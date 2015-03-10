//
//  ViewController.swift
//  HandiParking
//
//  Created by Gaël on 10/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit

class GeoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IconHome"), style: .Plain, target: self, action: "presentLeftMenuViewController")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "IconHome"), style: .Plain, target: self, action: "presentRightMenuViewController")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


