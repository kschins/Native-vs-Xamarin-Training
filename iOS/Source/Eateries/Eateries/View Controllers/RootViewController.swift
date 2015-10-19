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
    let nonEditableRows = 3
    let editableSection = 1
    let numberOfSections = 2
    let allPlacesRow = 0
    let favoritesRow = 1
    let nearbyRow = 2
    
    // vars
    var venueCollections = [VenueCollection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load venue collections...first check if none exist - if not, add All Places & Favorites
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "VenueCollection")
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [VenueCollection]
            
            if fetchedResults?.count > 0 {
                // we are good
                venueCollections = fetchedResults!
            } else {
                // add All Places
                let allPlaces = VenueCollection.insertNewObject(managedContext)
                allPlaces.name = NSLocalizedString("All Places", comment: "All Places")
                allPlaces.iconImageName = "Cutlery"
                allPlaces.creationDate = NSDate()
                allPlaces.canDelete = NSNumber(bool: false)
                
                // add Favorites
                let favorites = VenueCollection.insertNewObject(managedContext)
                favorites.name = NSLocalizedString("Favorites", comment: "Favorites")
                favorites.iconImageName = "Unselected-Favorite"
                favorites.creationDate = NSDate()
                favorites.canDelete = NSNumber(bool: false)
                
                // add Nearby
                let nearby = VenueCollection.insertNewObject(managedContext)
                nearby.name = NSLocalizedString("Nearby", comment: "Nearby")
                nearby.iconImageName = "Current Location"
                nearby.creationDate = NSDate()
                nearby.canDelete = NSNumber(bool: false)
            
                // save
                appDelegate.saveContext()
                
                // add to local data source
                venueCollections.append(allPlaces)
                venueCollections.append(favorites)
                venueCollections.append(nearby)
            }
        } catch {
            print("Failed to save")
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if section == nonEditableSection {
            return nonEditableRows
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Venue Collection Cell", forIndexPath: indexPath) as! CollectionTableViewCell
            
        // Configure the cell...
        cell.collectionNameLabel?.text = venueCollection.name
        cell.collectionImageView?.image = UIImage(named: venueCollection.iconImageName!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // figure out segue
        let segueName: String
        
        if indexPath.section == nonEditableSection && indexPath.row == nearbyRow {
            segueName = "Show Nearby Places"
        } else {
            segueName = "Show Venue Collection"
        }
        
        // perform the right segue
        performSegueWithIdentifier(segueName, sender: nil)
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        if indexPath.section == nonEditableSection {
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
            
            // save
            appDelegate.saveContext()
            
            // delete the row from the data source
            venueCollections.removeAtIndex(indexPath.row + nonEditableRows)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Venue Collection" {
            let selectedIndexPath = tableView.indexPathForSelectedRow
            var currentCollection = selectedIndexPath!.row

            if selectedIndexPath?.section == editableSection {
                currentCollection += nonEditableRows
            }
            
            let venueCollectionViewController = segue.destinationViewController as! VenueCollectionViewController
            venueCollectionViewController.venueCollection = venueCollections[currentCollection]
            venueCollectionViewController.allPlacesCollection = venueCollections[allPlacesRow]
            venueCollectionViewController.favoritesCollection = venueCollections[favoritesRow]
        } else if segue.identifier == "Add New Collection Segue" {
            let navViewController = segue.destinationViewController as! UINavigationController
            let newVenueCollectionViewController = navViewController.viewControllers.first as! NewVenueCollectionViewController
            newVenueCollectionViewController.delegate = self
        }
    }
    
    // MARK: - New Venue Collection Protocol
    func newVenueCollectionAdded(venueCollection: VenueCollection) {
        // add venue collection to array
        venueCollections.append(venueCollection)
        tableView.reloadData()
    }
}
