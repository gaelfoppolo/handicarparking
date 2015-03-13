//
//  Emplacement.swift
//  HandiParking
//
//  Created by Gaël on 12/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

class Emplacement {
    
    var id: String
    var lat: String
    var lon: String
    
    init(id: String?, lat: String?, lon: String?) {
        self.id = id ?? ""
        self.lat = lat ?? ""
        self.lon = lon ?? ""
    }
}