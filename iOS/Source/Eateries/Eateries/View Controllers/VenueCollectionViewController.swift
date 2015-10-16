//
//  VenueCollectionViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 6/13/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit

class VenueCollectionViewController: UITableViewController, VenueAddedToCollectionProtocol {

    var venueCollection : VenueCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // title
        title = venueCollection!.valueForKey("name") as?  String
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return venueCollection!.venues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Venue Cell", forIndexPath: indexPath) 

        // Configure the cell...
        let venue = venueCollection!.venues.allObjects[indexPath.row] as? Venue
        cell.textLabel?.text = venue?.name
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // delete from core data - can only delete from this section so need to add 2
            let objectToDelete = venueCollection?.venues.allObjects[indexPath.row] as! Venue
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(objectToDelete)
            
            // save
            appDelegate.saveContext()
            
            // delete the row from the data source
            venueCollection?.removeVenue(objectToDelete)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Venue Detail Segue" {
            let selectedIndexPath = tableView.indexPathForSelectedRow
            let selectedVenue = venueCollection?.venues.allObjects[selectedIndexPath!.row] as? Venue
            let venueVC = segue.destinationViewController as! VenueViewController
            venueVC.savedVenue = selectedVenue
        } else if segue.identifier == "Add Venue Segue" {
            let navViewController = segue.destinationViewController as! UINavigationController
            let newVenueViewController = navViewController.viewControllers.first as! AddVenueViewController
            newVenueViewController.delegate = self
        }
    }
    
    // MARK: - VenueAddedToCollectionProtocol
    func addVenueToCollection(newVenue: FSVenue) {
        // create Venue from FSVenue
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // setup new venue - add collection
        let venue = newVenue.createVenue(managedContext)
        
        // add venue to necessary collections
        venueCollection?.addVenue(venue)
        
        // save
        appDelegate.saveContext()
        
        // reload table view
        tableView.reloadData()
    }
}
