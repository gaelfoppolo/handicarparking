//
//  MapsAppsData.swift
//  HandiParking
//
//  Created by Gaël on 23/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Foundation

struct MapsAppsData {
    
    private let listAppsMaps = [
        "Plans":"http://maps.apple.com/?",
        "Google Maps":"comgooglemaps://?",
        "Waze":"waze://?"
    ]
    
    func generateActionSheet() -> UIActionSheet {
        var sheet: UIActionSheet = UIActionSheet()
        let title: String = "Sélectionnez l'application qui va prendre en charge votre itinéraire"
        sheet.title = title
        sheet.addButtonWithTitle("Annuler")
        sheet.cancelButtonIndex = 0
        //sheet.addButtonWithTitle("Plans")
        
        var installApps = MapsAppsData().getListOfInstalledMapsApps()
        
        for (appName,urlscheme) in installApps {
            sheet.addButtonWithTitle(appName)
        }
        
        return sheet
    }
    
    func getListOfInstalledMapsApps() -> [String:String] {
        var listAppsInstall = [String:String]()
        for (appName,urlscheme) in listAppsMaps {
            if isInstalled(appName) {
                listAppsInstall[appName] = urlscheme
            }
        }
        return listAppsInstall
    }
    
    func isInstalled(appName: String) -> Bool {
        var urlsheme = listAppsMaps[appName]!
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: urlsheme)!)
    }
    
    func generateURLScheme(appName:String, location: CLLocationCoordinate2D, marker: PlaceMarker) -> String {
        
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