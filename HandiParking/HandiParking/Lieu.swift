//
//  Lieu.swift
//  HandiParking
//
//  Created by Gaël on 24/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Foundation

class Lieu: NSObject, Printable {
    
    //MARK: Attributs
    
    let placeid: String
    let nom: String
    var lat: String?
    var lon: String?
    
    //MARK: description de l'objet
    
    override var description: String {
        return "ID : \(placeid) \nNom : \(nom) \n"
    }
    
    //MARK: Initialisateur
    
    init(placeid: String?, nom: String?) {
        self.placeid = placeid ?? ""
        self.nom = nom ?? ""
    }
    
    override init() {
        self.placeid = ""
        self.nom = ""
        super.init()
    }
    
    func setCoordinate(lat:String?, lon: String?) {
        self.lat = lat
        self.lon = lon
    }
    
    func generateMarker() -> GMSMarker {
        var marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2DMake(NSString(string: self.lat!).doubleValue, NSString(string: self.lon!).doubleValue)
        marker.icon = UIImage(named: "marker_place")
        marker.groundAnchor = CGPoint(x: 0.5, y: 1)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.title = self.nom
        
        return marker
    }
}