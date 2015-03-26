//
//  SearchSelectedViewController.swift
//  HandiParking
//
//  Created by Gaël on 25/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class SearchSelectedViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIActionSheetDelegate {
    
    /// lien de sortie vers la carte
    @IBOutlet weak var mapView: GMSMapView!
    
    /// lieu choisi
    var place = Lieu()
    
    /// gestionnaire des requêtes pour Google Maps
    var managerGM: Alamofire.Manager?
    
    var request: Alamofire.Request?

    override func viewDidLoad() {
        let configurationGM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationGM.timeoutIntervalForRequest = 10 // secondes
        self.managerGM = Alamofire.Manager(configuration: configurationGM)
        var rightA = UIBarButtonItem(title: "11", style: .Plain, target: nil, action: nil)
        var rightB = UIBarButtonItem(title: "22", style: .Plain, target: nil, action: nil)
        var myButtonArray: NSArray = [rightA, rightB]
        self.navigationItem.rightBarButtonItems = myButtonArray
        println(place.description)
        getCoordinate()
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "test", style: .Plain, target: nil, action: nil)
    }
    
    func getCoordinate() {
            let request = self.managerGM!.request(DataProvider.GoogleMaps.PlaceDetails(self.place.placeid))
            request.validate()
            request.responseSwiftyJSON { request, response, json, error in
                if error == nil  {
                    var dataRecup = json
                    var status:String? = dataRecup["status"].stringValue
                    
                    var lat:String?
                    var lon:String?
                    
                    if status == "OK" {
                        
                        lat = dataRecup["result"]["geometry"]["location"]["lat"].stringValue
                        lon = dataRecup["result"]["geometry"]["location"]["lng"].stringValue
                        
                        println(lat)
                        println(lon)

                        
                    } else {

                        AlertViewController().errorResponseGoogle()
                    }
                    
                } else {

                    AlertViewController().errorRequest()
                }
            }
        
    }

    
    
    
}
