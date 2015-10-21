//
//  VenueCollectionViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 6/13/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit

class VenueCollectionViewController: UITableViewController, VenueAddedToCollectionProtocol {

    var venueCollection : VenueCollection!
    var allPlacesCollection : VenueCollection!
    var favoritesCollection : VenueCollection!
    var venues = [Venue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // title
        title = venueCollection!.valueForKey("name") as? String
        
        // sort venues alphabetically to display better
        venues = sortVenuesAlphabetically()
    }

    // MARK: - Private
    
    func sortVenuesAlphabetically() -> [Venue] {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true);
        
        return venueCollection.venues?.sortedArrayUsingDescriptors([sortDescriptor]) as! [Venue]
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return venues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // grab current venue
        let venue = venues[indexPath.row]

        if (allPlacesCollection == venueCollection || favoritesCollection == venueCollection) {
            let cell = tableView.dequeueReusableCellWithIdentifier("All Venues Cell", forIndexPath: indexPath)
            
            // configure cell...
            cell.textLabel?.text = venue.name
            cell.detailTextLabel?.text = venue.mainVenueCollectionName
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Venue Cell", forIndexPath: indexPath)

            // Configure the cell...
            cell.textLabel?.text = venue.name
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (allPlacesCollection == venueCollection) {
            return false
        } else {
            return true
        }
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let venue = venues[indexPath.row]
        
        var favoriteAction: UITableViewRowAction
        
        if favoritesCollection == venueCollection {
            favoriteAction = UITableViewRowAction(style: .Default, title: "Remove") { (action, indexPath) -> Void in
                // remove venue from favorites collection
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                venue.favorite = NSNumber(bool: false)
                self.favoritesCollection.removeVenue(venue)
                
                // save
                appDelegate.saveContext()
                
                // remove row
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            return [favoriteAction]
        } else {
            if (venue.favorite?.boolValue == true) {
                favoriteAction = UITableViewRowAction(style: .Normal, title: "Un-Favorite") { (action, indexPath) -> Void in
                    // remove venue from favorites collection
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    venue.favorite = NSNumber(bool: false)
                    self.favoritesCollection.removeVenue(venue)
                    
                    // save
                    appDelegate.saveContext()
                    
                    // remove row
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            } else {
                favoriteAction = UITableViewRowAction(style: .Normal, title: "Favorite") { (action, indexPath) -> Void in
                    self.editing = false
                    
                    // add venue to favorites collection
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    venue.favorite = NSNumber(bool: true)
                    self.favoritesCollection.addVenue(venue)
                    
                    // save
                    appDelegate.saveContext()
                }
            }
            
            let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
                // delete from core data - can only delete from this section
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext!
                managedContext.deleteObject(venue)
                
                // save
                appDelegate.saveContext()
                
                // delete the row from the data source
                self.venueCollection.removeVenue(venue)
                self.allPlacesCollection.removeVenue(venue)
                self.favoritesCollection.removeVenue(venue)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            return [deleteAction, favoriteAction]
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Add Venue Segue" {
            let navViewController = segue.destinationViewController as! UINavigationController
            let newVenueViewController = navViewController.viewControllers.first as! AddVenueViewController
            newVenueViewController.delegate = self
        } else {
            let selectedIndexPath = tableView.indexPathForSelectedRow
            let selectedVenue = venues[selectedIndexPath!.row]
            let venueVC = segue.destinationViewController as! VenueViewController
            venueVC.savedVenue = selectedVenue
        }
    }
    
    // MARK: - VenueAddedToCollectionProtocol
    
    func addVenueToCollection(newVenue: FSVenue) {
        // create Venue from FSVenue
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // setup new venue - add collection
        let venue = newVenue.createVenue(managedContext)
        venue.mainVenueCollectionName = venueCollection.name
        
        // add venue to necessary collections
        venueCollection.addVenue(venue)
        allPlacesCollection.addVenue(venue)
        
        // save
        appDelegate.saveContext()
        
        // sort venues
        venues = sortVenuesAlphabetically()

        // reload table view
        tableView.reloadData()
    }
}
