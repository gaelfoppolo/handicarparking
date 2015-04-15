//
//  InfoWindow.swift
//  HandiCarParking
//
//  Created by Gaël on 17/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit

/// Vue affichant les détails d'un emplacement lorsqu'il est sélectionné

//@IBDesignable
class InfoMarkerWindow: UIView {
    
    /// MARK: Outlets
    
    /// l'adresse de l'emplacement
    @IBOutlet weak var address: UILabel!
    
    /// la durée de trajet estimée jusqu'à l'emplacement
    @IBOutlet weak var duration: UILabel!
    
    /// la distance de trajet estimée jusqu'à l'emplacement
    @IBOutlet weak var distance: UILabel!
    
    /// le nom du lieu associé à l'emplacement
    @IBOutlet weak var name: UILabel!
    
    // le nombre de places disponible à cet emplacement
    @IBOutlet weak var capacity: UILabel!
    
    // emplacement payant/gratuit
    @IBOutlet weak var fee: UILabel!
    
    /// MARK: Initilisateurs
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /**
        Setup de la vue, seulement son rendu
    */
    func setup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)

    }
    
}