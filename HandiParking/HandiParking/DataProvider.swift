//
//  GoogleDataProvider.swift
//  HandiParking
//
//  Created by Gaël Foppolo on 3/12/15.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Alamofire

// Structure étendant le framework Alamofire et permettant d'effectuer des appels plus simplement

struct DataProvider {

    enum OpenStreetMap: URLRequestConvertible {
        
        static let baseURLString = "http://overpass-api.de/api/interpreter"
        
        case GetNode(CLLocationCoordinate2D, RayonRecherche)
        
        var URLRequest: NSURLRequest {
            let (parameters: [String: AnyObject]) = {
                switch self {
                    
                case .GetNode (let coordinate, let rayon):
                    let params = ["data": "[out:json];(node(around:\(rayon.valeur),\(coordinate.latitude),\(coordinate.longitude))['amenity'~'parking|parking_space']['capacity:disabled'~'yes|[0-9]*[0-9]'];node(around:\(rayon.valeur),\(coordinate.latitude),\(coordinate.longitude))['amenity'~'parking|parking_space']['wheelchair'='yes'];node(around:\(rayon.valeur),\(coordinate.latitude),\(coordinate.longitude))['amenity'='parking_space']['parking_space'='disable'];);out 20;"]
                    return (params)
                }
                }()
            
            let URL = NSURL(string: OpenStreetMap.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!)
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
    
    enum GoogleMaps: URLRequestConvertible {
        
        static let baseURLString = "https://maps.googleapis.com/maps/api"
        static let apiKey = "AIzaSyB5wnwkYNT7azlLkIGDOcFAA3DrBo-Jneo"
        
        case Autocomplete(String)
        
        var URLRequest: NSURLRequest {
            let (path: String, parameters: [String: AnyObject]) = {
                switch self {
                    
                case .Autocomplete (let searchString):
                    let path = "/place/autocomplete/json"
                    let params = ["input": searchString, "key": GoogleMaps.apiKey]
                    return (path, params)
                }
                }()
            
            let URL = NSURL(string: OpenStreetMap.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }

}
