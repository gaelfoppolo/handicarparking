//
//  ServicesController.swift
//  HandiParking
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
    
        :returns: InternetIsWorking la connexion Internet est fonctionnelle
    */
    private func checkInternetConnection() -> Bool {
        
        // le service est activé par défaut
        var InternetIsWorking: Bool = true
        
        if !IJReachability.isConnectedToNetwork() {
            
            SCLAlertView().showError("😁", subTitle:"Il semblerait que votre accès Internet soit désactivé. Veuillez le réactiver si vous souhaitez utiliser pleinement l'application", closeButtonTitle:"OK")
            
            InternetIsWorking = !InternetIsWorking
            
        } else if IJReachability.isConnectedToNetwork() && IJReachability.isConnectedToNetworkOfType().description == "NotConnected" {
            
            SCLAlertView().showWarning("Connexion inexistante..", subTitle: "Il semblerait que votre accès Internet soit actif mais limité. Essayez de trouver une meilleure connexion pour pouvoir utiliser pleinement l'application", closeButtonTitle:"OK")
            
            InternetIsWorking = !InternetIsWorking
        }
        
        return InternetIsWorking
    }
    
    /**
        Vérifie l'activation du service de localisation
    
        :returns: LocationIsEnable le service de localisation est activé
    */
    private func checkLocationService() -> Bool {
        
        // le service est activé par défaut
        var LocationIsEnable: Bool = true
        
        if !CLLocationManager.locationServicesEnabled() {
            
            SCLAlertView().showError("😁", subTitle:"Il semblerait que le service de localisation ne soit pas activé ! Allez les modifier dans les Réglages !", closeButtonTitle:"OK")
            
            LocationIsEnable = !LocationIsEnable
            
        }
        
        return LocationIsEnable
        
    }
    
    /**
        Vérifie l'activation des services
    
        :returns: Bool tous les services sont opérationnels
    */
    internal func servicesAreWorking() -> Bool {
        
        if checkInternetConnection() {
            if checkLocationService() {
                return true
            }
        }
        return false
    }

}