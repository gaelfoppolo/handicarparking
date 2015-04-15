//
//  ServicesController.swift
//  HandiCarParking
//
//  Created by Gaël on 16/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import CoreLocation

/// Contrôleur des services Internet et de localisation

class ServicesController {
    
    /**
        Vérifie la présence d'une connexion Internet fonctionnelle
    
        :returns: internetIsWorking la connexion Internet est fonctionnelle
    */
    internal func checkInternetConnection() -> Bool {
        
        // le service est activé par défaut
        var internetIsWorking: Bool = true
        
        if !IJReachability.isConnectedToNetwork() {

            AlertViewController().internetConnectionDisabled()
            
            internetIsWorking = !internetIsWorking
            
        } else if IJReachability.isConnectedToNetwork() && IJReachability.isConnectedToNetworkOfType().description == "NotConnected" {
            
            AlertViewController().internetConnectionLimited()
            
            internetIsWorking = !internetIsWorking
        }
        
        return internetIsWorking
    }
    
    /**
        Vérifie l'activation du service de localisation
    
        :returns: locationIsEnable le service de localisation est activé
    */
    private func checkLocationService() -> Bool {
        
        // le service est activé par défaut
        var locationIsEnable: Bool = true
        
        if !CLLocationManager.locationServicesEnabled() {
            
            AlertViewController().locationServiceError()
            
            locationIsEnable = !locationIsEnable
            
        }
        
        return locationIsEnable
        
    }
    
    /**
        Vérifie l'autorisation d'utilisation de la localisation
    
        :returns: Bool autorisation
    */
    private func checkAutho() -> Bool {
        
        let status = CLLocationManager.authorizationStatus()
        
        // l'autorisation est vraie
        var authoriIsOk: Bool = true

        switch status {
            case .Denied:
                authoriIsOk = !authoriIsOk
                AlertViewController().locationAutho()
            default:
                break
        }
     
        return authoriIsOk
    }
    
    /**
        Vérifie l'activation des services
    
        :returns: Bool tous les services sont opérationnels
    */
    internal func servicesAreWorking() -> Bool {
        
        if checkInternetConnection() {
            if checkLocationService() {
                if checkAutho() {
                    return true
                }
            }
        }
        return false
    }

}