//
//  Rayon.swift
//  HandiParking
//
//  Created by Gaël on 13/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Foundation

enum RayonRecherche: Int {
    case premier = 1, deuxieme, troisieme, quatrieme
    
    var valeur : Int {
        switch self {
        case .premier: return 500;
        case .deuxieme: return 1000;
        case .troisieme: return 10000;
        case .quatrieme: return 50000;
        }
    }
}