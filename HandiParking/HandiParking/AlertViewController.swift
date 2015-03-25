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
        SCLAlertView().showError("😁", subTitle:"Il semblerait que le service de localisation ne soit pas activé ! Allez dans Réglages > Confidentialité > Service de localisation pour l'activer!", closeButtonTitle:"OK")
            
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
        SCLAlertView().showError("😁", subTitle:"Il semblerait que votre accès Internet soit désactivé. Veuillez le réactiver si vous souhaitez utiliser pleinement l'application", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Accès Internet limité
    */
    internal func internetConnectionLimited() {
        SCLAlertView().showWarning("Connexion inexistante..", subTitle: "Il semblerait que votre accès Internet soit actif mais limité. Essayez de trouver une meilleure connexion pour pouvoir utiliser pleinement l'application", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Autorisation d'utilisation de la localisation refusée
    */
    internal func locationAutho() {
        SCLAlertView().showError("😁", subTitle:"Il semblerait que l'application n'est pas le droit d'utiliser vos données de géolocalisation !", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Pas d'emplacements trouvés lors de la recherche OSM
    */
    internal func noPlacesFound() {
        SCLAlertView().showError("😁", subTitle:"Il semblerait qu'aucun emplacement n'est été trouvé dans un rayon de \((RayonRecherche.rayon4.valeur)/1000) kilomètres... C'est fortuit !", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Erreur lors de la réponse de la requête (timeout ou autre)
    */
    internal func errorRequest() {
        SCLAlertView().showError("😁", subTitle:"Il semblerait que les serveurs soient surchargés ou que votre connexion Internet soit trop faible... Réesayez dans quelques instants !", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - La localisation n'a pas encore été récupérée
    */
    internal func locationWasNotGet() {
        SCLAlertView().showError("😁", subTitle:"Il semblerait que votre position n'est pas pu être déterminée ! Réesayez dans quelques instants !", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - Erreur dans la réponse de la requête Google
    */
    internal func errorResponseGoogle() {
        SCLAlertView().showError("😁", subTitle:"Il semblerait qu'il y ait un problème lors de la récupération des données ! Si ce problème persiste, contactez-nous !", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - L'application n'est plus installée
    */
    internal func appsDeleted(appName: String) {
        SCLAlertView().showError("😁", subTitle:"Il semblerait que \(appName) n'est plus installée ! Réinstallez-la afin de pouvoir à nouveau l'utiliser !", closeButtonTitle:"OK")
    }
    
    /**
        Erreur - StreetView non disponible
    */
    internal func errorStreetView() {
        SCLAlertView().showError("😁", subTitle:"Il semblerait que StreetView ne soit pas disponible pour ce lieu !", closeButtonTitle:"OK")
    }
    
    /**
    Erreur - Connexion trop faible pour StreetView
    */
    internal func errorBadConnection() {
        SCLAlertView().showError("😁", subTitle:"Il semblerait que votre connexion Internet soit trop faible pour afficher StreetView...", closeButtonTitle:"OK")
    }
    
}