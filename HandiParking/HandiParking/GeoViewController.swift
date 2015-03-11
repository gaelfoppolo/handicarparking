//
//  GeoViewController.swift
//  HandiParking
//
//  Created by Gaël on 10/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import CoreLocation

class GeoViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set le titre dans la barre de navigation
        title = "Géolocalisation"
        self.locationManager.delegate = self;
        
        locationManager.requestWhenInUseAuthorization()
        
        checkServices()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func checkServices() {
        // check si internet connexion
        // check si service localisation
        // check si localisation ok
        
        if checkInternetConnection() {
            if checkLocationService() {
                    locationManager.startUpdatingLocation()
                
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .Restricted, .Denied:
            SCLAlertView().showError("Hum... 😁", subTitle:"Il semblerait que l'application n'est pas le droit d'utiliser vos données de géolocalisation !", closeButtonTitle:"OK")
        default:
            break
        }
        
        if status == .AuthorizedWhenInUse {
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            
            if checkInternetConnection() {
                if checkLocationService() {
                        locationManager.startUpdatingLocation()
                }
            }
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {

            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

            locationManager.stopUpdatingLocation()
        }
    }


}



