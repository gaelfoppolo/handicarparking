//
//  Place.swift
//  HandiCarParking
//
//  Created by Gaël on 24/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

/// Lieu choisi lors de la recherche par nom

import Foundation

class Place: NSObject, Printable {
    
    //MARK: Attributs
    
    let placeid: String
    let name: String
    
    //MARK: Initialisateur
    
    init(placeid: String?, name: String?) {
        self.placeid = placeid ?? ""
        self.name = name ?? ""
    }
    
    override init() {
        self.placeid = ""
        self.name = ""
        super.init()
    }
}