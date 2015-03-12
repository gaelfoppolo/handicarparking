//
//  GeoViewController.swift
//  HandiParking
//
//  Created by Gaël on 10/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import CoreLocation

class GeoViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    
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
            
            updateMapCameraOnUserLocation()
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        //println(testServices())
        if testServices() {
            locationManager.startUpdatingLocation()
            updateMapCameraOnUserLocation()
            locationManager.stopUpdatingLocation()
        }
        return false
        //true pour le comportement par défaut de la fonction
        //false pour faire ce que l'on veut
    }
    
    func updateMapCameraOnUserLocation() {
        var camera = GMSCameraPosition(target: locationManager.location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animateToCameraPosition(camera)
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



