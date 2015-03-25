//
//  SearchViewController.swift
//  HandiParking
//
//  Created by Gaël on 11/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchViewController: BaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    // MARK : Properties
    
    var searchArray = [Lieu]()
    var countrySearchController: UISearchController!
    var searchTimer = NSTimer()

    /// gestionnaire des requêtes pour Google Maps
    var managerGM: Alamofire.Manager?
    
    var request: Alamofire.Request?
    
    //MARK : Base view controllers func
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurationGM = NSURLSessionConfiguration.defaultSessionConfiguration()
        configurationGM.timeoutIntervalForRequest = 10 // secondes
        self.managerGM = Alamofire.Manager(configuration: configurationGM)
        
        // Configure tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Configure countrySearchController
        
        self.countrySearchController = UISearchController(searchResultsController: nil)
        self.countrySearchController.searchResultsUpdater = self
        self.countrySearchController.searchBar.sizeToFit()
        //self.countrySearchController.searchBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        //self.countrySearchController.searchBar.translucent = true
        tableView.tableHeaderView = self.countrySearchController.searchBar
        //self.countrySearchController.searchBar.searchBarStyle = .Prominent
        
        self.countrySearchController.delegate = self
        self.countrySearchController.dimsBackgroundDuringPresentation = false // default is YES
        self.countrySearchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.countrySearchController.searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchControllerDelegate
    
    func presentSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let searchBarValue:String = self.countrySearchController.searchBar.text {
            if (searchBarValue.isEmpty) {
                var messageLabel:UILabel
                messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                messageLabel.text = "Veuillez rentrer un nom de lieu 🏠"
                messageLabel.textColor = UIColor.blackColor()
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center;
                //messageLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(22))
                //[messageLabel sizeToFit];
                self.tableView.backgroundView = messageLabel;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            }
            else if (self.searchArray.count == 0) {
                var messageLabel:UILabel
                messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                messageLabel.text = "Aucun lieu ne correpond à votre recherche 😞"
                messageLabel.textColor = UIColor.blackColor()
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center;
                //messageLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(22))
                //[messageLabel sizeToFit];
                self.tableView.backgroundView = messageLabel;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            }
            else {
                self.tableView.backgroundView = nil;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
            }
        }
        else {
            self.tableView.backgroundView = nil;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
        }
        return self.searchArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = self.tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as UITableViewCell
        //cell.textLabel?.text! = self.searchArray[indexPath.row].nom
        let place = self.searchArray[indexPath.row]
        configureCell(cell, forPlace: place)

        return cell
    }
    
    // MARK : UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK : UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let searchString:String = self.countrySearchController.searchBar.text
        
        if searchString.isEmpty {
            self.searchArray.removeAll(keepCapacity: false)
            self.tableView.reloadData()
        } else {
            if self.searchTimer.valid {
                self.searchTimer.invalidate()
                self.request?.cancel()
            }
            
            self.searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("launchSearch:"), userInfo:nil, repeats:false)
        }
    }
    
    func launchSearch(sTimer: NSTimer) {
        
        
        self.searchArray.removeAll(keepCapacity: false)

        if let searchString:String = self.countrySearchController.searchBar.text {
            
            if !searchString.isEmpty {
                
                self.request = self.managerGM!.request(DataProvider.GoogleMaps.Autocomplete(searchString)).responseSwiftyJSON { request, response, json, error in
                    
                    let predictions = json["predictions"].arrayValue
                    //TODO//let status = json["status"]
                    if !predictions.isEmpty {
                        
                        for lieu in predictions {
                            var placeid: String? = lieu["place_id"].stringValue
                            var nom: String? = lieu["description"].stringValue
                            var types = lieu["types"].arrayValue
                            if !contains(types, "country") {
                                var point = Lieu(placeid: placeid, nom: nom)
                                self.searchArray.append(point)
                            }
                        }
                        
                    }
                    self.tableView.reloadData()
                }
   
            }
            else {
                self.tableView.reloadData()
            }
        }
    }

    
}