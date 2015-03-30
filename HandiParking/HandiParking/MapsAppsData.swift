//
//  MapsAppsData.swift
//  HandiParking
//
//  Created by Gaël on 23/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

/// Gére les données avec lesquelles appeler les applications de navigation tierce

struct MapsAppsData {
    
    // MARK: Attributs
    
    /// dictionnaire des applications de navigation tierce prise en charge, identifié par leur nom (clé) et avec l'URL scheme nécessaire pour effectuer l'appel (valeur)
    private let listAppsMaps = [
        "Plans":"http://maps.apple.com/?",
        "Google Maps":"comgooglemaps://?",
        "Waze":"waze://?"
    ]
    
    // MARK: Fonctions
    
    /**
        Génère l'action sheet à afficher, seules les applications tierce installées sur l'appareil sont affichées
    
        :returns: action sheet des applications de navigation tierce
    */
    func generateActionSheet() -> UIActionSheet {
        var sheet: UIActionSheet = UIActionSheet()
        let title: String = "Sélectionnez l'application qui va prendre en charge votre itinéraire"
        sheet.title = title
        sheet.addButtonWithTitle("Annuler")
        sheet.cancelButtonIndex = 0
        
        var installApps = MapsAppsData().getListOfInstalledMapsApps()
        
        for (appName,urlscheme) in installApps {
            sheet.addButtonWithTitle(appName)
        }
        
        return sheet
    }
    /**
        Génére la liste (dictionnaire) des applications installées
    
        :returns: dictionnaire des applications installées
    */
    func getListOfInstalledMapsApps() -> [String:String] {
        var listAppsInstall = [String:String]()
        for (appName,urlscheme) in listAppsMaps {
            if isInstalled(appName) {
                listAppsInstall[appName] = urlscheme
            }
        }
        return listAppsInstall
    }
    /**
        Détermine si une application est installée sur l'appareil
    
        :param: appName Le nom de l'application
    
        :returns: l'application est installée ou non
    */
    func isInstalled(appName: String) -> Bool {
        var urlscheme = listAppsMaps[appName]!
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: urlscheme)!)
    }
    /**
        Génère l'URL Scheme complet permettant de lancer l'application tierce en mode navigation
    
        :param: appName Le nom de l'application à qui on doit générer l'URL Scheme
        :param: location Le point de départ
        :param: marker Le point d'arrivée
    
        :returns: l'URL Scheme générée prête à être utilisée
    */
    func generateURLScheme(appName:String, location: CLLocationCoordinate2D, marker: PlaceMarker) -> NSString {
        
        let baseURL = listAppsMaps[appName]!
        var parameters: String?
        
        switch appName {
            case "Plans","Google Maps":
                var source: String = "\(location.latitude),\(location.longitude)"
                var destination: String = "\(marker.place.latitude),\(marker.place.longitude)"
                
                parameters = "saddr=\(source)&daddr=\(destination)"
            case "Waze":
                var latitude: String = marker.place.latitude
                var longitude: String = marker.place.longitude
                
                parameters = "ll=\(latitude),\(longitude)&navigate=yes"
        default:
            break
        }
        
        return baseURL+parameters!
    }
}