//
//  InitialTableViewController.swift
//  CID-10
//
//  Created by Albin Stigo on 26/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import UIKit
import SVProgressHUD

class InitialTableViewController: BrowseTableViewController {

    var searchController : UISearchController?
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        
        var text = NSMutableAttributedString(string: "\u{f0f1} CIDRapido.com")
        
        // Stethoscope
        text.addAttribute(NSFontAttributeName,
            value: UIFont(name: "FontAwesome", size: 22.0)!,
            range: NSMakeRange(0, 1))
        
        // Text font
        text.addAttribute(NSFontAttributeName,
            value: UIFont(name: "Titillium-Semibold", size: 22.0)!,
            range: NSMakeRange(1, 14))
        
        label.textColor = UIColor.whiteColor()
        label.shadowColor = UIColor.shadowColor()
        label.shadowOffset = CGSizeMake(1, 1)
        
        label.attributedText = text
        label.sizeToFit()
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchResultsController = storyboard?.instantiateViewControllerWithIdentifier("searchResultsViewController") as! SearchResultsViewController
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController!.searchResultsUpdater = searchResultsController
        searchController!.searchBar.sizeToFit()
        searchController!.searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchController!.searchBar.scopeButtonTitles = ["Português", "Inglês"]
        
        // Colors
        searchController!.searchBar.tintColor = UIColor.hospitalGreen()
        // Delegate
        searchResultsController.searchController = searchController
        // Add to tableview
        tableView.tableHeaderView = searchController!.searchBar
        
        // Title label
        navigationItem.titleView = titleLabel
        
        // Progress HUD Setup
        SVProgressHUD.setBackgroundColor(UIColor.lightHospitalGreen())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.setInfoImage(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }*/
}
