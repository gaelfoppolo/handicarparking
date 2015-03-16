//
//  PlaceMarker.swift
//  HandiParking
//
//  Created by Gaël on 13/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit

class PlaceMarker: GMSMarker {

    let place: Emplacement

    init(place: Emplacement) {
        self.place = place
        super.init()
        
        position = CLLocationCoordinate2DMake(NSString(string: place.latitude).doubleValue, NSString(string: place.longitude).doubleValue)
        icon = UIImage(named: "marker")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
        title = place.id_node
    }
}
