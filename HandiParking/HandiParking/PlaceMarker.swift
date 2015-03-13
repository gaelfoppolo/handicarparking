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
        
        position = CLLocationCoordinate2DMake(NSString(string: place.lat).doubleValue, NSString(string: place.lon).doubleValue)
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
    }
}
