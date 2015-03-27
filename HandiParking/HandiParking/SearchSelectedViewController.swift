//
//  SearchSelectedViewController.swift
//  HandiParking
//
//  Created by Gaël on 25/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class SearchSelectedViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIActionSheetDelegate {
    
    /// lien de sortie vers la carte
    @IBOutlet weak var mapView: GMSMapView!
    
    var streetViewButton: UIBarButtonItem!
    
    var itineraryButton: UIBarButtonItem!
    
    @IBOutlet weak var launchButtonText: UIButton!
    
    @IBAction func launchButtonAction(sender: AnyObject) {
        
        if let lat = self.place.lat {
            
            if ServicesController().servicesAreWorking() {
                if let locationWasGet = locationManager.location {
                    launchRecherche()
                } else {
                    AlertViewController().locationWasNotGet()
                }
            }
            
        } else {
            
            self.launchButtonText.enabled = false
            getCoordinate()
            
        }
    }
    
    /// lieu choisi
    var place = Lieu()
    
    /// déclaration d'un alias pour les notifications KVO + instanciation d'un contexte
    typealias KVOContext = UInt8
    var MyObservationContext = KVOContext()
    
    /// gestionnaire de la localisation
    var locationManager = CLLocationManager()
    
    /// rayon de recherche (mètres) des emplacements
    var rayon: RayonRecherche = RayonRecherche(rawValue: 1)!
    
    /// tableau des emplacements récupérés
    var emplacements = [Emplacement]()
    
    /// gestionnaire des requêtes pour OpenStreetMap
    var managerOSM: Alamofire.Manager?
    
    /// gestionnaire des requêtes pour Google Maps
    var managerGM: Alamofire.Manager?
    
    /// tableau de marqueurs ajoutés sur la carte
    var markers = [PlaceMarker]()

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
        
        self.navigationItem.rightBarButtonItems = setButtons()
        
        if ServicesController().checkInternetConnection() {
        
            getCoordinate()
        }
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
                self.itineraryButton.enabled = false
                self.streetViewButton.enabled = false
            }
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    
    
    func setButtons() -> NSArray {
        self.streetViewButton = UIBarButtonItem(image: UIImage(named: "toolbar_streetview"), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        streetViewButton.enabled = false
        self.itineraryButton = UIBarButtonItem(image: UIImage(named: "toolbar_itinerary"), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        itineraryButton.enabled = false
        var buttons: NSArray = [self.streetViewButton, self.itineraryButton]
        return buttons
    }
    
    func getCoordinate() {
            let request = self.managerGM!.request(DataProvider.GoogleMaps.PlaceDetails(self.place.placeid))
            request.validate()
            request.responseSwiftyJSON { request, response, json, error in
                if error == nil  {
                    var dataRecup = json
                    var status:String? = dataRecup["status"].stringValue
                    
                    var lat:String?
                    var lon:String?
                    
                    if status == "OK" {
                        
                        lat = dataRecup["result"]["geometry"]["location"]["lat"].stringValue
                        lon = dataRecup["result"]["geometry"]["location"]["lng"].stringValue
                        
                        self.place.setCoordinate(lat, lon:lon)
                        
                        var marker = self.place.generateMarker()
                        
                        marker.map = self.mapView
                        
                        self.updateMapCameraOnPlaceLocation()
                        
                        UIView.animateWithDuration(0.5, animations: {
                            self.launchButtonText.alpha = 0.0
                        }) { finished in
                                self.launchButtonText.setImage(UIImage(named: "toolbar_launch"), forState: .Normal)
                                self.launchButtonText.enabled = true
                                UIView.animateWithDuration(0.5, animations: {
                                    self.launchButtonText.alpha = 1.0
                                })
                        }
                        
                    } else {
                        
                        self.launchButtonText.enabled = true
                        AlertViewController().errorResponseGoogle()
                    }
                    
                } else {
                    
                    self.launchButtonText.enabled = true
                    AlertViewController().errorRequest()
                }
            }
        
    }
    
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
            
            locationManager.stopUpdatingLocation()
            updateMapCameraOnUserLocation()
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
    Centre la caméra (vue) sur la localisation du lieu recherchée
    On suppose ici qu'une vérification des services a été effectuées et que la localisation du lieu a été récupérée
    */
    func updateMapCameraOnPlaceLocation() {
        var marker = place.generateMarker()
        var camera = GMSCameraPosition(target: marker.position, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animateToCameraPosition(camera)
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
        self.markers.removeAll(keepCapacity: false)
        self.emplacements.removeAll(keepCapacity: false)
        self.rayon = RayonRecherche(rawValue: 1)!
        self.getEmplacements(locationManager.location.coordinate, radius: self.rayon)
    }
    
    /**
    Vérifie les résultats de la recherche et en initie une nouvelle s'il n'y a pas assez de résultats
    Si en revanche il y a assez de résultats, on peut préparer les données pour le traitement/affichage
    */
    func searchResultsController() {
        println(self.emplacements.count)
        println(self.rayon.valeur)
        if(self.emplacements.count > DataProvider.OpenStreetMap.minimumResults) {
            createMarkersAndBoundsToDisplay()
        } else if let newRayon = RayonRecherche(rawValue: self.rayon.rawValue+1){
            self.emplacements.removeAll(keepCapacity: false)
            self.rayon = newRayon
            self.getEmplacements(locationManager.location.coordinate, radius: self.rayon)
        } else {
            createMarkersAndBoundsToDisplay()
        }
    }
    
    /**
    Traitement & affichage des marqueurs sur la carte
    En même temps, on calcule les bornes afin d'ajuster la caméra pour afficher tous les marqueurs
    */
    func createMarkersAndBoundsToDisplay() {
        SwiftSpinner.show("Récupération des informations...")
        var firstLocation: CLLocationCoordinate2D
        var bounds = GMSCoordinateBounds(coordinate: self.locationManager.location.coordinate, coordinate: self.locationManager.location.coordinate)
        if !self.emplacements.isEmpty {
            for place: Emplacement in self.emplacements {
                let marker = PlaceMarker(place: place)
                bounds = bounds.includingCoordinate(marker.position)
                self.markers.append(marker)
                marker.map = mapView
            }
            mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 50.0))
            SwiftSpinner.hide()
        } else {
            SwiftSpinner.hide()
            AlertViewController().noPlacesFound()
        }
        
    }
    
    /**
    Recherche des emplacements de places grâce à l'API d'OSM
    
    :param: coordinate Les coordonnées (latitude, longitue) de notre position actuelle
    
    :param: radius Le rayon (en mètres) de recherche
    
    La requête est effectuée de façon asynchrone grâce à une closure, avec un timeout de 10 secondes.
    Quand la requête est un succès, on appelle une fonction contrôleur qui va vérifier les résultats.
    */
    func getEmplacements(coordinate: CLLocationCoordinate2D, radius: RayonRecherche) {
        
        if self.rayon.rawValue % 2 == 0 {
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
                    
                    var emplacement = Emplacement(id: id, lat: lat, lon: lon, name: name, fee: fee, capacity: capacity)
                    self.emplacements.append(emplacement)
                }
                
                self.searchResultsController()
            } else {
                SwiftSpinner.hide()
                AlertViewController().errorRequest()
            }
        }
        
    }



    
    
    
}
