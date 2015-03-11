//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum LeftMenu: Int {
    case Main = 0
    case Search
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    let menus = ["Géolocalisation", "Rechercher"]
    let images = ["ic_menu_location", "ic_menu_search"]
    var geoViewController: UIViewController!
    var searchViewController: UIViewController!
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .None
        
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = self.tableView.bounds
        
        let cor1 = UIColor(red: 9/255, green: 80/255, blue: 208/255, alpha: 1.0).CGColor
        let cor2 = UIColor.cyanColor().CGColor
        let arrayColors = [cor1, cor2]
        
        gradient.colors = arrayColors
        self.tableView.layer.insertSublayer(gradient, atIndex: 0)
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let searchViewController = storyboard.instantiateViewControllerWithIdentifier("SearchViewController") as SearchViewController
        self.searchViewController = UINavigationController(rootViewController: searchViewController)
        
        self.tableView.registerCellClass(BaseTableViewCell.self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: BaseTableViewCell = BaseTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: BaseTableViewCell.identifier)
        cell.backgroundColor = UIColor(red: 102/255, green: 204/255, blue: 255/255, alpha: 0.0)
        //cell.textLabel?.font = UIFont.italicSystemFontOfSize(18)
        cell.textLabel?.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        cell.textLabel?.text = menus[indexPath.row]
        cell.imageView?.image = UIImage(named: images[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            self.changeViewController(menu)
        }
    }
    
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .Main:
            self.slideMenuController()?.changeMainViewController(self.geoViewController, close: true)
        case .Search:
            self.slideMenuController()?.changeMainViewController(self.searchViewController, close: true)
            break
        default:
            break
        }
    }
    
}