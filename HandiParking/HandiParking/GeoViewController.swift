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

class GeoViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIActionSheetDelegate {
    
    //MARK: Variables
    
    /// lien de sortie vers la carte
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var resultsInfo: UILabel!
    
    /// bouton pour lancer la recherche de places - action
    @IBAction func launchButtonAction(sender: AnyObject) {
        if ServicesController().servicesAreWorking() {
            if let locationWasGet = locationManager.location {
                launchRecherche()
            } else {
                AlertViewController().locationWasNotGet()
            }
        }
    }
    
    /// bouton pour afficher les applications pour l'itinéraire - layout
    @IBOutlet weak var itineraryButtonText: UIBarButtonItem!
    
    /// bouton pour afficher les applications pour l'itinéraire - action
    @IBAction func itineraryButtonAction(sender: AnyObject) {
        if ServicesController().servicesAreWorking() {
            if let locationWasGet = locationManager.location {
                var sheet = MapsAppsData().generateActionSheet()
                sheet.delegate = self
                sheet.showInView(self.view)
                
            } else {
                AlertViewController().locationWasNotGet()
            }
        }
    }
    
    /// bouton pour afficher StreetView - layout
    @IBOutlet weak var streetViewButtonText: UIBarButtonItem!
    
    /// bouton pour afficher StreetView - action
    @IBAction func streetViewButtonAction(sender: AnyObject) {
        if ServicesController().servicesAreWorking() {
            
            var streetView = StreetViewController(marker: self.mapView.selectedMarker as PlaceMarker)
            
            self.presentViewController(streetView, animated: true, completion: nil)
        }
        
    }
    
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
    
    // MARK: Démarrage
    
    /**
        Instanciation de la vue
        
        - initialise les composants nécessaires
    */
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // fait de la vue le délégué de locationMananger afin d'utiliser la localisation
        // demande l'autorisation si besoin
        // fait de la vue le délégué de mapView afin d'utiliser la carte
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        // instanciation du manager de requêtes OSM + GM
        let configurationOSM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationOSM.timeoutIntervalForRequest = 10 // secondes
        self.managerOSM = Alamofire.Manager(configuration: configurationOSM)
        
        let configurationGM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationGM.timeoutIntervalForRequest = 10 // secondes
        self.managerGM = Alamofire.Manager(configuration: configurationGM)
        
        /// création des options pour les notifications KVO : ancienne et nouvelle valeur
        let options = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old
        
        /// ajout d'un observateur : self recevra les notifications de l'attribut selectedMarker de l'objet mapView et les deux valeurs (ancienne et nouvelle) de selectedMarker seront passées à la méthode qui observe
        mapView.addObserver(self, forKeyPath: "selectedMarker", options: options, context: &MyObservationContext)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
        Appelée juste avant que l'instance soit désalloué de la mémoire. Ainsi on supprime l'observateur avant de désallouer l'instance et l'application ne crash pas en désallouant mapView
    */
    deinit {
        mapView.removeObserver(self, forKeyPath: "selectedMarker", context: &MyObservationContext)
    }
    
    /**
        Implémentation de l'observateur
    
        Dans notre cas, on n'observe que selectedMarker, si nil on désactive le bouton d'itinéraire, tout simplement
    */
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch (keyPath, context) {
            case("selectedMarker", &MyObservationContext):
                if self.mapView.selectedMarker == nil {
                    self.itineraryButtonText.enabled = false
                    self.streetViewButtonText.enabled = false
                }
            default:
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    /**
        Appelée dès qu'un bouton de l'action sheet est tappé
        On test si l'application est toujours installée, on génère l'URL scheme et on bascule vers l'application choisie
    */
    func actionSheet(sheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > 0 {
            if MapsAppsData().isInstalled(sheet.buttonTitleAtIndex(buttonIndex)) {
                var marker = mapView.selectedMarker as PlaceMarker
                var urlscheme: NSString = MapsAppsData().generateURLScheme(sheet.buttonTitleAtIndex(buttonIndex), location: self.locationManager.location.coordinate, marker: marker)
                // on parse l'url sinon les caractères Unicode font crasher lors de openURL()
                var urlParse: NSString = urlscheme.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                UIApplication.sharedApplication().openURL(NSURL(string: urlParse)!)
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

                // on affiche le bouton My Location dans la vue et on lance l'actualisation de la localisation
                mapView.settings.myLocationButton = true
                mapView.myLocationEnabled = true
                locationManager.startUpdatingLocation()
            
        }
        
    }
    
    /**
        Appelé dès que la localisation change
        On suppose ici qu'une vérification des services a été effectuées avant de lancer l'actualisation de la localisation
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {

            updateMapCameraOnUserLocation()
            locationManager.stopUpdatingLocation()
        }
    }
    
    /**
        Appelé dès que le bouton Ma position est tappé
        N'est appelé que si le service de localisation est activé et que l'autorisation est permise
    */
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
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
    
    /**
        Initie le lancement de la recherche d'emplacements avec les données remise à zéro
    */
    func launchRecherche() {
        mapView.clear()
        resultsInfo.hidden = true
        self.markers.removeAll(keepCapacity: false)
        self.parkingSpaces.removeAll(keepCapacity: false)
        self.radius = SearchRadius(rawValue: 1)!
        self.getEmplacements(locationManager.location.coordinate, radius: self.radius)
    }
    
    /**
        Vérifie les résultats de la recherche et en initie une nouvelle s'il n'y a pas assez de résultats
        Si en revanche il y a assez de résultats, on peut préparer les données pour le traitement/affichage
    */
    func searchResultsController() {
        if(self.parkingSpaces.count >= DataProvider.OpenStreetMap.minimumResults) {
            sortAndFilterNearestPlace()
            createMarkersAndBoundsToDisplay()
        } else if let newRadius = SearchRadius(rawValue: self.radius.rawValue+1){
            self.parkingSpaces.removeAll(keepCapacity: false)
            self.radius = newRadius
            self.getEmplacements(locationManager.location.coordinate, radius: self.radius)
        } else {
            createMarkersAndBoundsToDisplay()
        }
    }
    
    func sortAndFilterNearestPlace() {

        self.parkingSpaces.sort({ $0.distance < $1.distance })
        var newParkSpac = [ParkingSpace]()
        
        for index in 0...DataProvider.OpenStreetMap.minimumResults-1 {
            newParkSpac.append(self.parkingSpaces[index])
        }
        
        self.parkingSpaces = newParkSpac
    }
    
    func makeStringSearchResultsInfo() -> NSString {
        var string = "\(self.parkingSpaces.count) place"
        if self.parkingSpaces.count > 1 {
            string += "s"
        }
        string += " dans un rayon de "
        if self.radius.value > 500 {
            string += "\(self.radius.value/1000) km"
        } else {
            string += "\(self.radius.value) m"
        }
        return string
    }
    
    /**
        Traitement & affichage des marqueurs sur la carte
        En même temps, on calcule les bornes afin d'ajuster la caméra pour afficher tous les marqueurs
    */
    func createMarkersAndBoundsToDisplay() {
        SwiftSpinner.show("Récupération des informations...")
        resultsInfo.text = makeStringSearchResultsInfo()
        var firstLocation: CLLocationCoordinate2D
        var bounds = GMSCoordinateBounds(coordinate: self.locationManager.location.coordinate, coordinate: self.locationManager.location.coordinate)
        if !self.parkingSpaces.isEmpty {
            for place: ParkingSpace in self.parkingSpaces {
                let marker = PlaceMarker(place: place)
                bounds = bounds.includingCoordinate(marker.position)
                self.markers.append(marker)
                marker.map = mapView
            }
            mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 50.0))
            SwiftSpinner.hide()
            resultsInfo.alpha = 0.0
            resultsInfo.hidden = false
            UIView.animateWithDuration(2.5, animations: {
                self.resultsInfo.alpha = 0.75
            })
            
        } else {
            SwiftSpinner.hide()
            AlertViewController().noPlacesFound(self.radius)
        }
        
    }
    
    /**
        Recherche des emplacements de places grâce à l'API d'OSM
    
        :param: coordinate Les coordonnées (latitude, longitue) de notre position actuelle
    
        :param: radius Le rayon (en mètres) de recherche
    
        La requête est effectuée de façon asynchrone grâce à une closure, avec un timeout de 10 secondes.
        Quand la requête est un succès, on appelle une fonction contrôleur qui va vérifier les résultats.    
    */
    func getEmplacements(coordinate: CLLocationCoordinate2D, radius: SearchRadius) {
        
        if self.radius.rawValue % 2 == 0 {
            SwiftSpinner.show("Recherche en cours...")
        } else {
            SwiftSpinner.show("Patientez...")
        }
        
        let request = self.managerOSM!.request(DataProvider.OpenStreetMap.GetNodes(coordinate,radius))
        request.validate()
        request.responseSwiftyJSON { request, response, json, error in
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
                        distance = self.locationManager.location.distanceFromLocation(nodeLocation)

                        var parkingSpace = ParkingSpace(id: id, lat: lat, lon: lon, name: name, fee: fee, capacity: capacity, distance: distance)
                        self.parkingSpaces.append(parkingSpace)
                    }
            
                self.searchResultsController()
            } else {
                SwiftSpinner.hide()
                AlertViewController().errorRequest()
            }
        }
        
    }
    
    /**
        Appelé dès qu'un marqueur est tappé
        On retourne faux pour que le comportement par défaut soit réalisé
        Si les services (internet, localisation) et la localisation sont ok et si les informations n'ont pas encore été récupérées, on lance leur récupération
    
    */
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if self.mapView.selectedMarker != nil {
            self.mapView.selectedMarker = nil
        }
        if ServicesController().servicesAreWorking() && locationManager.location != nil {
            if (marker as PlaceMarker).place.address == nil {
                reverseGeocodeCoordinate(marker as PlaceMarker)
            }
            if (marker as PlaceMarker).place.distanceETA == nil && (marker as PlaceMarker).place.durationETA == nil {
              getExpectedDistanceAndTravelTime(marker as PlaceMarker)
            }
        } else {
           self.mapView.selectedMarker = nil
        }
        return false
    }
    
    /**
        Appelé juste avant que infoWindow soit affiché
        On load notre vue personnalisée et on affiche si disponible les informations
        Si les informations ne sont pas encore disponible (en cours de récupération), on lock la vue
        Dès que les informations sont disponible (récupération ok ou échouée), on unlock la vue et on affiche
    */
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let placeMarker = marker as PlaceMarker
        var optionalDataHasNotBeenSet:Bool = (placeMarker.place.address == nil) || (placeMarker.place.distanceETA == nil) || (placeMarker.place.durationETA == nil)
        if let infoView = UIView.viewFromNibName("InfoMarkerWindow") as? InfoMarkerWindow {
            if (optionalDataHasNotBeenSet) {
                infoView.lock()
            } else {
                infoView.unlock()
                infoView.address.text = placeMarker.place.address
                infoView.duration.text = placeMarker.place.getDuration()
                infoView.distance.text = placeMarker.place.getDistance()
                infoView.name.text = placeMarker.place.name
                infoView.capacity.text = placeMarker.place.capacity
                infoView.fee.text = placeMarker.place.fee
                
                self.itineraryButtonText.enabled = true
                self.streetViewButtonText.enabled = true
            }
            
            return infoView
        } else {
            return nil
        }
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
                        
                        let lines = addressGet.lines as [String]
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
        var sourcePlacemark:MKPlacemark = MKPlacemark(coordinate: self.locationManager.location.coordinate, addressDictionary: nil)
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
                    
                    var route = response.routes.first! as MKRoute
                    
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
            let request = self.managerGM!.request(DataProvider.GoogleMaps.DistanceMatrix(self.locationManager.location.coordinate, place.position))
            request.validate()
            request.responseSwiftyJSON { request, response, json, error in
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

                        //self.mapView.selectedMarker = place
                        
                    } else {
                        //self.mapView.selectedMarker = nil
                        AlertViewController().errorResponseGoogle()
                    }
                    
                } else {
                    self.mapView.selectedMarker = nil
                    AlertViewController().errorRequest()
                }
            }
        }
    }
    
    

}



