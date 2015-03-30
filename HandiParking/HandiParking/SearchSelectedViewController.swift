//
//  SearchSelectedViewController.swift
//  HandiParking
//
//  Created by Gaël on 25/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

class SearchSelectedViewController: GeoViewController {
    
    var streetViewButton: UIBarButtonItem!
    
    var itineraryButton: UIBarButtonItem!
    
    @IBOutlet weak var launchButtonText: UIButton!
    
    @IBAction override func launchButtonAction(sender: AnyObject) {
        
        if let icon = marker_place.icon {
            
            launchAction()
            
        } else {
            
            self.launchButtonText.enabled = false
            getCoordinate()
            
        }
    }
    
    /// lieu choisi
    var place = Place()
    
    /// marqueur du lieu choisi
    var marker_place = GMSMarker()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = setButtons()
        
        if ServicesController().checkInternetConnection() {
        
            getCoordinate()
        }
    }
    
    override func sourceOfSearch() -> CLLocationCoordinate2D {
        return marker_place.position
    }

    
    func setButtons() -> NSArray {
        self.streetViewButton = UIBarButtonItem(image: UIImage(named: "toolbar_streetview"), style: UIBarButtonItemStyle.Bordered, target: self, action: "streetViewButtonAction:")
        streetViewButton.enabled = false
        self.itineraryButton = UIBarButtonItem(image: UIImage(named: "toolbar_itinerary"), style: UIBarButtonItemStyle.Bordered, target: self, action: "itineraryButtonAction:")
        itineraryButton.enabled = false
        var buttons: NSArray = [self.streetViewButton, self.itineraryButton]
        return buttons
    }
    
    func getCoordinate() {
            let request = self.managerGM!.request(DataProvider.GoogleMaps.PlaceDetails(self.place.placeid))
            request.validate()
            request.responseSwiftyJSON { request, response, json, error in
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
            }
        
    }

    /**
    Centre la caméra (vue) sur la localisation du lieu recherchée
    On suppose ici qu'une vérification des services a été effectuées et que la localisation du lieu a été récupérée
    */
    func updateMapCameraOnPlaceLocation() {
        var camera = GMSCameraPosition(target: self.marker_place.position, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.animateToCameraPosition(camera)
    }
    
    override func launchRecherche() {
        super.launchRecherche()
        marker_place.map = mapView
    }
    
    override func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if marker_place != marker {
            super.mapView(mapView, didTapMarker: marker)
        }
        
        return false
    }
    
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
    
}
