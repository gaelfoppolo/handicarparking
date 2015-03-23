//
//  MapsAppsData.swift
//  HandiParking
//
//  Created by Gaël on 23/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Foundation

struct MapsAppsData {
    
    private let listAppsMaps = ["Google Maps", "Waze"]
    
    func getListOfInstalledMapsApps() -> [String] {
        var listAppsInstall = [String]()
        for app in listAppsMaps {
            if isInstalled(app) {
                listAppsInstall.append(app)
            }
        }
        return listAppsInstall
    }
    
    func isInstalled(appName: String) -> Bool {
        var urlsheme: String = getBaseURLScheme(appName)
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: urlsheme)!)
    }
    
    func getBaseURLScheme(appName: String) -> String {
        var urlsheme:String = ""
        switch appName {
            case "Google Maps":
                urlsheme = "comgooglemaps://?"
            case "Waze":
                urlsheme = "waze://"
            case "Plans":
                urlsheme = "http://maps.apple.com/?"
            default:
                break
        }
        return urlsheme
    }
    
    func generateURLScheme(appName:String, location: CLLocationCoordinate2D, address: String?, marker: PlaceMarker) -> String {
        
        let baseURL = getBaseURLScheme(appName)
        var parameters: String?
        
        switch appName {
            case "Plans":
                var source: String = address!.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
                var destination: String = marker.place.adresse!.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                parameters = "saddr=\(source)&daddr=\(destination)"
            case "Google Maps":
                var source: String = "\(location.latitude),\(location.longitude)"
                var destination: String = "\(marker.place.latitude),\(marker.place.longitude)"
                
                parameters = "saddr=\(source)&daddr=\(destination)"
        default:
            break
        }
        
        return baseURL+parameters!
    }
}