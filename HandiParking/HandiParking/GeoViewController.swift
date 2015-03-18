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

/// Contrôleur de la vue géolocalisation 📍

class GeoViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //MARK: Variables
    
    // lien de sortie vers la carte
    @IBOutlet weak var mapView: GMSMapView!
    
    //lien vers le bouton de droite de la barre de navigation
    @IBAction func launchSearch(sender: AnyObject) {
        if ServicesController().servicesAreWorking() {
            if let locationWasGet = locationManager.location {
                SwiftSpinner.show("Recherche en cours...")
                launchRecherche()
            } else {
                AlertViewController().locationWasNotGet()
            }
            
        }
    }
    
    // gestionnaire de la localisation
    var locationManager = CLLocationManager()
    
    // rayon de recherche (mètres) des emplacements
    var rayon: RayonRecherche = RayonRecherche(rawValue: 1)!
    
    // tableau des emplacements récupérés
    var emplacements = [Emplacement]()
    
    // gestionnaire des requêtes pour OpenStreetMap
    var managerOSM: Alamofire.Manager?
    
    //gestionnaire des requêtes pour Google Maps
    var managerGM: Alamofire.Manager?
    
    // tableau de marqueurs ajoutés sur la carte
    var markers = [PlaceMarker]()
    
    var markerFilledWithInfos:Int = 0
    
    // MARK: Démarrage
    
    /**
        Instanciation de la vue
        
        - initialise les composants nécessaires
    */
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set le titre dans la barre de navigation
        title = "Géolocalisation"
        
        // fait de la vue le délégué de locationMananger afin d'utiliser la localisation
        // demande l'autorisation si besoin
        // fait de la vue le délégué de mapView afin d'utiliser la carte
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        // instanciation du manager de requêtes
        let configurationOSM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationOSM.timeoutIntervalForRequest = 10 // secondes
        self.managerOSM = Alamofire.Manager(configuration: configurationOSM)
        
        let configurationGM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationGM.timeoutIntervalForRequest = 10 // secondes
        self.managerGM = Alamofire.Manager(configuration: configurationGM)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.markers.removeAll(keepCapacity: false)
        self.emplacements.removeAll(keepCapacity: false)
        self.rayon = RayonRecherche(rawValue: 1)!
        self.markerFilledWithInfos = 0
        self.getEmplacements(locationManager.location.coordinate, radius: self.rayon)
    }
    
    /**
        Vérifie les résultats de la recherche et en initie une nouvelle s'il n'y a pas assez de résultats
        Si en revanche il y a assez de résultats, on peut préparer les données pour le traitement/affichage
    */
    func searchResultsController() {
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
                //getInformations(marker)
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
        
        let request = self.managerOSM!.request(DataProvider.OpenStreetMap.GetNodes(coordinate,radius))
        request.validate()
        request.responseSwiftyJSON { request, response, json, error in
            if error == nil {
                let elements = json["elements"].arrayValue

                    for place in elements {
                        var id: String? = place["id"].stringValue
                        var lat: String? = place["lat"].stringValue
                        var lon: String? = place["lon"].stringValue
                        var tim: String? = place["timestamp"].stringValue

                        var emplacement = Emplacement(id: id, lat: lat, lon: lon, tim: tim)
                        self.emplacements.append(emplacement)
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
    */
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        getInformations(marker as PlaceMarker)
        return false
    }
    
    /**
        Appelé si markerInfoWindow renvoie nil
        On load notre vue personnalisée et on affiche si disponible les informations
    */
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        
        let placeMarker = marker as PlaceMarker
        if let infoView = UIView.viewFromNibName("InfoMarkerWindow") as? InfoMarkerWindow {
            if (infoView.adresse.text == "" && placeMarker.place.adresse == nil) {
                infoView.lock()
            } else if infoView.adresse.text != placeMarker.place.adresse {
                infoView.unlock()
                infoView.adresse.text = placeMarker.place.adresse
                infoView.duration.text = placeMarker.place.duration
                infoView.distance.text = placeMarker.place.distance
            }
        
            return infoView
        } else {
            return nil
        }
    }
    
    /**
        Appelé dès que la fenêtre d'informations d'un marqueur est tappé
    */
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        println("window tapped")
    }
    
    /**
        Recherche des informations complémentaires entre deux lieux
    
        :param: place Le marqueur sélectionné
    
        On effectue une requête sur l'API de Google Maps afin de récupérer l'adresse du lieu de destination ainsi que la distance et le temps de parcours pour se rendre sur ce lieu, grâce à la position actuelle.
    
        La requête est effectuée de façon asynchrone grâce à une closure, avec un timeout de 10 secondes.
    */
    func getInformations(place: PlaceMarker) {
        if place.place.adresse == nil {
            let request = self.managerGM!.request(DataProvider.GoogleMaps.DistanceMatrix(self.locationManager.location.coordinate, place.position))
            request.validate()
            request.responseSwiftyJSON { request, response, json, error in
                if error == nil  {
                    var dataRecup = json
                    var status:String? = dataRecup["status"].stringValue
                    
                    if status == "OK" {
                        
                        var destination = dataRecup["destination_addresses"]
                        
                        if destination.isEmpty {
                            place.place.adresse = "Aucune adresse correspondante"
                        } else {
                            place.place.adresse = destination.arrayValue[0].stringValue
                        }
                        
                        var rows = dataRecup["rows"].arrayValue
                        
                        if !rows.isEmpty {
                            
                            let element = rows[0]["elements"].arrayValue
                            
                            let firstData = element[0]
                            
                            if firstData["status"].stringValue == "OK" {
                                
                                place.place.duration = firstData["duration"]["text"].stringValue
                                
                                place.place.distance = firstData["distance"]["text"].stringValue
                                
                            } else {
                                
                                place.place.duration = "Aucune donnée"
                                
                                place.place.distance = "Aucune donnée"
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
            }
        }
    }

}



