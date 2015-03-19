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
            let activity = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activity.hidesWhenStopped = true
            activity.center = lockView.center
            activity.startAnimating()
            lockView.addSubview(activity)
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