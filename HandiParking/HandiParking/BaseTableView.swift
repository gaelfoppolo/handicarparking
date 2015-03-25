//
//  BaseTableView.swift
//  HandiParking
//
//  Created by Gaël on 11/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

/*
Abstract:

Base or common view controller to share a common UITableViewCell prototype between subclasses.

*/

import UIKit

class BaseTableViewController: UITableViewController {
    // MARK: Types
    
    struct Constants {
        struct Nib {
            static let name = "TableCell"
        }
        
        struct TableViewCell {
            static let identifier = "cellID"
        }
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Required if our subclasses are to use: dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)
    }
    
    // MARK:
    
    func configureCell(cell: UITableViewCell, forPlace place: Lieu) {
        cell.textLabel?.text = place.nom
        //cell.detailTextLabel?.text = "what display?"
    }
}