//
//  GeoViewController.swift
//  HandiParking
//
//  Created by Gaël on 10/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MapKit

/// Contrôleur de la vue géolocalisation 📍

class GeoViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIActionSheetDelegate, SwiftSpinnerDelegate {
    
    //MARK: Outlets
    
    /// la carte
    @IBOutlet weak var mapView: GMSMapView!
    
    /// petit résumé des places trouvées
    @IBOutlet weak var resultsInRadius: LTMorphingLabel!
    
    /// loader lors du chargement des informations d'infoWindow
    @IBOutlet weak var loadingInfoWindow: UIView!
    
    /// bouton StreetView
    @IBOutlet weak var streetViewButtonText: UIBarButtonItem!
    
    /// bouton itinéraire
    @IBOutlet weak var itineraryButtonText: UIBarButtonItem!
    
    /**
        Appelée quand le bouton lancement est tapé
    */
    @IBAction func launchButtonAction(sender: AnyObject) {
        launchAction()
    }
    
    /**
        Appelée quand le bouton itinéraire est tapé
    */
    @IBAction func itineraryButtonAction(sender: AnyObject) {
        itineraryAction()
    }

    /**
        Appelée quand le bouton StreetView est tapé
    */
    @IBAction func streetViewButtonAction(sender: AnyObject) {
        streetViewAction()
    }
    
    ///MARK: Property
    
    /// déclaration d'un alias pour les notifications KVO + instanciation d'un contexte
    typealias KVOContext = UInt8
    var MyObservationContext = KVOContext()
    
    /// gestionnaire de la localisation
    var locationManager = CLLocationManager()
    
    /// rayon de recherche (mètres) des emplacements
    var radius: SearchRadius = SearchRadius(rawValue: 1)!
    
    /// liste des emplacements récupérés
    var parkingSpaces = [ParkingSpace]()
    
    /// gestionnaire des requêtes pour OpenStreetMap
    var managerOSM: Alamofire.Manager?
    
    /// gestionnaire des requêtes pour Google Maps
    var managerGM: Alamofire.Manager?
    
    /// tableau de marqueurs ajoutés sur la carte
    var markers = [PlaceMarker]()
    
    /// requête de recherche OpenStreetMap (permet de l'annuler à tout moment)
    var requestOSM: Alamofire.Request?
    
    // MARK: Init & deinit
    
    /**
        Instanciation de la vue
        
        - initialise les composants nécessaires
    */
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // fait de la vue le délégué de locationMananger afin d'utiliser la localisation
        // demande l'autorisation si besoin
        // fait de la vue le délégué de map afin d'utiliser la carte
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        // instanciation du manager de requêtes OSM + GM
        let configurationOSM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationOSM.timeoutIntervalForRequest = 10 // secondes
        managerOSM = Alamofire.Manager(configuration: configurationOSM)
        
        let configurationGM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationGM.timeoutIntervalForRequest = 10 // secondes
        managerGM = Alamofire.Manager(configuration: configurationGM)
        
        /// création des options pour les notifications KVO : ancienne et nouvelle valeur
        let options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old
        
        /// ajout d'un observateur : self recevra les notifications de l'attribut selectedMarker de l'objet map et les deux valeurs (ancienne et nouvelle) de selectedMarker seront passées à la méthode qui observe
        mapView.addObserver(self, forKeyPath: "selectedMarker", options: options, context: &MyObservationContext)
        
        self.loadingInfoWindow.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
        
    }
    
    /**
        Appelé juste avant que la vue apparaisse (nom de la fonction assez obvious)
    
        D'après mois, comme notre ViewController est utilisé comme parent et que SwiftSpinner est un singleton, le delegate ne fait pas de liaison dynamique ascendante une fois que le fils de ce ViewController est instancié. Ainsi on doit redéfinir le delegate dès que la vue apparait sinon la liaison reste bloquée dans le ViewController le plus bas dans la hiérarchie. 
            Dès que SearchSelectedViewController est instancié, il devient le ViewController le plus bas de la hiérarchie et donc quand on revient sur GeoViewController (son père), le delegate se fait toujours sur SearchSelectedViewController. On doit donc manuellement redéfinir le delegate à l'apparition de la vue pour que le delegate se fasse sur le bon ViewController.
    */
    override func viewWillAppear(animated: Bool) {
        SwiftSpinner.sharedInstance.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
        Implémentation de l'observateur
    
        Dans notre cas, on n'observe que selectedMarker, si nil on désactive les boutons itinéraire et StreetView, tout simplement
    */
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch (keyPath, context) {
        case("selectedMarker", &MyObservationContext):
            if mapView.selectedMarker == nil {
                setButtonsItineraryAndStreetViewInState(false)
                unloadInfoWindow()
            }
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: ActionSheet

    
    /**
        Appelée juste avant que l'instance soit désalloué de la mémoire. Ainsi on supprime l'observateur avant de désallouer l'instance et l'application ne crash pas en désallouant la carte
    */
    deinit {
        mapView.removeObserver(self, forKeyPath: "selectedMarker", context: &MyObservationContext)
    }
    
    /**
        Appelée dès qu'un bouton de l'action sheet est tappé
        On test si l'application est toujours installée, on génère l'URL scheme et on bascule vers l'application choisie
    */
    func actionSheet(sheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > 0 {
            if MapsAppsData().isInstalled(sheet.buttonTitleAtIndex(buttonIndex)) {
                var marker = mapView.selectedMarker as! PlaceMarker
                var urlscheme: NSString = MapsAppsData().generateURLScheme(sheet.buttonTitleAtIndex(buttonIndex), location: self.locationManager.location.coordinate, marker: marker)
                // on parse l'URL sinon les caractères Unicode font crasher lors de openURL()
                var urlParse: NSString = urlscheme.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                UIApplication.sharedApplication().openURL(NSURL(string: urlParse as String)!)
            } else {
                AlertViewController().appsDeleted(sheet.buttonTitleAtIndex(buttonIndex))
            }
            
        }
    }
    
    // MARK: Localisation
    
    /**
        Appelée dès que le statut de l'autorisation change : chargement de la vue, changement d'application, etc.
        Si toutes les services sont opérationnels, on met à jour la localisation
    */
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if ServicesController().servicesAreWorking() {
            
            // on affiche le bouton Ma position dans la vue et on lance l'actualisation de la localisation
            mapView.settings.myLocationButton = true
            mapView.myLocationEnabled = true
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    /**
        Appelée dès que la localisation change
        On suppose ici qu'une vérification des services a été effectuées avant de lancer l'actualisation de la localisation
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            
            updateMapCameraOnUserLocation()
            locationManager.stopUpdatingLocation()
        }
    }
    
    /**
        Appelée dès que le bouton Ma position est tappé
        N'est appelée que si le service de localisation est activé et que l'autorisation est permise
    */
    func didTapMyLocationButtonFormap(map: GMSMapView!) -> Bool {
        if ServicesController().servicesAreWorking() {
            locationManager.startUpdatingLocation()
        }
        return true
    }
    
    
    /**
        Centre la caméra (vue) sur la localisation actuelle
        On suppose ici qu'une vérification des services a été effectuées et que la localisation a été actualisé au moins une fois
    */
    func updateMapCameraOnUserLocation() {
        var camera = GMSCameraPosition(target: locationManager.location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animateToCameraPosition(camera)
    }
    
    // MARK: Fonctions de contrôle et de lancement
    
    /**
        Vérifie si on peut lancer la recherche et la lance ou affiche une erreur dans le cas contraire
    */
    func launchAction() {
        if ServicesController().servicesAreWorking() {
            if let locationWasGet = locationManager.location {
                launchRecherche()
            } else {
                AlertViewController().locationWasNotGet()
            }
        }
    }
    
    /**
        Vérifie si on peut afficher l'action sheet et l'affiche ou génère une erreur
    */
    func itineraryAction() {
        if ServicesController().servicesAreWorking() {
            if let locationWasGet = locationManager.location {
                var sheet = MapsAppsData().generateActionSheet()
                sheet.delegate = self
                sheet.showInView(view)
                
            } else {
                AlertViewController().locationWasNotGet()
            }
        }
    }
    
    /**
        Vérifie si on peut lancer StreetView (connexion Internet)
    */
    func streetViewAction() {
        if ServicesController().servicesAreWorking() {
            
            if ServicesController().checkInternetConnection() {
                var streetView = StreetViewController(marker: mapView.selectedMarker as! PlaceMarker)
                presentViewController(streetView, animated: true, completion: nil)
            }
        }
        
    }
    
    /**
        Initie le lancement de la recherche d'emplacements en remettant les données à zéro
    */
    func launchRecherche() {
        parkingSpaces.removeAll(keepCapacity: false)
        radius = SearchRadius(rawValue: 1)!
        getEmplacements(sourceOfSearch(), radius: radius)
        self.resultsInRadius.text = nil
    }
    
    /**
        Vérifie les résultats de la recherche et en initie une nouvelle s'il n'y a pas assez de résultats
        Si en revanche il y a assez de résultats, on peut préparer les données pour le traitement et l'affichage
    */
    func searchResultsController() {
        if(parkingSpaces.count >= DataProvider.OpenStreetMap.minimumResults) {
            resetServerParameters()
            sortAndFilterNearestPlace()
            controlIfPlaceFound()
        } else if let newRadius = SearchRadius(rawValue: radius.rawValue+1){
            parkingSpaces.removeAll(keepCapacity: false)
            radius = newRadius
            getEmplacements(sourceOfSearch(), radius: radius)
        } else {
            resetServerParameters()
            controlIfPlaceFound()
        }
    }
    
    /**
        Retourne les coordonnées de la "source", l'emplacement duquel on veut partir
        Ici c'est la position actuelle de l'utilisateur
    */
    func sourceOfSearch() -> CLLocationCoordinate2D {
        return locationManager.location.coordinate
    }
    
    /**
        Tri les places trouvées par ordre décroissant selon la distance à vol d'oiseau et ne récupère que le minimum de places à afficher défini dans DataProvider
    */
    func sortAndFilterNearestPlace() {
        
        parkingSpaces.sort({ $0.distance < $1.distance })
        var newParkSpac = [ParkingSpace]()
        
        for index in 0...DataProvider.OpenStreetMap.minimumResults-1 {
            newParkSpac.append(parkingSpaces[index])
        }
        
        parkingSpaces = newParkSpac
    }
    
    /**
        Formatte une chaîne qui résume le nombre de places trouvées/dans quel rayon
        
        :return: la chaîne formatée prête à être utilisée
    */
    func makeStringSearchResultsInRadius() -> NSString {
        var formattedString:String
        
        switch parkingSpaces.count {
        case 0:
            formattedString = NSLocalizedString("NO_SPACE_FOUND", comment: "no space found")
        default:
            switch parkingSpaces.count {
            case 1:
                formattedString = String(format: NSLocalizedString("NB_SPACE", comment: "nb space"), String(parkingSpaces.count))
            default:
                formattedString = String(format: NSLocalizedString("NB_SPACES", comment: "nb spaces"), String(parkingSpaces.count))
            }
            formattedString += NSLocalizedString("RADIUS_OF", comment: "radius of")
            if radius.value > 500 {
                formattedString += "\(radius.value/1000) km"
            } else {
                formattedString += "\(radius.value) m"
            }
        }
        
        return formattedString
    }
    
    /**
        Création du message des résultats + lancement du traitement des markers ou erreur
    */
    func controlIfPlaceFound() {
        if !parkingSpaces.isEmpty {
            createMarkersAndBoundsToDisplay()
        } else {
            SwiftSpinner.hide()
            AlertViewController().noPlacesFound(radius)
        }
        changeSearchResultsEffect()
        self.delay(seconds: 1.3, completion: {
            self.resultsInRadius.text = self.makeStringSearchResultsInRadius()
  as String       })
        
        if resultsInRadius.hidden {
            resultsInRadius.alpha = 0.0
            resultsInRadius.hidden = false
            UIView.animateWithDuration(2.5, animations: {
                self.resultsInRadius.alpha = 0.85
            })
        }
        
    }
    
    /**
        Met à jour l'effet d'apparition du label de résultats
    
    */
    func changeSearchResultsEffect() {
        switch arc4random_uniform(5) {
        case 0:
            self.resultsInRadius.morphingEffect = .Evaporate
        case 1:
            self.resultsInRadius.morphingEffect = .Fall
        case 2:
            self.resultsInRadius.morphingEffect = .Pixelate
        case 3:
            self.resultsInRadius.morphingEffect = .Sparkle
        default:
            self.resultsInRadius.morphingEffect = .Scale
        }
    }
    
    /**
        Met à jour le statut des boutons dans l'état activé ou désactivé
    
        :param: state L'état du bouton à applique
    
    */
    func setButtonsItineraryAndStreetViewInState(state: Bool) {
        itineraryButtonText.enabled = state
        streetViewButtonText.enabled = state
    }
    
    // MARK: Carte
    
    /**
        Appelé dès qu'un marqueur est tappé
        On retourne faux pour que le comportement par défaut soit réalisé (ou vrai si on veut l'override)
        Si les services (internet, localisation) et la localisation sont ok et si les informations n'ont pas encore été récupérées, on lance leur récupération
    
    */
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if mapView.selectedMarker != nil {
            mapView.selectedMarker = nil
        }
        if ServicesController().servicesAreWorking() && locationManager.location != nil {
            if (marker as! PlaceMarker).place.address == nil {
                reverseGeocodeCoordinate(marker as! PlaceMarker)
            }
            if (marker as! PlaceMarker).place.distanceETA == nil && (marker as! PlaceMarker).place.durationETA == nil {
                getExpectedDistanceAndTravelTime(marker as! PlaceMarker)
            }
        } else {
            mapView.selectedMarker = nil
        }
        return false
    }
    
    /**
        Appelé juste avant que l'infoWindow soit affiché
        On load notre vue personnalisée et on affiche si disponible les informations
        Si les informations ne sont pas encore disponible (en cours de récupération), on lock la vue
        Dès que les informations sont disponible (récupération ok ou échouée), on unlock la vue et on affiche
    */
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let placeMarker = marker as! PlaceMarker
        var optionalDataHasNotBeenSet:Bool = (placeMarker.place.address == nil) || (placeMarker.place.distanceETA == nil) || (placeMarker.place.durationETA == nil)
        var nibName:String
        if placeMarker.place.name == nil {
            nibName = "InfoMarkerWindowWithoutName"
        } else {
            nibName = "InfoMarkerWindow"
        }
        if let infoView = UIView.viewFromNibName(nibName) as? InfoMarkerWindow {
            if (optionalDataHasNotBeenSet) {
                infoView.lock()
                loadInfoWindow()
                
            } else {
                infoView.unlock()
                unloadInfoWindow()
                infoView.address.text = placeMarker.place.address
                infoView.duration.text = placeMarker.place.getDuration() as String
                infoView.distance.text = placeMarker.place.getDistance() as String
                if nibName == "InfoMarkerWindow" {
                    infoView.name.text = placeMarker.place.name
                }
                infoView.capacity.text = placeMarker.place.capacity
                infoView.fee.text = placeMarker.place.fee
                
                setButtonsItineraryAndStreetViewInState(true)
            }
            
            return infoView
        } else {
            return nil
        }
    }
    
    /**
        Ajoute un spinner au bas de la vue pour signaler à l'utilisateur qu'une activité est en cours
    */
    func loadInfoWindow() {
        let loadingView = UIView(frame: CGRectMake(0, 0, self.loadingInfoWindow.bounds.size.width, self.loadingInfoWindow.bounds.size.height))
        loadingView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
        
        let myActivityIndicatorView: DTIActivityIndicatorView = DTIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
        myActivityIndicatorView.center = loadingView.center
        myActivityIndicatorView.alpha = 0.0
        myActivityIndicatorView.indicatorColor = UIColor(red: 0/255, green: 142/255, blue: 255/255, alpha: 1.0)
        myActivityIndicatorView.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        myActivityIndicatorView.startActivity()
        
        loadingView.addSubview(myActivityIndicatorView)
        
        UIView.animateWithDuration(0.5) {
            myActivityIndicatorView.alpha = 1.0
        }
        
        loadingInfoWindow.addSubview(loadingView)
    }
    
    /**
        Supprimer le spinner d'activité en bas de la vue
    */
    func unloadInfoWindow() {
        if let views = loadingInfoWindow.subviews as? [UIView] {
            for view in views {
              view.removeFromSuperview()
            }
        }
    }
    
    /**
        Traitement & affichage des marqueurs sur la carte
        En même temps, on calcule les bornes afin d'ajuster la caméra pour afficher tous les marqueurs (+ padding pour laisser de la marge autour de la carte)
    */
    func createMarkersAndBoundsToDisplay() {
        mapView.clear()
        markers.removeAll(keepCapacity: false)
        SwiftSpinner.show(NSLocalizedString("FORMA_DATA", comment: "Formatting data"))
        var firstLocation: CLLocationCoordinate2D
        var bounds = GMSCoordinateBounds(coordinate: sourceOfSearch(), coordinate: sourceOfSearch())
        for place: ParkingSpace in parkingSpaces {
            let marker = PlaceMarker(place: place)
            bounds = bounds.includingCoordinate(marker.position)
            markers.append(marker)
            marker.map = mapView
        }
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 50.0))
        SwiftSpinner.hide()
        
    }
    
    /**
        Permet de changer le serveur OSM sur lequel on effectue les appels
        On fait une rotation sur un tableau et quand on est au bout, on revient au début du tableau
    */
    func switchServer() {
        DataProvider.OpenStreetMap.nbServerUsed++
        var actualServer = DataProvider.OpenStreetMap.actualServer
        
        if actualServer < DataProvider.OpenStreetMap.listOSMServers.count-1 {
            DataProvider.OpenStreetMap.actualServer++
        } else {
            DataProvider.OpenStreetMap.actualServer = 0
        }
    }
    
    /**
        Reset le switch des serveurs
        Appelée dès que la recherche est un succès
    */
    func resetServerParameters() {
        DataProvider.OpenStreetMap.nbServerUsed = 0
    }
    
    // MARK: Recherche & récupération de données
    
    /**
        Recherche des emplacements de places grâce à l'API d'OSM
    
        :param: coordinate Les coordonnées (latitude, longitue) de notre position actuelle
    
        :param: radius Le rayon (en mètres) de recherche
    
        La requête est effectuée de façon asynchrone grâce à une closure, avec un timeout de 10 secondes.
    
        Après ce timeout, on swich de serveur (si possible).
    
        Quand la requête est un succès, on appelle une fonction contrôleur qui va vérifier les résultats.
    */
    func getEmplacements(coordinate: CLLocationCoordinate2D, radius: SearchRadius) {
        
        if radius.rawValue % 2 == 0 {
            SwiftSpinner.show(NSLocalizedString("SEARCHING", comment: "In progress"))
        } else {
            SwiftSpinner.show(NSLocalizedString("WAITING", comment: "In progress 2"))
        }
        self.requestOSM = managerOSM!.request(DataProvider.OpenStreetMap.GetNodes(coordinate,radius)).validate().responseSwiftyJSON({ (request, response, json, error) -> Void in
            if error == nil {
                let elements = json["elements"].arrayValue
                
                for place in elements {
                    var id: String? = place["id"].stringValue
                    var lat: String? = place["lat"].stringValue
                    var lon: String? = place["lon"].stringValue
                    var name: String?
                    var fee: String?
                    var capacity:String?
                    var distance:CLLocationDistance
                    
                    for tag in place["tags"] {
                        switch tag.0 {
                        case "name":
                            name = tag.1.stringValue
                        case "fee":
                            fee = tag.1.stringValue
                        case "capacity:disabled":
                            capacity = tag.1.stringValue
                        default:
                            break
                        }
                    }
                    
                    var nodeLocation = CLLocation(latitude: NSString(string: lat!).doubleValue, longitude: NSString(string: lon!).doubleValue)
                    var selfSource = self.sourceOfSearch()
                    var selfLocation = CLLocation(latitude: selfSource.latitude, longitude: selfSource.longitude)
                    distance = selfLocation.distanceFromLocation(nodeLocation)
                    
                    var parkingSpace = ParkingSpace(id: id, lat: lat, lon: lon, name: name, fee: fee, capacity: capacity, distance: distance)
                    self.parkingSpaces.append(parkingSpace)
                }
                self.searchResultsController()
            } else {
                if error?.code == -999 {
                   SwiftSpinner.show(NSLocalizedString("SEARCH_CANCELLED", comment: "Search cancelled"), animated: false)
                    self.delay(seconds: 1.0, completion: {
                        SwiftSpinner.hide()
                    }) 
                } else {
                    if DataProvider.OpenStreetMap.nbServerUsed < DataProvider.OpenStreetMap.listOSMServers.count-1 {
                        self.switchServer()
                        self.getEmplacements(coordinate, radius: radius)
                    } else {
                        SwiftSpinner.hide()
                        AlertViewController().errorRequest()
                        // remise à zéro des paramètres de switch serveurs puisque erreur
                        self.resetServerParameters()
                    }
                }
            }
        })
        
    }
    
    /**
        Récupération de l'adresse approximative de la place sélectionnée (Google)
    
        :param: place Le marqueur sélectionné
    
        On effectue une requête grâce à Google Maps SDK afin de récupérer l'adresse de la place sélectionnée
    
        La requête est effectuée de façon asynchrone grâce à une closure, avec timeout (défini par Google).
    */
    func reverseGeocodeCoordinate(place: PlaceMarker) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(place.position) { response , error in
            var address:String?
            if error == nil {
                
                if let addressGet = response?.firstResult() {
                    
                    let lines = addressGet.lines as! [String]
                    address = join(", ", lines)
                }
                
            }
            place.place.setAddress(address)
            self.mapView.selectedMarker = place
        }
    }
    
    /**
        Récupération de la distance et du temps de parcours estimé (Apple) entre la place sélectionnée et la position actuelle
    
        :param: place Le marqueur sélectionné
    
        On effectue une requête grâce à MapKit (Apple) afin de récupérer la distance et le temps de parcours pour se rendre sur ce lieu, en partant de la position actuelle.
    
        La requête est effectuée de façon asynchrone grâce à une closure, avec timeout (défini Apple).
    */
    func getExpectedDistanceAndTravelTime(place: PlaceMarker) {
        var sourcePlacemark:MKPlacemark = MKPlacemark(coordinate: locationManager.location.coordinate, addressDictionary: nil)
        var destinationPlacemark:MKPlacemark = MKPlacemark(coordinate: place.position, addressDictionary: nil)
        var source:MKMapItem = MKMapItem(placemark: sourcePlacemark)
        var destination:MKMapItem = MKMapItem(placemark: destinationPlacemark)
        var directionRequest:MKDirectionsRequest = MKDirectionsRequest()
        
        directionRequest.setSource(source)
        directionRequest.setDestination(destination)
        directionRequest.transportType = MKDirectionsTransportType.Automobile
        directionRequest.requestsAlternateRoutes = true
        
        var directions:MKDirections = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler({
            (response: MKDirectionsResponse!, error: NSError?) in
            
            var timeETA:NSTimeInterval?
            var distanceETA:CLLocationDistance?
            
            if response != nil {
                if response.routes.count > 0 {
                    
                    var route = response.routes.first! as! MKRoute
                    
                    timeETA = route.expectedTravelTime
                    
                    distanceETA = route.distance
                    
                }
            }
            place.place.setDistanceAndDurationETA(distanceETA, durETA: timeETA)
            self.mapView.selectedMarker = place
        })
    }
    
    /**
        Recherche des informations complémentaires entre deux lieux
    
        :param: place Le marqueur sélectionné
    
        On effectue une requête sur l'API de Google Maps afin de récupérer l'adresse du lieu de destination ainsi que la distance et le temps de parcours pour se rendre sur ce lieu, grâce à la position actuelle.
    
        La requête est effectuée de façon asynchrone grâce à une closure, avec un timeout de 10 secondes.
    */
    func getInformations(place: PlaceMarker) {
        if place.place.address == nil {
            let request = managerGM!.request(DataProvider.GoogleMaps.DistanceMatrix(locationManager.location.coordinate, place.position))
            request.validate()
            request.responseSwiftyJSON({ (request, response, json, error) -> Void in
                if error == nil  {
                    var dataRecup = json
                    var status:String? = dataRecup["status"].stringValue
                    
                    var adresse:String?
                    var duration:String?
                    var distance:String?
                    
                    if status == "OK" {
                        
                        var destination = dataRecup["destination_addresses"]
                        
                        if !destination.isEmpty {
                            adresse = destination.arrayValue[0].stringValue
                        }
                        
                        var rows = dataRecup["rows"].arrayValue
                        
                        if !rows.isEmpty {
                            
                            let element = rows[0]["elements"].arrayValue
                            
                            let firstData = element[0]
                            
                            if firstData["status"].stringValue == "OK" {
                                
                                duration = firstData["duration"]["text"].stringValue
                                
                                distance = firstData["distance"]["text"].stringValue
                                
                                println("Distance estimée \(distance)")
                                println("Temps estimé \(duration)")
                            }
                            
                        }
                        
                        self.mapView.selectedMarker = place
                        
                    } else {
                        self.mapView.selectedMarker = nil
                        AlertViewController().errorResponseGoogle()
                    }
                    
                } else {
                    self.mapView.selectedMarker = nil
                    AlertViewController().errorRequest()
                }
            })
        }
    }
    
    /**
        Permet de lancer un timer avec completion handler
        :param: #seconds: le nombre de secondes à attendre avant d'effectuer l'action dans le handler
        :param: le handler
    */
    func delay(#seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    //MARK: SwiftSpinnerDelegate
    
    /**
        Appelée dès que le bouton close de la vue SwiftSpinner est tappé
        On annule la requête et remet les variables utilent à la recherche à zéro
    */
    func didTapCloseButton() {
        self.requestOSM?.cancel()
        changeSearchResultsEffect()
        self.delay(seconds: 1.3, completion: {
            self.resultsInRadius.text = NSLocalizedString("SEARCH_CANCELLED", comment: "Search cancelled")
        })
        if resultsInRadius.hidden {
            resultsInRadius.alpha = 0.0
            resultsInRadius.hidden = false
            UIView.animateWithDuration(2.5, animations: {
                self.resultsInRadius.alpha = 0.85
            })
        }
        parkingSpaces.removeAll(keepCapacity: false)
        radius = SearchRadius(rawValue: 1)!
    }
    
}



