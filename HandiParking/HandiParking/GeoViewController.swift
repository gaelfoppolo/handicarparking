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
import AlamofireSwiftyJSON

class GeoViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    
    var rayon: RayonRecherche = RayonRecherche(rawValue: 1)!
    
    var emplacements = [Emplacement]()
    
    var searchByMyLocationButton: Bool = false
    
    var managerOSM: Alamofire.Manager?
    
    // pour les appels aux services Google Maps
    let cleAPIGoogleMapsiOS = "AIzaSyBCsJT2QsSUcnnkb8Oq6wDuRUshrXmYb4Y"
    
    // on instantie au démarrage
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
        
        if testServices() {
            locationManager.startUpdatingLocation()
        }
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10 // secondes
        
        self.managerOSM = Alamofire.Manager(configuration: configuration)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // appelé quand l'autorisation localisation est changée
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            
            // on affiche le bouton My Location dans la vue
            mapView.settings.myLocationButton = true
            mapView.myLocationEnabled = true
            
        } else if testServices() {
            switch status {
            case .Denied:
                SCLAlertView().showError("Hum... 😁", subTitle:"Il semblerait que l'application n'est pas le droit d'utiliser vos données de géolocalisation !", closeButtonTitle:"OK")
            default:
                break
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            
            if !searchByMyLocationButton && testServices() {
                updateMapCameraOnUserLocation()
                SwiftSpinner.show("Recherche en cours...")
                launchRecherche()
            }
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        self.searchByMyLocationButton = true
        locationManager.startUpdatingLocation()
        if testServices() {
            updateMapCameraOnUserLocation()
            SwiftSpinner.show("Recherche en cours...")
            launchRecherche()
            return false
        }
        return false
        //true pour le comportement par défaut de la fonction
        //false pour faire ce que l'on veut
    }
    
    func updateMapCameraOnUserLocation() {
        var camera = GMSCameraPosition(target: locationManager.location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animateToCameraPosition(camera)
    }
    
    func launchRecherche() {
        //ajouter un spinner
        self.emplacements.removeAll(keepCapacity: false)
        self.rayon = RayonRecherche(rawValue: 1)!
        self.getEmplacements(locationManager.location.coordinate, radius: self.rayon)
    }
    
    func reloadData() {
        if(self.emplacements.count > 10) {
            SwiftSpinner.hide()
            displayMarker()
            println("on a assez d'emplacements")
            println("on a : \(self.emplacements.count)")
            println("avec un rayon de \(self.rayon.valeur)")
            self.searchByMyLocationButton = false
        } else if let newRayon = RayonRecherche(rawValue: self.rayon.rawValue+1){
            self.emplacements.removeAll(keepCapacity: false)
            self.rayon = newRayon
            self.getEmplacements(locationManager.location.coordinate, radius: self.rayon)
        } else {
            SwiftSpinner.hide()
            displayMarker()
            println("on ne sait pas si assez d'emplacements")
            println("on a : \(self.emplacements.count)")
            println("avec un rayon de \(self.rayon.valeur)")
            self.searchByMyLocationButton = false
        }
    }
    
    func displayMarker() {
        var firstLocation: CLLocationCoordinate2D
        //((GMSMarker *)markers.firstObject).position;
        var bounds = GMSCoordinateBounds(coordinate: self.locationManager.location.coordinate, coordinate: self.locationManager.location.coordinate)
        for place: Emplacement in self.emplacements {
            let marker = PlaceMarker(place: place)
            println(marker.position)
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = self.mapView
        }
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 50.0))
        //var zoom = GMSCameraPosition.zoomAtCoordinate(locationManager.location.coordinate, forMeters:CLLocationDistance(self.rayon.valeur), perPoints:500)
        //var camera = GMSCameraPosition(target: locationManager.location.coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
        //mapView.animateToCameraPosition(camera)
        
    }
    
    func getEmplacements(coordinate: CLLocationCoordinate2D, radius: RayonRecherche) {
        
        let request = self.managerOSM!.request(DataProvider.OpenStreetMap.GetNode(coordinate,radius))
        request.validate()
        request.responseSwiftyJSON { request, response, json, error in
            if error == nil {
                let elements = json["elements"].arrayValue

                    for place in elements {
                        var id: String? = place["id"].stringValue
                        var lat: String? = place["lat"].stringValue
                        var lon: String? = place["lon"].stringValue
                        var emplacement = Emplacement(id: id, lat: lat, lon: lon)
                        self.emplacements.append(emplacement)
                    }
            
                self.reloadData()
            } else {
                SwiftSpinner.hide()
                SCLAlertView().showError("Hum... 😁", subTitle:"Il semblerait que les serveurs soient surchargés ou que votre connexion Internet soit trop faible... Réesayez dans quelques instants !", closeButtonTitle:"OK")
            }
        }
        
    }

    
    // vérification de la présence d'une connexion internet, full ou limitée
    func checkInternetConnection() -> Bool {
        if !IJReachability.isConnectedToNetwork() {
            
            SCLAlertView().showError("Hum... 😁", subTitle:"Il semblerait que votre accès Internet soit désactivé. Veuillez le réactiver si vous souhaitez utiliser pleinement l'application", closeButtonTitle:"OK")
            
            return false
            
        } else if IJReachability.isConnectedToNetwork() && IJReachability.isConnectedToNetworkOfType().description == "NotConnected" {
            
            SCLAlertView().showWarning("Connexion inexistante..", subTitle: "Il semblerait que votre accès Internet soit actif mais limité. Essayez de trouver une meilleure connexion pour pouvoir utiliser pleinement l'application", closeButtonTitle:"OK")
            
            return false
        }
        
        return true
    }
    
    func checkLocationService() -> Bool {
        
        if !CLLocationManager.locationServicesEnabled() {
            
            SCLAlertView().showError("Hum... 😁", subTitle:"Il semblerait que le service de localisation ne soit pas activé ! Allez les modifier dans les Réglages !", closeButtonTitle:"OK")
            
            return false
            
        } else {
            return true
        }
    
    }
    
    func testServices() -> Bool {
        if checkInternetConnection() {
            if checkLocationService() {
                return true
            }
        }
        return false
    }


}



