//
//  AlertViewController.swift
//  HandiParking
//
//  Created by Gaël on 16/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

/// Structure d'alertes personnalisées (qui permettra une internationalisation et un réutilisation)

struct AlertViewController {
    
    /**
        Erreur - Service de localisation désactivé
    */
    internal func locationServiceError() {
        SCLAlertView().showError("No location service", subTitle:"It looks like the location service is not enabled! Go in Settings > Privacy > Location to turn it on!", closeButtonTitle:"OK")
            
            //let iosVersion: Double = (UIDevice.currentDevice().systemVersion as NSString).doubleValue
            
            /*if iosVersion < 8.0 {
                
                UIApplication.sharedApplication().openURL(NSURL(fileURLWithPath: "prefs:root=LOCATION_SERVICES")!)
                
            } else {
                
                UIApplication.sharedApplication().openURL(NSURL(fileURLWithPath: UIApplicationOpenSettingsURLString)!)
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
            }*/

    }
    
    /**
        Erreur - Accès Internet désactivé
    */
    internal func internetConnectionDisabled() {
        SCLAlertView().showError("No internet connection", subTitle:"It looks like your Internet access is disabled. Please re-enable it if you want to fully use the application.", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Accès Internet limité
    */
    internal func internetConnectionLimited() {
        SCLAlertView().showWarning("No internet", subTitle: "It looks like your Internet connection is active but limited. Try to find a better connection to fully use the application.", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Autorisation d'utilisation de la localisation refusée
    */
    internal func locationAutho() {
        SCLAlertView().showError("Location authorization", subTitle:"It looks like the application is not allowed to use your location data!", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Pas d'emplacements trouvés lors de la recherche OSM
    */
    internal func noPlacesFound(radius: SearchRadius) {
        SCLAlertView().showWarning("No parking space found", subTitle:"It looks like no parking space has been found within a radius of \((radius.value)/1000) kilometers... 😁", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Erreur lors de la réponse de la requête (timeout ou autre)
    */
    internal func errorRequest() {
        SCLAlertView().showError("Overloaded servers", subTitle:"It looks like all servers are overloaded at the moment or your internet connection is too weak... Please try again in a few moments!", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - La localisation n'a pas encore été récupérée
    */
    internal func locationWasNotGet() {
        SCLAlertView().showError("Position not determined", subTitle:"It look like your position could not be determined! Please try again in a few moments!", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Erreur dans la réponse de la requête Google
    */
    internal func errorResponseGoogle() {
        SCLAlertView().showError("Error retrieving data", subTitle:"It looks like there was a problem while retrieving data! Please try again in a few moments and if this problem persists, please contact us!", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - L'application n'est plus installée
    */
    internal func appsDeleted(appName: String) {
        SCLAlertView().showError("Application not installed", subTitle:"It looks like \(appName) is no longer installed! Reinstall it in order to use it again!", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - StreetView non disponible
    */
    internal func errorStreetView() {
        SCLAlertView().showError("StreetView not available", subTitle:"It looks like StreetView is not available for this location!", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Connexion trop faible pour StreetView
    */
    internal func errorBadConnection() {
        SCLAlertView().showError("Internet connection too weak", subTitle:"It looks like you internet connection is too weak to display StreetView...", closeButtonTitle:"OK")
    }
    
}