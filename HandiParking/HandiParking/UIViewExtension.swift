//
//  UIViewExtension.swift
//  HandiParking
//
//  Created by Gaël on 17/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit

extension UIView {

    class func viewFromNibName(name: String) -> UIView? {
        let views = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        return views.first as? UIView
    }
    
    func lock() {
        if let lockView = viewWithTag(10) {
            // la vue est déjà lock
        }
        else {
            let lockView = UIView(frame: bounds)
            lockView.backgroundColor = UIColor(white: 0.0, alpha: 1)
            lockView.tag = 10
            lockView.alpha = 0.0
            var label: UILabel = UILabel()
            label.text = "Chargement..."
            label.textColor = UIColor.whiteColor()
            label.numberOfLines = 1
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont.systemFontOfSize(15.0)
            label.sizeToFit()
            lockView.addSubview(label)
            label.center = lockView.center
            self.addSubview(lockView)
            UIView.animateWithDuration(0.5) {
                lockView.alpha = 1.0
            }
        }
    }
    
    func unlock() {
        if let lockView = self.viewWithTag(10) {
            UIView.animateWithDuration(0.5, animations: {
                lockView.alpha = 0.0
                }) { finished in
                    lockView.removeFromSuperview()
            }
        }
    }

}