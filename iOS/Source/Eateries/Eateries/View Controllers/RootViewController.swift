//
//  RootViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 5/28/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreData

class RootViewController: UITableViewController, NewVenueCollectionProtocol {

    // constants
    let nonEditableSection = 0
    let nonEditableRows = 2
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
            allPlacesCollection.setValue("Cutlery", forKey: "iconImageName")
            
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
            return venueCollections.count - nonEditableRows
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // venue collection
        var currentCollection: Int = indexPath.row
        
        if indexPath.section == editableSection {
            currentCollection = indexPath.row + nonEditableRows
        }
        
        let venueCollection = venueCollections[currentCollection]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Venue Collection Cell", forIndexPath: indexPath) as! UITableViewCell
            
        // Configure the cell...
        cell.textLabel?.text = venueCollection.valueForKey("name") as? String
        cell.imageView?.image = UIImage(named: (venueCollection.valueForKey("iconImageName") as? String)!)
        
        return cell
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
            // delete from core data - can only delete from this section so need to add 2
            let objectToDelete = venueCollections[indexPath.row + nonEditableRows]
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(objectToDelete)
            
            // save this change
            var error : NSError?
            
            // save
            if !managedContext.save(&error) {
                    
            }
            
            // delete the row from the data source
            venueCollections.removeAtIndex(indexPath.row + nonEditableRows)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Venue Collection Segue" {
            let selectedIndexPath = tableView.indexPathForSelectedRow()
            var currentCollection = selectedIndexPath!.row

            if selectedIndexPath?.section == editableSection {
                currentCollection += nonEditableRows
            }
            
            let selectedVenueCollection = venueCollections[currentCollection]
            let venueCollectionViewController = segue.destinationViewController as! VenueCollectionViewController
            venueCollectionViewController.venueCollection = (selectedVenueCollection as! VenueCollection)
        } else if segue.identifier == "Add New Collection Segue" {
            let navViewController = segue.destinationViewController as! UINavigationController
            let newVenueCollectionViewController = navViewController.viewControllers.first as! NewVenueCollectionViewController
            newVenueCollectionViewController.delegate = self
        }
    }
    
    // MARK: - New Venue Collection Protocol
    func newVenueCollectionAdded(venueCollection: NSManagedObject) {
        // add venue collection to array
        venueCollections.append(venueCollection)
        tableView.reloadData()
    }
}
