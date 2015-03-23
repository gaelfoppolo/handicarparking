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
                urlsheme = "waze://?"
            case "Plans":
                urlsheme = "http://maps.apple.com/?"
            default:
                break
        }
        return urlsheme
    }
    
    func generateURLScheme(appName:String, location: CLLocationCoordinate2D, marker: PlaceMarker) -> String {
        
        let baseURL = getBaseURLScheme(appName)
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