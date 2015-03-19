//
//  InfoWindow.swift
//  HandiParking
//
//  Created by Gaël on 17/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit

@IBDesignable class InfoMarkerWindow: UIView {
    
    @IBOutlet weak var adresse: UILabel!

    @IBOutlet weak var duration: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var capacity: UILabel!

    @IBOutlet weak var fee: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        //self.clipsToBounds = true
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        //var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        //var blurEffectView = UIVisualEffectView(effect: blurEffect)
        //blurEffectView.frame = self.bounds
        //self.addSubview(blurEffectView)

    }
    
}