//
//  RootViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 5/28/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {

    // constants
    let nonEditableSection = 0
    let editableSection = 1
    let numberOfSections = 2
    
    // categories
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load venue collections...first check if none exist - if not, add All Places & Favorites
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if (section == nonEditableSection) {
            return numberOfSections
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("Nonswipeable Venue Collection Cell", forIndexPath: indexPath) as! UITableViewCell
            
            // Configure the cell...
            cell.textLabel?.text = "Collection Name"
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Swipeable Venue Collection Cell", forIndexPath: indexPath) as! UITableViewCell
            
            // Configure the cell...
            cell.textLabel?.text = "Collection Name"
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        if (indexPath.section == nonEditableSection) {
            return false
        } else {
            return true
        }
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
}
