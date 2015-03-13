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
            
            if testServices() {
                locationManager.startUpdatingLocation()
            }
            
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
            //stop spinner
            //call la suite
            println("on a assez d'emplacements")
            println("on a : \(self.emplacements.count)")
            println("avec un rayon de \(self.rayon.valeur)")
            self.searchByMyLocationButton = false
        } else if let newRayon = RayonRecherche(rawValue: self.rayon.rawValue+1){
            self.emplacements.removeAll(keepCapacity: false)
            self.rayon = newRayon
            self.getEmplacements(locationManager.location.coordinate, radius: self.rayon)
        } else {
            //stop spinner
            println("on ne sait pas si assez d'emplacements")
            println("on a : \(self.emplacements.count)")
            println("avec un rayon de \(self.rayon.valeur)")
            self.searchByMyLocationButton = false
        }
    }
    
    func getEmplacements(coordinate: CLLocationCoordinate2D, radius: RayonRecherche) {
        
        let request = Alamofire.request(DataProvider.OpenStreetMap.GetNode(coordinate,radius))
        request.responseSwiftyJSON { request, response, json, error in
            
            let elements = json["elements"].arrayValue

                for place in elements {
                    var id: String? = place["id"].stringValue
                    var lat: String? = place["lat"].stringValue
                    var lon: String? = place["lon"].stringValue
                    var emplacement = Emplacement(id: id, lat: lat, lon: lon)
                    self.emplacements.append(emplacement)
                }
            
            self.reloadData()
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



