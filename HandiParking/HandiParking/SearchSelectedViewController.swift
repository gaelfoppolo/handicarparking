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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println(place.description)
    }
    
    
    
}
