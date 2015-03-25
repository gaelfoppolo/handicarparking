//
//  SearchViewController.swift
//  HandiParking
//
//  Created by Gaël on 11/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import Alamofire
import SwiftyJSON

/// Contrôleur de la vue recherche 📍

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating  {
    
    @IBOutlet weak var placeFoundTable: UITableView!
    
    var searchArray = [Lieu]()
    
    var searchTimer = NSTimer()
    
    var placeSearchController = UISearchController()
    
    /// gestionnaire des requêtes pour Google Maps
    var managerGM: Alamofire.Manager?
    
    var request: Alamofire.Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configurationGM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationGM.timeoutIntervalForRequest = 10 // secondes
        self.managerGM = Alamofire.Manager(configuration: configurationGM)
        
        // Configure
        self.placeFoundTable.delegate = self
        self.placeFoundTable.dataSource = self
        
        
        // Configure countrySearchController
        self.placeSearchController = ({
            // Two setups provided below:
            
            // Setup One: This setup present the results in the current view.
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.sizeToFit()
            self.placeFoundTable.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = "Recherche"
        self.placeFoundTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let searchBarValue:String = self.placeSearchController.searchBar.text {
            if (countElements(searchBarValue) < 3) {
                var messageLabel:UILabel
                messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                messageLabel.text = "Veuillez rentrer un nom de lieu"
                messageLabel.textColor = UIColor.blackColor()
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center;
                messageLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(22))
                //[messageLabel sizeToFit];
                self.placeFoundTable.backgroundView = messageLabel
                self.placeFoundTable.separatorStyle = UITableViewCellSeparatorStyle.None
            } else if (self.searchArray.count == 0) {
                var messageLabel:UILabel
                messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                messageLabel.text = "No place match your search 😞"
                messageLabel.textColor = UIColor.blackColor()
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center;
                //messageLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(22))
                //[messageLabel sizeToFit];
                self.placeFoundTable.backgroundView = messageLabel;
                self.placeFoundTable.separatorStyle = UITableViewCellSeparatorStyle.None;
            }
            else {
                self.placeFoundTable.backgroundView = nil
                self.placeFoundTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            }
        }
        else {
            self.placeFoundTable.backgroundView = nil
            self.placeFoundTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        return self.searchArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //ask for a reusable cell from the tableview (celle name Cell), the tableview will create a new one if it doesn't have any
        let cell = self.placeFoundTable.dequeueReusableCellWithIdentifier("cellule", forIndexPath: indexPath) as UITableViewCell
        // on rempli la cellule avec le nom de l'objet
        cell.textLabel?.text = self.searchArray[indexPath.row].nom
        // ajouter un indicateur sur le cote de la cellule
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        // ou on supprime les séparateurs
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        println(self.placeSearchController.searchBar.text)
        if self.searchTimer.valid {
            self.searchTimer.invalidate()
            self.request?.cancel()
        }
        
        self.searchTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("launchSearch:"), userInfo:nil, repeats:false)
    }
    
    func launchSearch(sTimer: NSTimer) {
        
        
        self.searchArray.removeAll(keepCapacity: false)
        
        // check si non vide
        
        if let searchString:String = self.placeSearchController.searchBar.text {
        
            if !searchString.isEmpty {
                println("Contenu de la barre de recherche : " + searchString)
                
                self.request = self.managerGM!.request(DataProvider.GoogleMaps.Autocomplete(searchString)).responseSwiftyJSON { request, response, json, error in
                    
                    let predictions = json["predictions"].arrayValue
                    //let status = json["status"]
                    //println(json)
                    if !predictions.isEmpty {
                        
                        for lieu in predictions {
                            var placeid: String? = lieu["place_id"].stringValue
                            var nom: String? = lieu["description"].stringValue
                            
                            var point = Lieu(placeid: placeid, nom: nom)
                            //println(point)
                            
                            self.searchArray.append(point)
                        }
                        
                    }
                    self.placeFoundTable.reloadData()
                }
                
                
            }
            else {
                self.placeFoundTable.reloadData()
            }
        }
    }
    
}
