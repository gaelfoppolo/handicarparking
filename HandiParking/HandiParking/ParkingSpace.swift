//
//  ParkingSpace.swift
//  HandiCarParking
//
//  Created by Gaël on 12/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

/// Emplacements récupérés grâce à OpenStreetMap

class ParkingSpace {
    
    // MARK: Attributs
    
    /// l'id de la node récupérée
    var id_node: String
    
    /// la latitude de l'emplacement
    var latitude: String
    
    /// la longitude de l'emplacement
    var longitude: String
    
    /// l'adresse approximative de l'emplacement (reverseGoogle)
    var address: String?
    
    /// distance (à vol d'oiseau) jusqu'à l'emplacement
    var distance: CLLocationDistance!
    
    /// distance (estimée) de parcours jusqu'à l'emplacement
    var distanceETA: CLLocationDistance!
    
    /// temps (estimé) de parcours jusqu'à l'emplacement
    var durationETA: NSTimeInterval?
    
    /// emplacement payant/gratuit
    var fee: String?
    
    /// nombre de places
    var capacity: String?
    
    /// nom du lieu associé à l'emplacement
    var name: String?
    
    // MARK: Initialisateurs
    
    /**
        Initialise un nouvel emplacement avec les informations suivantes :
        
        :param: id L'id de la node
        :param: lat La latitude de l'emplacement
        :param: lon La longitude de l'emplacment
        
        :returns: Un emplacement tout neuf, prêt à être utilisé
    */
    init(id: String?, lat: String?, lon: String?, name: String?, fee: String?, capacity: String?, distance: CLLocationDistance) {
        self.id_node = id ?? ""
        self.latitude = lat ?? ""
        self.longitude = lon ?? ""
        self.distance = distance
        self.name = name
        if let feee = fee {
            switch feee {
                case "yes":
                    self.fee = NSLocalizedString("FEE",comment:"Fee")
                case "no":
                    self.fee = NSLocalizedString("NO_FEE",comment:"No fee")
                default:
                    break
            }
        } else {
            self.fee = NSLocalizedString("NA",comment:"Not available")
        }
        if let capa = capacity {
            if let capa2 = capa.toInt() {
                if capa2 > 1 {
                    self.capacity = NSString(format: NSLocalizedString("NB_SPACES", comment: "nb spaces"), String(capa2)) as String
                } else if capa2 == 1 {
                    self.capacity = NSString(format: NSLocalizedString("NB_SPACE", comment: "nb space"), String(capa2)) as String
                } else {
                    self.capacity = NSLocalizedString("NA",comment:"Not available")
                }
            } else {
                self.capacity = NSString(format: NSLocalizedString("NB_SPACE", comment: "nb space"), String(1)) as String
            }
        } else {
            self.capacity = NSLocalizedString("NA",comment:"Not available")
        }
    }
    
    // MARK: Fonctions
    
    /**
        Met à jour l'adresse d'un emplacement ou défaut si aucune adresse
    
        :param: adr l'adresse à mettre à jour

    */
    func setAddress(adr: String?) {
        self.address = adr ?? NSLocalizedString("NO_ADDRESS",comment:"No adresse found")
    }
    
    /**
        Met à jour la distance et la durée estimée de parcours jusqu'à la place ou défaut si aucune estimation
    
        :param: distETA distance de parcours estimée
        :param: durETA durée de parcours estimée
 
    */
    func setDistanceAndDurationETA(distETA: CLLocationDistance?, durETA: NSTimeInterval?) {
        self.distanceETA = distETA ?? -1
        self.durationETA = durETA ?? -1
    }
    /**
        Génère sous une forme plus lisible par l'utilisateur, la distance
    
        :returns: la distance sous forme lisible
    */
    func getDistance() -> NSString {
        var distance:CLLocationDistance
        if self.distanceETA != -1 {
            distance = self.distanceETA
        } else {
            distance = self.distance!
        }
        
        var distanceTexte:String
        if distance < 1000 {
            distanceTexte = "\(Int(distance)) m"
        } else {
            distanceTexte = String(format: "%.2f", (distance/1000)) + " km"
        }
        return distanceTexte
    }
    
    /**
        Génère sous une forme plus lisible par l'utilisateur, la durée ou défaut si pas de durée
    
        :returns: la durée sous forme lisible
    */
    func getDuration() -> NSString {
        if self.durationETA != -1 {
            let tii = NSInteger(self.durationETA!)
            var seconds = tii % 60
            var minutes = (tii / 60) % 60
            var hours = (tii / 3600)
            
            let formatter = NSDateComponentsFormatter()
            formatter.unitsStyle = .Abbreviated
            
            let components = NSDateComponents()
            if minutes == 0 && hours == 0 {
                components.second = seconds
            } else {
                components.hour = hours
                components.minute = minutes
            }
            
            let string = formatter.stringFromDateComponents(components)
            
            return NSString(string: string!)
            
        } else {
            return NSLocalizedString("NA",comment:"Not available")
        }

    }
    
}