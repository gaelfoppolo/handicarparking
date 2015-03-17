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

}