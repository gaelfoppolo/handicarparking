//
//  DataProvider.swift
//  HandiCarParking
//
//  Created by Gaël Foppolo on 3/12/15.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Alamofire

/// DataProvider créant une instance appropriée d'URLString pour les appels aux différentes API ("extension" d'Alamofire).

/**
    Chaque énumération se conforme à URLRequestConvertible, un protocole définit dans Alamofire et propose un ou plusieurs points de sorties ou cas, chaque étant un appel différent, avec ses propres paramètres 
*/

struct DataProvider {

    enum OpenStreetMap: URLRequestConvertible {
        
        /// la liste des seveurs OSM
        static let listOSMServers = [
            "http://overpass.osm.rambler.ru/cgi/interpreter",
            "http://overpass-api.de/api/interpreter",
            "http://api.openstreetmap.fr/oapi/interpreter"
        ]
        
        /// le numéro du serveur utilisé actuellement dans la recherche (correspond à une case de listOSMServers)
        static var actualServer: Int = 0
        
        /// le nombre de serveur utilisés lors de la recherche en cours, inférieur à listOSMServers-1
        static var nbServerUsed: Int = 0
        
        /// l'URL de base de l'API d'OSM (computed)
        static var baseURLString : String {
            return listOSMServers[actualServer]
        }
        
        /// nombre minimum de résultats à récupérer
        static let minimumResults: Int = 10
        
        /// nombre maximum de résultats à récupérer
        static let maximumResults: Int = 200
        
        /**
            GetNodes : récupérer les nodes
            
            :param: les coordonnées (latitude, longitude)

            :param: le rayon de recherche (en mètres)
        
        */
        case GetNodes(CLLocationCoordinate2D, SearchRadius)
        
        var URLRequest: NSURLRequest {
            let (parameters: [String: AnyObject]) = {
                switch self {
                    
                case .GetNodes (let coordinate, let rayon):
                    let params = ["data": "[out:json];(node(around:\(rayon.value),\(coordinate.latitude),\(coordinate.longitude))['amenity'~'parking|parking_space']['capacity:disabled'~'yes|[0-9]*[0-9]'];node(around:\(rayon.value),\(coordinate.latitude),\(coordinate.longitude))['amenity'~'parking|parking_space']['wheelchair'='yes'];node(around:\(rayon.value),\(coordinate.latitude),\(coordinate.longitude))['amenity'='parking_space']['parking_space'='disable'];);out meta \(OpenStreetMap.maximumResults);"]
                    return (params)
                }
            }()
            
            let URL = NSURL(string: OpenStreetMap.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!)
            let encoding = Alamofire.ParameterEncoding.URL
            
            // Exemple illustrant la logique :
            // = baseURLString  +  params
            // http://overpass-api.de/api/interpreter  +   ?data=[out:json];(node(around:5000,43.609416,3.869641)['amenity'~'parking|parking_space']['capacity:disabled'~'yes|[0-9]*[0-9]'];node(around:5000,43.609416,3.869641)['amenity'~'parking|parking_space']['wheelchair'='yes'];node(around:5000,43.609416,3.869641)['amenity'='parking_space']['parking_space'='disabled'];);out meta 20;
            // URL: http://overpass-api.de/api/interpreter?data=[out:json];(node(around:5000,43.609416,3.869641)['amenity'~'parking|parking_space']['capacity:disabled'~'yes|[0-9]*[0-9]'];node(around:5000,43.609416,3.869641)['amenity'~'parking|parking_space']['wheelchair'='yes'];node(around:5000,43.609416,3.869641)['amenity'='parking_space']['parking_space'='disabled'];);out meta 20;
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
    
    enum GoogleMaps: URLRequestConvertible {
        
        // l'URL de base de l'API de Google Maps
        static let baseURLString = "https://maps.googleapis.com/maps/api"
        
        // la clé spécifique au bundle de cette application iOS
        static let apiKeyiOS = "AIzaSyDhySHTDSe2IOR8WTF4fmr1ISAo-HcIoGc"
        
        // la clé utiliser pour les appels aux services serveurs
        static let apiKeyServer = "AIzaSyB5wnwkYNT7azlLkIGDOcFAA3DrBo-Jneo"
        
        /**
            Autocomplete : récupérer les prédictions des lieux
        
            :param: le nom, code postal ou adresse du lieu
        
        */
        case Autocomplete(String)
        
        /**
            DistanceMatrix : distance et temps de parcours entre deux lieu
        
            :param: lieu d'origine (latitude, longitude)
        
            :param: lieu de destination (latitude, longitude)
        
        */
        case DistanceMatrix(CLLocationCoordinate2D, CLLocationCoordinate2D)
        
        /**
            Place Details : récupérer les détails d'un lieu
        
            :param: l'ID unique généré par Google pour identifier un lieu
        
        */
        case PlaceDetails(String)
        
        var URLRequest: NSURLRequest {
            let (path: String, parameters: [String: AnyObject]) = {
                switch self {
                    
                case .Autocomplete (let searchString):
                    let path = "/place/autocomplete/json"
                    let params = ["input": searchString, "key": GoogleMaps.apiKeyServer]
                    return (path, params)
                case .DistanceMatrix (let origins, let destinations):
                    let path = "/distancematrix/json"
                    let params = ["origins": "\(origins.latitude),\(origins.longitude)", "destinations": "\(destinations.latitude),\(destinations.longitude)", "key": GoogleMaps.apiKeyServer]
                    return (path, params)
                case .PlaceDetails (let id_place):
                    let path = "/place/details/json"
                    let params = ["placeid": id_place, "key": GoogleMaps.apiKeyServer]
                    return (path, params)
                }
            }()
            
            let URL = NSURL(string: GoogleMaps.baseURLString)
            let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            
            // // Exemple illustrant la logique pour DistanceMatrix :
            // = baseURLString  +  path  +  encoded parameters
            // https://maps.googleapis.com/maps/api  +  /distancematrix/json  +  ?origins=44.3526603,2.5690328&destinations=44.5204289,2.762072&key=AIzaSyB5wnwkYNT7azlLkIGDOcFAA3DrBo-Jneo
            // URL: https://maps.googleapis.com/maps/api/distancematrix/json?origins=44.3526603,2.5690328&destinations=44.5204289,2.762072&key=AIzaSyB5wnwkYNT7azlLkIGDOcFAA3DrBo-Jneo
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }

}