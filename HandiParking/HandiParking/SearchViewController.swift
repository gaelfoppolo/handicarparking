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
    
    var placesResults = [Place]()
    var placeSearchController: UISearchController!
    var timerBeforeLaunchSearch = NSTimer()
    
    var inSearching: Bool = false

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
        
        // Configure placeSearchController
        
        self.placeSearchController = UISearchController(searchResultsController: nil)
        self.placeSearchController.searchResultsUpdater = self
        self.placeSearchController.searchBar.sizeToFit()
        self.placeSearchController.searchBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        self.placeSearchController.searchBar.translucent = true
        tableView.tableHeaderView = self.placeSearchController.searchBar
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        //self.placeSearchController.searchBar.searchBarStyle = .Prominent
        
        self.placeSearchController.delegate = self
        self.placeSearchController.dimsBackgroundDuringPresentation = false // default is YES
        self.placeSearchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
        
        self.placeSearchController.searchBar.tintColor = UIColor.whiteColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.placeSearchController.searchBar.becomeFirstResponder()
    }
    
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.placeSearchController.searchBar.resignFirstResponder()
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
        if let searchBarValue:String = self.placeSearchController.searchBar.text {
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
                
            }
            else if self.inSearching {
                
                let loadingView = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                
                let myActivityIndicatorView: DTIActivityIndicatorView = DTIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
                myActivityIndicatorView.center = loadingView.center
                loadingView.alpha = 0.0
                myActivityIndicatorView.indicatorColor = UIColor.blueColor()
                myActivityIndicatorView.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
                myActivityIndicatorView.startActivity()
                
                loadingView.addSubview(myActivityIndicatorView)
                
                UIView.animateWithDuration(0.5) {
                    loadingView.alpha = 1.0
                }
                
               self.tableView.backgroundView = loadingView
            }
            else if (self.placesResults.count == 0) {
                var messageLabel:UILabel
                messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                messageLabel.text = "Aucun lieu ne correpond à votre recherche 😞"
                messageLabel.textColor = UIColor.blackColor()
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center
                //messageLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(22))
                //[messageLabel sizeToFit];
                self.tableView.backgroundView = messageLabel
            }
            else {
                self.tableView.backgroundView = nil
            }
        }
        else {
            self.tableView.backgroundView = nil
        }
        return self.placesResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = self.tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as UITableViewCell
        //cell.textLabel?.text! = self.searchArray[indexPath.row].nom
        let place = self.placesResults[indexPath.row]
        configureCell(cell, forPlace: place)

        return cell
    }
    
    // MARK : UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if ServicesController().checkInternetConnection() {
            let searchString:String = self.placeSearchController.searchBar.text
            
            self.inSearching = false
            
            if searchString.isEmpty {
                self.placesResults.removeAll(keepCapacity: false)
                self.tableView.reloadData()
            } else {
                if self.timerBeforeLaunchSearch.valid {
                    self.timerBeforeLaunchSearch.invalidate()
                    self.request?.cancel()
                }
                
                self.timerBeforeLaunchSearch = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("launchSearch:"), userInfo:nil, repeats:false)
            }
        }
        
    }
    
    func launchSearch(sTimer: NSTimer) {
        
        self.inSearching = true
        
        self.placesResults.removeAll(keepCapacity: false)
        
        self.tableView.reloadData()

        if let searchString:String = self.placeSearchController.searchBar.text {
            
            if !searchString.isEmpty {
                
                self.request = self.managerGM!.request(DataProvider.GoogleMaps.Autocomplete(searchString)).responseSwiftyJSON { request, response, json, error in
                    
                    if error == nil  {
                        
                        let predictions = json["predictions"].arrayValue
                        var status = json["status"].stringValue
                        
                        if status == "OK" || status == "ZERO_RESULTS" {
                            
                            if !predictions.isEmpty {
                                
                                for lieu in predictions {
                                    var placeid: String? = lieu["place_id"].stringValue
                                    var name: String? = lieu["description"].stringValue
                                    var types = lieu["types"].arrayValue
                                    if !contains(types, "country") {
                                        var point = Place(placeid: placeid, name: name)
                                        self.placesResults.append(point)
                                    }
                                }
                                
                            }
                            self.inSearching = false
                            self.tableView.reloadData()
                            
                        } else {
                            self.inSearching = false
                            self.placeSearchController.searchBar.resignFirstResponder()
                            AlertViewController().errorResponseGoogle()
                            self.tableView.reloadData()
                        }
                        
                    } else {
                        self.inSearching = false
                        if error?.code != -999 {
                            AlertViewController().errorRequest()
                            self.placeSearchController.searchBar.resignFirstResponder()
                        }
                        self.tableView.reloadData()
                    }
                    
                }
   
            }
            else {
                self.inSearching = false
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK : UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("placeSelected", sender: self.tableView)
    }
    
    // MARK : Segue
    
    //pour savoir à quelle vue on envoie les donnnées
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "placeSelected" {
            let searchSelectedViewController = segue.destinationViewController as SearchSelectedViewController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            searchSelectedViewController.place = self.placesResults[indexPath.row]
            //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Recherche", style: .Plain, target: nil, action: nil)
        }
    }

    
}