//
//  BrowseTableViewController.swift
//  CID-10
//
//  Created by Albin Stigo on 10/01/15.
//  Copyright (c) 2015 Albin Stigo. All rights reserved.
//

import UIKit

private let kEstimatedRowHeight : CGFloat = 74.0

class BrowseTableViewController: UITableViewController {

    var parent : BrowseRow? // Parent?
    var rows : Array<BrowseRow>?
    
    var screenName : String?
    
    @IBAction func searchButtonTapped(sender: UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch parent {
            
        case .Some(let chapter as Chapter):
            self.title = "Capitulo \(chapter.first)–\(chapter.last)"
            Database.sharedInstance.groups(chapter, completion: {rows in
                self.rows = rows
                self.tableView.reloadData()
            })
            
        case .Some(let group as Group):
            self.title = "Grupo \(group.first)–\(group.last)"
            Database.sharedInstance.categories(group, completion: {rows in
                self.rows = rows
                self.tableView.reloadData()
            })
            
        case .Some(let category as Category):
            self.title = "Categoria \(category.first)"
            Database.sharedInstance.subcategories(category, completion: {rows in
                self.rows = rows
                self.tableView.reloadData()
            })
            
        default:
            Database.sharedInstance.chapters({rows in
                self.rows = rows
                self.tableView.reloadData()
            })
        }
        
        // Automatic line height
        tableView.estimatedRowHeight = kEstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Google Analytics
        // Put it at the end of the main que
        dispatch_async(dispatch_get_main_queue(), {
            if let screenName = self.screenName {
                let tracker = GAI.sharedInstance().defaultTracker
                tracker.set(kGAIScreenName, value: screenName)
                tracker.send( GAIDictionaryBuilder.createScreenView().build() as NSDictionary as [NSObject : AnyObject])
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = rows {
            return rows.count
        }
        
        return 0
    }

    func rowForIndexPath(indexPath: NSIndexPath?) -> BrowseRow? {
        if let rows = rows {
            return rows[indexPath!.row]
        }
        
        return nil
    }
    
    func selectedRow() -> BrowseRow? {
        return rowForIndexPath(tableView.indexPathForSelectedRow)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch rowForIndexPath(indexPath) {
            
        case .Some(let chapter as Chapter):
            let cell = tableView.dequeueReusableCellWithIdentifier("chapterCell", forIndexPath: indexPath) as! ChapterCell
            cell.code.text = "\(chapter.first)–\(chapter.last)"
            cell.desc.text = chapter.desc
            cell.cap.text = "Cap. \(chapter.roman)"
            //cell.layoutIfNeeded()
            return cell
            
        case .Some(let group as Group):
            let cell = tableView.dequeueReusableCellWithIdentifier("browseCell", forIndexPath: indexPath) as! BrowseCell
            cell.childCount = group.childCount
            cell.code.text = "\(group.first)–\(group.last)"
            cell.desc.text = group.desc
            //cell.layoutIfNeeded()
            return cell
            
        case .Some(let category as Category):
            let cell = tableView.dequeueReusableCellWithIdentifier("browseCell", forIndexPath: indexPath) as! BrowseCell
            cell.childCount = category.childCount
            cell.codeWidth.constant = 44.0
            cell.code.text = category.first
            cell.desc.text = category.desc
            //cell.layoutIfNeeded()
            return cell
            
        case .Some(let subcategory as SubCategory):
            let cell = tableView.dequeueReusableCellWithIdentifier("browseCell", forIndexPath: indexPath) as! BrowseCell
            cell.childCount = 0
            cell.codeWidth.constant = 44.0
            cell.code.text = subcategory.first
            cell.desc.text = subcategory.desc
            //cell.layoutIfNeeded()
            return cell
        
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("browseCell", forIndexPath: indexPath) as! BrowseCell
            return cell
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


    // MARK: - Navigation
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let row = rowForIndexPath(indexPath)
        
        switch row {
        case .Some(let chapter as Chapter) where chapter.childCount > 0:
            return indexPath
        case .Some(let group as Group) where group.childCount > 0:
            return indexPath
        case .Some(let category as Category) where category.childCount > 0:
            return indexPath
        default: return nil
        }
    }

    /*
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return true
    }*/
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier {
        case .Some("browseSegue"): fallthrough
        case .Some("recursiveSegue"):
            let btvc = segue.destinationViewController as! BrowseTableViewController
            btvc.parent = selectedRow()
        default: break
        }
        
    }
}
