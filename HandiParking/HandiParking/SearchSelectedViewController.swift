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
    
    var streetViewButton: UIBarButtonItem!
    
    var itineraryButton: UIBarButtonItem!
    
    @IBOutlet weak var launchButtonText: UIButton!
    
    @IBAction func launchButtonAction(sender: AnyObject) {
        
        if let lat = self.place.lat {
            
            //launchsearch car on a les coordonnées
            
        } else {
            
            self.launchButtonText.enabled = false
            getCoordinate()
            
        }
    }
    
    /// lieu choisi
    var place = Lieu()
    
    /// gestionnaire des requêtes pour Google Maps
    var managerGM: Alamofire.Manager?
    
    var request: Alamofire.Request?

    override func viewDidLoad() {
        let configurationGM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationGM.timeoutIntervalForRequest = 10 // secondes
        self.managerGM = Alamofire.Manager(configuration: configurationGM)
        
        self.navigationItem.rightBarButtonItems = setButtons()
        
        if ServicesController().checkInternetConnection() {
        
            getCoordinate()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setButtons() -> NSArray {
        self.streetViewButton = UIBarButtonItem(image: UIImage(named: "toolbar_streetview"), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        streetViewButton.enabled = false
        self.itineraryButton = UIBarButtonItem(image: UIImage(named: "toolbar_itinerary"), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        itineraryButton.enabled = false
        var buttons: NSArray = [self.streetViewButton, self.itineraryButton]
        return buttons
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
                        
                        self.place.setCoordinate(lat, lon:lon)
                        
                        UIView.animateWithDuration(0.5, animations: {
                            self.launchButtonText.alpha = 0.0
                        }) { finished in
                                self.launchButtonText.setImage(UIImage(named: "toolbar_launch"), forState: .Normal)
                                self.launchButtonText.enabled = true
                                UIView.animateWithDuration(0.5, animations: {
                                    self.launchButtonText.alpha = 1.0
                                })
                        }
                        
                    } else {
                        
                        self.launchButtonText.enabled = true
                        AlertViewController().errorResponseGoogle()
                    }
                    
                } else {
                    
                    self.launchButtonText.enabled = true
                    AlertViewController().errorRequest()
                }
            }
        
    }

    
    
    
}
