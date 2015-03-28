//
//  StreetViewController.swift
//  HandiParking
//
//  Created by Gaël on 24/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit

/// Contrôleur de la vue StreetView 🚩

class StreetViewController: UIViewController {
    
    //MARK: Attributs
    
    /// marqueur contenant les coordonnées pour charger StreetView
    var marker:PlaceMarker
    
    //MARK: Initialisateurs
    
    /**
        Initialisation de la vue
    
        :param: marker Le marqueur sélectionné
    
    */
    init(marker: PlaceMarker) {
        self.marker = marker
        super.init(nibName: nil, bundle: nil)
    }
    
    // initialisateur obligatoire car marker n'est pas initialisé
    // find better way to do : init placemarker()
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        Instanciation de la vue
    
        - initialise un objet service panorama qui va demander le panorama prêt des coordonnées du marqueur sélectionné
        - ce service retourne un objet panorama que l'on peut utiliser
        - si il n'y a pas de panorama, on affiche une erreur
        - on créé ensuite une caméra pour notre panorama qui va indiquer dans quelle direction le panorama est affiché (voir la doc Google Maps pour les paramètres)
        - on créé ensuite notre vue panorama qui va afficher notre panorama, on lui assigne la caméra et le panorama et on l'ajoute à la vue
        - on créer le bouton qui servira à fermer la vue
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var service: GMSPanoramaService = GMSPanoramaService()
        
        service.requestPanoramaNearCoordinate(self.marker.position, callback: { (panorama, error) -> Void in
            
            if panorama != nil {
                
                var camera: GMSPanoramaCamera = GMSPanoramaCamera(heading: 180, pitch: 0, zoom: 1, FOV: 90)
                
                var panoView: GMSPanoramaView = GMSPanoramaView()
                
                panoView.autoresizingMask = .FlexibleWidth | .FlexibleHeight | .FlexibleBottomMargin |
                    .FlexibleLeftMargin | .FlexibleRightMargin |
                    .FlexibleTopMargin | .FlexibleBottomMargin
                
                panoView.camera = camera
                
                panoView.panorama = panorama
                
                self.marker.panoramaView = panoView
                
                self.view = panoView
                
                var closeButton: UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
                closeButton.addTarget(self, action: "closeButton:", forControlEvents: .TouchUpInside)
                closeButton.setImage(UIImage(named: "close.png") as UIImage!, forState: .Normal)
                closeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
                closeButton.frame = CGRectMake(10, 25, 50, 50)
                
                self.view.addSubview(closeButton)
                
            } else {
                if error.code == -1001 { // == timeout
                    self.errorBadConnection()
                } else {
                    self.errorNoData()
                }
                
            }
            
            
        })
    }

    /**
        Action sur le bouton pour fermer la vue
    */
    func closeButton(sender: UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
        Appelée s'il n'y a pas de panorama disponible : on ferme la vue et on affiche un message d'erreur
    */
    func errorNoData() {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            AlertViewController().errorStreetView()
        })
        
    }
    
    /**
    Appelée le message d'erreur indique un timeout
    */
    func errorBadConnection() {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            AlertViewController().errorBadConnection()
        })
        
    }
    
    
}