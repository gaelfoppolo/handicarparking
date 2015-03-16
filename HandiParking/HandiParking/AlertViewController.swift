//
//  AlertViewController.swift
//  HandiParking
//
//  Created by Gaël on 16/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//


class AlertViewController {
    
    internal func locationServiceError() {
        
        SCLAlertView().showError("😁", subTitle:"Il semblerait que le service de localisation ne soit pas activé ! Allez dans Réglages > Confidentialité > Service de localisation pour l'activer!", closeButtonTitle:"OK")
            
            //let iosVersion: Double = (UIDevice.currentDevice().systemVersion as NSString).doubleValue
            
            /*if iosVersion < 8.0 {
                
                UIApplication.sharedApplication().openURL(NSURL(fileURLWithPath: "prefs:root=LOCATION_SERVICES")!)
                
            } else {
                
                UIApplication.sharedApplication().openURL(NSURL(fileURLWithPath: UIApplicationOpenSettingsURLString)!)
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
            }*/

    }
    
    internal func internetConnectionDisabled() {
        
        SCLAlertView().showError("😁", subTitle:"Il semblerait que votre accès Internet soit désactivé. Veuillez le réactiver si vous souhaitez utiliser pleinement l'application", closeButtonTitle:"OK")
        
    }
    
    internal func internetConnectionLimited() {
        
        SCLAlertView().showWarning("Connexion inexistante..", subTitle: "Il semblerait que votre accès Internet soit actif mais limité. Essayez de trouver une meilleure connexion pour pouvoir utiliser pleinement l'application", closeButtonTitle:"OK")
        
    }
    
    internal func locationStatusDenied() {
        
        SCLAlertView().showError("😁", subTitle:"Il semblerait que l'application n'est pas le droit d'utiliser vos données de géolocalisation !", closeButtonTitle:"OK")
        
    }
    
    internal func locationAutho() {
        
        SCLAlertView().showError("😁", subTitle:"Il semblerait que l'application n'est pas le droit d'utiliser vos données de géolocalisation !", closeButtonTitle:"OK")
        
    }
    
    internal func noPlacesFound() {
        
        SCLAlertView().showError("😁", subTitle:"Il semblerait qu'aucun emplacement n'est été trouvé dans un rayon de 50 kilomètres... C'est fortuit !", closeButtonTitle:"OK")
        
    }
    
    internal func errorRequestOSM() {
        
        SCLAlertView().showError("😁", subTitle:"Il semblerait que les serveurs soient surchargés ou que votre connexion Internet soit trop faible... Réesayez dans quelques instants !", closeButtonTitle:"OK")
        
    }
    
}