//
//  ParkingSpace.swift
//  HandiParking
//
//  Created by Gaël on 12/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

// MARK: Classe gérant les emplacements récupérés grâce à OpenStreetMap

class ParkingSpace {
    
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
    
    /// nombre d'emplacements
    var capacity: String?
    
    /// nom du lieu associé à l'emplacement
    var name: String?
    
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
        self.name = name ?? "Aucune information"
        if let feee = fee {
            switch feee {
                case "yes":
                    self.fee = "Payant"
                case "no":
                    self.fee = "Gratuit"
                default:
                    break
            }
        } else {
            self.fee = "N/A"
        }
        if let capa = capacity {
            if let capa2 = capa.toInt() {
                if capa2 > 1 {
                    self.capacity = "\(capa2) places"
                } else {
                    self.capacity = "1 place"
                }
            } else {
                self.capacity = "1 place"
            }
        } else {
            self.capacity = "N/A"
        }
    }
    
    func setAddress(adr: String?) {
        self.address = adr ?? "Aucune adresse correspondante"
    }
    
    func setDistanceAndDurationETA(distETA: CLLocationDistance?, durETA: NSTimeInterval?) {
        self.distanceETA = distETA ?? -1
        self.durationETA = durETA ?? -1
    }
    
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
    
    func getDuration() -> NSString {
        if self.durationETA != -1 {
            let tii = NSInteger(self.durationETA!)
            var seconds = tii % 60
            var minutes = (tii / 60) % 60
            var hours = (tii / 3600)
            
            let formatter = NSDateComponentsFormatter()
            formatter.unitsStyle = .Short
            
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
            return "N/A"
        }

    }
    
}