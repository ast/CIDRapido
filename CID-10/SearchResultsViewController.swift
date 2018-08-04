//
//  SearchResultsViewController.swift
//  CID-10
//
//  Created by Albin Stigo on 26/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import UIKit
import SVProgressHUD


private let kEstimatedRowHeight : CGFloat = 74.0
private let kScreenName = "Search"

class SearchResultsViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController : UISearchController?
    
    private var searchResults : [Row]?
    
    private var hasResults : Bool {
        get {
            if let searchResults = searchResults {
                return searchResults.count > 0 ? true : false
            }
            return false
        }
    }
    
    private var searchScope: SearchScope {
        get {
            let selectedIndex = self.searchController!.searchBar.selectedScopeButtonIndex
            return SearchScope(rawValue: selectedIndex)!
        }
    }
    
    // Dismiss keyboard when scrolling
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if case .Some(let searchBar) = searchController?.searchBar where searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
    
    private func showHUD(message : String) {
        SVProgressHUD.showInfoWithStatus(message)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Automatic line height
        tableView.estimatedRowHeight = kEstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Google Analytics
        // Put it at the end of the main queue, this is an optimization technique
        dispatch_async(dispatch_get_main_queue(), {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: kScreenName)
            tracker.send( GAIDictionaryBuilder.createScreenView().build() as NSDictionary as [NSObject : AnyObject])
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(self.searchController!)
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if let query = searchController.searchBar.text,
               scope = SearchScope(rawValue: searchController.searchBar.selectedScopeButtonIndex) {
                
                Database.sharedInstance.find(query, scope: scope, completion: { rows in
                    self.searchResults = rows
                    // Always reload, even if empty. This is need to handle the "No results" display.
                    self.tableView.reloadData()
                })
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchResults = self.searchResults {
            return searchResults.count > 0 ? searchResults.count : 1
        }
    
        return 0
    }
    
    func rowForIndexPath(indexPath: NSIndexPath) -> Row? {
        if let searchResults = self.searchResults {
            return searchResults[indexPath.row]
        }
        
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if hasResults {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("rowCell", forIndexPath: indexPath) as! RowCell
            
            // Get row
            if let row = rowForIndexPath(indexPath) {
                cell.codeLabel.attributedText = row.attributedCode
                cell.descLabel.attributedText = row.attributedDesc
            }
            
            // English codes are longer
            switch searchScope {
            case .Portuguse: cell.codeLabelWidth = 60
            case .English: cell.codeLabelWidth = 80
            }

            return cell
            
        } else {
            
            // No results cell
            let cell = tableView.dequeueReusableCellWithIdentifier("noResultsCell", forIndexPath: indexPath) as UITableViewCell
            
            cell.selectionStyle = .None
            //cell.layoutIfNeeded()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        return hasResults ? indexPath : nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let row = rowForIndexPath(indexPath),
            searchController = searchController {
            
            let code = row.attributedCode.string
            
            let prefixIndex = code.startIndex.advancedBy(code.characters.count - 1)
            //let prefixIndex = advance(code.startIndex, code.characters.count - 1)
                
            let prefix = code.substringToIndex(prefixIndex)
            
            // Set search text and show HUD if not equal
            if searchController.searchBar.text != prefix {
                searchController.searchBar.text = prefix
                showHUD(prefix)
            }

        }
    }
    
    /* Copy / Paste */
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return action == Selector("copy:")
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        
        switch action {
        case Selector("copy:"):
            UIPasteboard.generalPasteboard().string = rowForIndexPath(indexPath)?.description
        default: break
        }
    }

}
