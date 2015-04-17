//
//  SearchViewController.swift
//  HandiCarParking
//
//  Created by Gaël on 11/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/// Contrôleur de la vue recherche 🔍

class SearchViewController: BaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    // MARK : Properties
    
    /// la liste des lieux trouvées
    var placesResults: [Place]? {
        didSet {
            reloadAutoCompleteData()
        }
    }
    
    /// le contrôleur de la barre de recherche
    var placeSearchController: UISearchController!
    
    /// timer pour lancer la recherche
    var timerBeforeLaunchSearch = NSTimer()
    
    /// booléen en recherche ou non
    var inSearching: Bool = false

    /// gestionnaire des requêtes pour Google Maps
    var managerGM: Alamofire.Manager?
    
    /// requête de la recherche Google Autocomplete (permet de cancel)
    var request: Alamofire.Request?
    
    /// couleur par défaut du texte
    var autoCompleteTextColor = UIColor.lightGrayColor()
    
    /// liste des noms des lieux trouvés
    var attributedAutocompleteStrings:[NSAttributedString]?
    
    /// attributs du texte à afficher
    var autoCompleteAttributes:Dictionary<String,AnyObject>?
    
    //MARK: Init
    
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
        
        // Configuration de la tableView
        // On veut être le délégué et la source des données pour notre tableView afin de pouvoir gérer le fait de sélectionner une ligne
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Configuration de placeSearchController
        self.placeSearchController = UISearchController(searchResultsController: nil)
        self.placeSearchController.searchResultsUpdater = self
        self.placeSearchController.searchBar.sizeToFit()
        self.placeSearchController.searchBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        self.placeSearchController.searchBar.translucent = true
        self.placeSearchController.searchBar.keyboardType = UIKeyboardType.ASCIICapable
        tableView.tableHeaderView = self.placeSearchController.searchBar
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.placeSearchController.delegate = self
        self.placeSearchController.dimsBackgroundDuringPresentation = false // par défaut c'est true
        self.placeSearchController.searchBar.delegate = self // donc on peut surveiller/contrôler les changements
        
        definesPresentationContext = true
        
        self.placeSearchController.searchBar.tintColor = UIColor.whiteColor()
        
        var attributes = Dictionary<String,AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(12)
        
        autoCompleteAttributes = attributes
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.placeSearchController.searchBar.placeholder = NSLocalizedString("SEARCH_BAR_PLACEHOLDER", comment: "help people know what typing")
        // après 0.8 secondes on affiche le clavier
        var delayKeyboardPresentation = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("presentKeyboard:"), userInfo:nil, repeats:false)
    }
    
    /**
        Affiche le clavier
    */
    func presentKeyboard(sTimer: NSTimer) {
        self.placeSearchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: UISearchBarDelegate
    
    /**
        Cache le clavier lorsque le bouton Recherche est cliqué
    */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
    
    /**
        Défini le nombre de lignes à afficher dans notre tableView (voir Apple Doc)
        En plus ici on gère deux autres choses :
            - si la barre de recherche est vide, un message d'aide
            - si la barre de recherche n'est pas vide et aucun résultat, un message d'erreur
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchBarValue:String = self.placeSearchController.searchBar.text {
            if (searchBarValue.isEmpty) {
                var messageLabel:UILabel
                messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                messageLabel.text = NSLocalizedString("SEARCH_WELCOME", comment: "help people know what typing")
                messageLabel.textColor = UIColor.blackColor()
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center
                self.tableView.backgroundView = messageLabel
                
            }
            else if self.inSearching {
                
                let loadingView = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                
                let myActivityIndicatorView: DTIActivityIndicatorView = DTIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
                myActivityIndicatorView.center = loadingView.center
                loadingView.alpha = 0.0
                myActivityIndicatorView.indicatorColor = UIColor(red: 0/255, green: 142/255, blue: 255/255, alpha: 1.0)
                myActivityIndicatorView.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
                myActivityIndicatorView.startActivity()
                
                loadingView.addSubview(myActivityIndicatorView)
                
                UIView.animateWithDuration(0.5) {
                    loadingView.alpha = 1.0
                }
                
               self.tableView.backgroundView = loadingView
            }
            else if (self.placesResults == nil) {
                var messageLabel:UILabel
                messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                messageLabel.text = NSLocalizedString("SEARCH_NO_RESULT", comment: "search no results message")
                messageLabel.textColor = UIColor.blackColor()
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = NSTextAlignment.Center
                self.tableView.backgroundView = messageLabel
            }
            else {
                self.tableView.backgroundView = nil
            }
        }
        else {
            self.tableView.backgroundView = nil
        }
        return self.placesResults != nil ? self.placesResults!.count : 0
    }
    /**
        Demande les données à afficher dans la cellule (voir Apple Doc)
        On utilise une sous fonction pour remplir la cellule
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.identifier, forIndexPath: indexPath) as! UITableViewCell
        let place = self.placesResults![indexPath.row]
        let textToDisplay = attributedAutocompleteStrings![indexPath.row]
        //cell.textLabel?.attributedText = attributedAutocompleteStrings![indexPath.row]
        configureCell(cell, forText: textToDisplay)

        return cell
    }
    
    // MARK : UISearchResultsUpdating
    
    /**
        Appelée quand le texte de la barre de recherche est modifié
        On vérifie si la barre n'est pas vide et on attend 0.5 seconde avant de lancer la recherche
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if ServicesController().checkInternetConnection() {
            let searchString:String = self.placeSearchController.searchBar.text
            
            self.inSearching = false
            
            if searchString.isEmpty {
                self.placesResults = nil
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
    
    /**
        Recherche des lieux correspondants au contenu de la barre de recherche
    
        On effectue une requête sur l'API de Google Maps, Places (Autocommplete) afin de récupérer le nom du lieu ainsi que son identifiant unique. Un maximum de 5 résultats est proposé (il est arrivé d'en obtenir 6).
    
        La requête est effectuée de façon asynchrone grâce à une closure, avec un timeout de 10 secondes.
    */
    func launchSearch(sTimer: NSTimer) {
        
        self.inSearching = true
        
        self.placesResults = nil
        
        self.tableView.reloadData()

        if let searchString:String = self.placeSearchController.searchBar.text {
            
            if !searchString.isEmpty {
                
                self.request = self.managerGM!.request(DataProvider.GoogleMaps.Autocomplete(searchString)).responseSwiftyJSON({ (request, response, json, error) -> Void in
                    
                    if error == nil  {
                        
                        let predictions = json["predictions"].arrayValue
                        var status = json["status"].stringValue
                        
                        if status == "OK" || status == "ZERO_RESULTS" {
                            
                            if !predictions.isEmpty {
                                
                                var placesTemp = [Place]()
                                
                                for lieu in predictions {
                                    var placeid: String? = lieu["place_id"].stringValue
                                    var name: String? = lieu["description"].stringValue
                                    var types = lieu["types"].arrayValue
                                    if !contains(types, "country") {
                                        var point = Place(placeid: placeid, name: name)
                                        placesTemp.append(point)
                                    }
                                }
                                self.inSearching = false
                                self.placesResults = placesTemp
                                
                            } else {
                                self.inSearching = false
                                self.tableView.reloadData()
                            }
                            
                            
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
                    
                })
   
            }
            else {
                self.inSearching = false
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK : UITableViewDelegate
    
    /**
        Signifie au délégué que la ligne spécifiée a été sélectionnée
        On lance le segue grâce à son identifiant
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("placeSelected", sender: self.tableView)
    }
    
    // MARK : Segue
    
    /**
        Préparation de la segue
        On spécifie la vue à laquelle on envoie les données et quelles données on envoie
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "placeSelected" {
            let searchSelectedViewController = segue.destinationViewController as! SearchSelectedViewController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            searchSelectedViewController.place = self.placesResults![indexPath.row]
            //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "test", style: .Plain, target: nil, action: nil)
        }
    }
    
    /**
        Mise en place du style du texte qui va être affiché
        Si le texte de la barre de recherche est contenu dans le nom du lieu, on lui applique un style différent
        On lance l'actualisation du contenu de la table quand c'est terminé
    */
    private func reloadAutoCompleteData(){
            let searchString:String = self.placeSearchController.searchBar.text
            let attrs = [NSForegroundColorAttributeName:autoCompleteTextColor, NSFontAttributeName:UIFont.systemFontOfSize(13)]
            if attributedAutocompleteStrings == nil{
                attributedAutocompleteStrings = [NSAttributedString]()
            }
            else{
                if attributedAutocompleteStrings?.count > 0 {
                    attributedAutocompleteStrings?.removeAll(keepCapacity: false)
                }
            }
            
            if placesResults != nil{
                for i in 0..<placesResults!.count{
                    let str = placesResults![i].name as NSString
                    let range = str.rangeOfString(searchString, options: .CaseInsensitiveSearch)
                    var attString = NSMutableAttributedString(string: str as String, attributes: attrs)
                    attString.addAttributes(autoCompleteAttributes!, range: range)
                    attributedAutocompleteStrings?.append(attString)
                }
            }
        tableView.reloadData()
    }


}