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
    
    //MARK: description de l'objet
    
    override var description: String {
        return "ID : \(placeid) \nNom : \(nom) \n"
    }
    
    //MARK: Initialisateur
    
    init(placeid: String?, nom: String?) {
        self.placeid = placeid ?? ""
        self.nom = nom ?? ""
    }
}