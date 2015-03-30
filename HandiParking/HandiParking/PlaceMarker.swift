//
//  PlaceMarker.swift
//  HandiParking
//
//  Created by Gaël on 13/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit

/// Marqueur personnalisé héritant des propriétés du marqueur par défaut du framework Google Maps

class PlaceMarker: GMSMarker {
    
    // MARK: Attributs
    
    // emplacement contenant toutes informations additionnelles
    let place: ParkingSpace
    
    // MARK: Initialisateur
    
    /**
        Initialise un nouveau marqueur
        
        :param: place un emplacement
        
        :returns: Un marqueur contenant les informations de l'emplacement
    */
    init(place: ParkingSpace) {
        
        self.place = place
        super.init()
        
        position = CLLocationCoordinate2DMake(NSString(string: place.latitude).doubleValue, NSString(string: place.longitude).doubleValue)
        icon = UIImage(named: "marker")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
        
    }
    
}
