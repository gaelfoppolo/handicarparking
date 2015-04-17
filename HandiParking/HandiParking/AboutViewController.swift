//
//  AboutViewController.swift
//  HandiCarParking
//
//  Created by Gaël on 11/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //MARK : Outlets
    
    /// appelé lorsque le bouton nous contacter est touché
    @IBAction func sendMail(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            AlertViewController().errorSendMail()
        }
    }
    
    /// appelé lorsque le bouton en savoir plus est touché
    @IBAction func learnMoreOSM(sender: AnyObject) {
        var mySafari: UIApplication = UIApplication.sharedApplication()
        var myURL: NSURL = NSURL(string: "http://www.openstreetmap.org/about")!
        mySafari.openURL(myURL)
    }
    
    /// appelé lorsque le bouton contribuer est touché
    @IBAction func contributeOSM(sender: AnyObject) {
        var mySafari: UIApplication = UIApplication.sharedApplication()
        var urlString = "http://wiki.openstreetmap.org/wiki/" + NSLocalizedString("CONTRIB_OSM_URL",comment:"language string") + "Beginners'_guide"
        var urlParse: NSString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var myURL: NSURL = NSURL(string: urlParse as String)!
        mySafari.openURL(myURL)
    }
    
    //MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("ABOUT", comment: "About")
    }
    
    //MARK: Fonctions
    
    /**
        Créer la vue mail avec les paramètres nécessaires
        :return: la vue qui va gérer le mail
    */
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["contact@keepcore.com"])
        mailComposerVC.setSubject("HandiCarParking")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
