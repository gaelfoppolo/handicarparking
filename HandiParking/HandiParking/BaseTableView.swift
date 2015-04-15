//
//  BaseTableView.swift
//  HandiCarParking
//
//  Created by Gaël on 11/03/2015.
//  Copyright (c) 2015 KeepCore. All rights reserved.
//

/// ViewController commune pour partager un prototype d'UITableViewCell commune entre les sous classes

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: Constants.Nib.name, bundle: nil)
        
        // Requis si nos sous classes utilisent dequeueReusableCellWithIdentifier:forIndexPath:
        tableView.registerNib(nib, forCellReuseIdentifier: Constants.TableViewCell.identifier)
    }
    
    /**
        Configure la cellule avec les données de la place
        :param: cell la cellule à remplir avec les données
        :param: place les données utilisées pour remplir
    */
    func configureCell(cell: UITableViewCell, forText text: NSAttributedString) {
        //cell.textLabel?.text = place.name
        cell.textLabel?.attributedText = text
        cell.imageView?.image = UIImage(named: "marker")
    }
}