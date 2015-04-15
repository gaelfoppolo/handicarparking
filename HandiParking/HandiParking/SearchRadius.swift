//
//  SearchRadius.swift
//  HandiCarParking
//
//  Created by Gaël on 13/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Foundation

/// Rayon (en mètres) lors de la recherche des emplacements avec OpenStreetMap

enum SearchRadius: Int {
    
    /**  
        Quatre rayons (mètres) : 
        - 500m
        - 1km
        - 5km
        - 10km
        - 25km  
    */
    case radius1 = 1, radius2, radius3, radius4, radius5
    
    /// retourne la valeur (en m) du rayon choisi
    var value : Int {
        switch self {
            case .radius1: return 500;
            case .radius2: return 1000;
            case .radius3: return 5000
            case .radius4: return 10000;
            case .radius5: return 25000;
        }
    }
}