//
//  RootViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 5/28/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreData

class RootViewController: UITableViewController {

    // constants
    let nonEditableSection = 0
    let editableSection = 1
    let numberOfSections = 2
    
    // vars
    var venueCollections = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load venue collections...first check if none exist - if not, add All Places & Favorites
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "VenueCollection")
        var error : NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]

        if fetchedResults?.count > 0 {
            // we are good
            venueCollections = fetchedResults!
        } else {
            // add All Places
            let venueCollectionEntity = NSEntityDescription.entityForName("VenueCollection", inManagedObjectContext: managedContext)
            let allPlacesCollection = NSManagedObject(entity: venueCollectionEntity!, insertIntoManagedObjectContext: managedContext)
            allPlacesCollection.setValue(NSLocalizedString("All Places", comment: "All Places"), forKey: "name")
            allPlacesCollection.setValue("All Places", forKey: "iconImageName")
            
            // add Favorites
            let favoritesCollection = NSManagedObject(entity: venueCollectionEntity!, insertIntoManagedObjectContext: managedContext)
            favoritesCollection.setValue(NSLocalizedString("Favorites", comment: "Favorites"), forKey: "name")
            favoritesCollection.setValue("Unselected-Favorite", forKey: "iconImageName")
            
            // save
            if !managedContext.save(&error) {
                
            }
            
            // add to local data source
            venueCollections.append(allPlacesCollection)
            venueCollections.append(favoritesCollection)
        }
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
            return venueCollections.count - 2
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // venue collection
        let venueCollection = venueCollections[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Venue Collection Cell", forIndexPath: indexPath) as! UITableViewCell
            
        // Configure the cell...
        cell.textLabel?.text = venueCollection.valueForKey("name") as? String
        cell.imageView?.image = UIImage(named: (venueCollection.valueForKey("iconImageName") as? String)!)
        
        return cell
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
        if segue.identifier == "Venue Collection Segue" {
            let selectedVenueCollection = venueCollections[0] as? VenueCollection
            let venueCollectionViewController = segue.destinationViewController as! VenueCollectionViewController
            venueCollectionViewController.venueCollection = selectedVenueCollection
        }
    }
}
