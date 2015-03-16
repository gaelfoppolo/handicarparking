//
//  Emplacement.swift
//  HandiParking
//
//  Created by Gaël on 12/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

// MARK: Classe gérant les emplacements récupérés grâce à OpenStreetMap

class Emplacement {
    
    /// l'id de la node récupérée
    var id_node: String
    
    /// la latitude de l'emplacement
    var latitude: String
    
    /// la longitude de l'emplacement
    var longitude: String
    
    /**
        Initialise un nouvel emplacement avec les informations suivantes :
        
        :param: id L'id de la node
        :param: lat La latitude de l'emplacement
        :param: lon La longitude de l'emplacment
        
        :returns: Un emplacement tout neuf, prêt à être utilisé
    */
    init(id: String?, lat: String?, lon: String?) {
        self.id_node = id ?? ""
        self.latitude = lat ?? ""
        self.longitude = lon ?? ""
    }
}