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
        SCLAlertView().showError(NSLocalizedString("NO_LOC_SERV",comment:"No location service"), subTitle:NSLocalizedString("NO_LOC_SERV_EXPL",comment:"No location service meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
            
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
        SCLAlertView().showError(NSLocalizedString("NO_WEB_CONNEC",comment:"No internet connection"), subTitle:NSLocalizedString("NO_WEB_CONNEC_EXPL",comment:"No internet connection meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
    /**
        Erreur - Accès Internet limité
    */
    internal func internetConnectionLimited() {
        SCLAlertView().showWarning(NSLocalizedString("NO_WEB",comment:"No internet"), subTitle: NSLocalizedString("NO_WEB_EXPL",comment:"No internet meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
    /**
        Erreur - Autorisation d'utilisation de la localisation refusée
    */
    internal func locationAutho() {
        SCLAlertView().showError(NSLocalizedString("LOC_AUTH",comment:"Location authorization"), subTitle:NSLocalizedString("LOC_AUTH_EXPL",comment:"Location authorization meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
    /**
        Erreur - Pas d'emplacements trouvés lors de la recherche OSM
    */
    internal func noPlacesFound(radius: SearchRadius) {
        SCLAlertView().showWarning(NSLocalizedString("NO_SPACE_FOUND",comment:"No space found"), subTitle:NSString(format: NSLocalizedString("NO_SPACE_FOUND_EXPL", comment: "No space found meaning"), String((radius.value)/1000)), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
        
    }
    
    /**
        Erreur - Erreur lors de la réponse de la requête (timeout ou autre)
    */
    internal func errorRequest() {
        SCLAlertView().showError(NSLocalizedString("OVER_SERV",comment:"Overloaded servers"), subTitle:NSLocalizedString("OVER_SERV_EXPL",comment:"Overloaded servers meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
    /**
        Erreur - La localisation n'a pas encore été récupérée
    */
    internal func locationWasNotGet() {
        SCLAlertView().showError(NSLocalizedString("LOC_NOT_DETER",comment:"Position not located"), subTitle:NSLocalizedString("LOC_NOT_DETER_EXPL",comment:"Position not located meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
    /**
        Erreur - Erreur dans la réponse de la requête Google
    */
    internal func errorResponseGoogle() {
        SCLAlertView().showError(NSLocalizedString("GOOGLE_FUCK_UP",comment:"Error retrieving Google data"), subTitle:NSLocalizedString("GOOGLE_FUCK_UP_EXPL",comment:"Error retrieving Google data meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
    /**
        Erreur - L'application n'est plus installée
    */
    internal func appsDeleted(appName: String) {
        SCLAlertView().showError(NSLocalizedString("APP_NOT_INST",comment:"Application not install"), subTitle:NSString(format: NSLocalizedString("APP_NOT_INST_EXPL", comment: "Application not install meaning"), appName), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
    /**
        Erreur - StreetView non disponible
    */
    internal func errorStreetView() {
        SCLAlertView().showError(NSLocalizedString("STREETVIEW_NA",comment:"StreetView not available"), subTitle:NSLocalizedString("STREETVIEW_NA_EXPL",comment:"StreetView not available meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
    /**
        Erreur - Connexion trop faible pour StreetView
    */
    internal func errorBadConnection() {
        SCLAlertView().showError(NSLocalizedString("WEB_CONNEC_WEAK",comment:"Internet connection to weak"), subTitle:NSLocalizedString("WEB_CONNEC_WEAEXPL",comment:"Internet connection to weak meaning"), closeButtonTitle:NSLocalizedString("OK",comment:"OK"))
    }
    
}