//
//  RayonRecherche.swift
//  HandiParking
//
//  Created by Gaël on 13/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Foundation

/// Rayon (en mètres) lors de la recherche des emplacements avec OpenStreetMap

enum RayonRecherche: Int {
    
    /**  
        Quatre rayons (mètres) : 
        - 500m
        - 1km
        - 10km
        - 50km  
    */
    case rayon1 = 1, rayon2, rayon3, rayon4
    
    var valeur : Int {
        switch self {
            case .rayon1: return 500;
            case .rayon2: return 1000;
            case .rayon3: return 10000;
            case .rayon4: return 50000;
        }
    }
}