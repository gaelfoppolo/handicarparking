//
//  SearchSelectedViewController.swift
//  HandiCarParking
//
//  Created by Gaël on 25/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

/// Contrôleur de la vue recherche après sélection d'un lieu 📍

class SearchSelectedViewController: GeoViewController {
    
    //MARK : IBOutlets
    
    /// bouton lancement recherche/coordonnées
    @IBOutlet weak var launchButtonText: UIButton!
    
    /**
        Appelée quand le bouton lancement est tapé
    */
    @IBAction override func launchButtonAction(sender: AnyObject) {
        
        if let icon = marker_place.icon {
            launchAction()
        } else {
            self.launchButtonText.enabled = false
            getCoordinate()
        }
    }
    
    /// bouton StreetView
    var streetViewButton: UIBarButtonItem!
    
    /// bouton itinéraire
    var itineraryButton: UIBarButtonItem!
    
    /// lieu choisi
    var place = Place()
    
    /// marqueur du lieu choisi
    var marker_place = GMSMarker()
    
    // MARK: Initialisateur

    override func viewDidLoad() {
        // on appelle le constructeur papa
        super.viewDidLoad()
        // on set les boutons itinéraire et StreetView
        self.navigationItem.rightBarButtonItems = setButtons() as [AnyObject]
        // on lance la récupération des coordonnées du lieu choisi
        if ServicesController().checkInternetConnection() {
            getCoordinate()
        }
    }
    
    override func sourceOfSearch() -> CLLocationCoordinate2D {
        return marker_place.position
    }

    /**
        Génère les boutons de la barre de navigation
    */
    func setButtons() -> NSArray {
        self.streetViewButton = UIBarButtonItem(image: UIImage(named: "toolbar_streetview"), style: UIBarButtonItemStyle.Plain, target: self, action: "streetViewButtonAction:")
        streetViewButton.enabled = false
        self.itineraryButton = UIBarButtonItem(image: UIImage(named: "toolbar_itinerary"), style: UIBarButtonItemStyle.Plain, target: self, action: "itineraryButtonAction:")
        itineraryButton.enabled = false
        var buttons: NSArray = [self.streetViewButton, self.itineraryButton]
        return buttons
    }
    
    /**
        Récupération des coordonnées du lieu choisi
    
        On effectue une requête sur l'API de Google Maps afin de récupérer les coordonnées du lieu choisi, en utilisant l'id unique associé à ce lieu
    
        La requête est effectuée de façon asynchrone grâce à une closure, avec un timeout de 10 secondes.
            
        On affiche ensuite un marker pour identifier ce lieu, on centre la caméra dessus et on change le bouton pour pouvoir lancer la recherche
    */
    func getCoordinate() {
            let request = self.managerGM!.request(DataProvider.GoogleMaps.PlaceDetails(self.place.placeid))
            request.validate()
            request.responseSwiftyJSON({ (request, response, json, error) -> Void in
                if error == nil  {
                    var dataRecup = json
                    var status:String? = dataRecup["status"].stringValue
                    
                    var lat:String?
                    var lon:String?
                    
                    if status == "OK" {
                        
                        lat = dataRecup["result"]["geometry"]["location"]["lat"].stringValue
                        lon = dataRecup["result"]["geometry"]["location"]["lng"].stringValue
                        
                        self.marker_place = GMSMarker(position: CLLocationCoordinate2DMake(NSString(string: lat!).doubleValue, NSString(string: lon!).doubleValue))
                        
                        self.marker_place.icon = UIImage(named: "marker_place")
                        self.marker_place.groundAnchor = CGPoint(x: 0.5, y: 1)
                        self.marker_place.appearAnimation = kGMSMarkerAnimationPop
                        self.marker_place.title = self.place.name
                        self.marker_place.tappable = false
                        
                        self.marker_place.map = self.mapView
                        
                        self.updateMapCameraOnPlaceLocation()
                        
                        UIView.animateWithDuration(0.5, animations: {
                            self.launchButtonText.alpha = 0.0
                        }) { finished in
                                self.launchButtonText.setImage(UIImage(named: "toolbar_launch"), forState: .Normal)
                                self.launchButtonText.enabled = true
                                UIView.animateWithDuration(0.5, animations: {
                                    self.launchButtonText.alpha = 1.0
                                })
                        }
                        
                    } else {
                        
                        self.launchButtonText.enabled = true
                        AlertViewController().errorResponseGoogle()
                    }
                    
                } else {
                    
                    self.launchButtonText.enabled = true
                    AlertViewController().errorRequest()
                }
            })
        
    }

    /**
        Centre la caméra (vue) sur la localisation du lieu recherchée
        On suppose ici qu'une vérification des services a été effectuées et que la localisation du lieu a été récupérée
    */
    func updateMapCameraOnPlaceLocation() {
        var camera = GMSCameraPosition(target: self.marker_place.position, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animateToCameraPosition(camera)
    }
    
    /**
        On ne sélectionne qu'un marqueur-emplacement, pas un marqueur représentant le lieu choisi
    */
    override func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if marker_place != marker {
            super.mapView(mapView, didTapMarker: marker)
        }
        
        return false
    }
    /**
        On ne génère l'infoWindow que si c'est un emplacement, sinon pas de fenêtre
    */
    override func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        if marker_place == marker {
            return nil
        } else {
            return super.mapView(mapView, markerInfoWindow: marker)
        }
    }

    override func setButtonsItineraryAndStreetViewInState(state: Bool) {
        itineraryButton.enabled = state
        streetViewButton.enabled = state
    }
    
    override func createMarkersAndBoundsToDisplay() {
        super.createMarkersAndBoundsToDisplay()
        marker_place.map = mapView
    }
    
}
