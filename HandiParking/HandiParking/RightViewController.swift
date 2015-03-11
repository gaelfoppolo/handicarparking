//
//  RightViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum RightMenu: Int {
    case Help
    case About
}

protocol RightMenuProtocol : class {
    func changeViewController(menu: RightMenu)
}

class RightViewController : UIViewController, RightMenuProtocol {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var menus = ["Aide", "À propos"]
    let images = ["ic_menu_help", "ic_menu_about"]
    var helpViewController: UIViewController!
    var aboutViewController: UIViewController!
    
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
        let helpViewController = storyboard.instantiateViewControllerWithIdentifier("HelpViewController") as HelpViewController
        self.helpViewController = UINavigationController(rootViewController: helpViewController)
        
        let aboutViewController = storyboard.instantiateViewControllerWithIdentifier("AboutViewController") as AboutViewController
        self.aboutViewController = UINavigationController(rootViewController: aboutViewController)
        
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
        cell.backgroundColor = UIColor(red: 64/255, green: 170/255, blue: 239/255, alpha: 0.0)
        cell.textLabel?.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        cell.textLabel?.text = menus[indexPath.row]
        cell.imageView?.image = UIImage(named: images[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = RightMenu(rawValue: indexPath.item) {
            self.changeViewController(menu)
        }
    }
    
    func changeViewController(menu: RightMenu) {
        switch menu {
        case .Help:
            self.slideMenuController()?.changeMainViewController(self.helpViewController, close: true)
            break
        case .About:
            self.slideMenuController()?.changeMainViewController(self.aboutViewController, close: true)
            break
        default:
            break
        }
    }
    
}
