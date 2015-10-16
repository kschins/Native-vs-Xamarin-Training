//
//  VenueViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/6/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit

protocol VenueAddedProtocol {
    func newVenueAdded(newVenue : FSVenue)
}

class VenueViewController : UITableViewController {
    
    var savedVenue: Venue?
    var venue: FSVenue?
    var addVenue = false
    var delegate: VenueAddedProtocol?

    // constants
    let venueNameRow = 0
    let venuePhoneRow = 1
    let venueWebsiteRow = 2
    let venueTwitterRow = 3
    let venueAddressRow = 4
    let venueDetailRows = 5
    let venueSearchAPI = VenueSearchAPI()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let venue = venue {
            // fetch all details for this venue since not all vital information is sent when searching venues
            venueSearchAPI.fetchVenue(venue.venueID, completionClosure: {(venue, success) in
                // only one venue
                if success {
                    self.venue = venue
                    
                    // update table view
                    self.tableView.reloadData()
                } else {
                    print("Error retrieving venue details.")
                }
            })
        } else {
            // remove save button since just viewing details
            if !addVenue {
                navigationItem.rightBarButtonItem = nil
            }
            
            venue = FSVenue(venue: savedVenue!)
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return venueDetailRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! VenueDetailCell
        
        // Configure the cell...
        switch (indexPath.row) {
        case venueNameRow:
            cell.headerLabel?.text = NSLocalizedString("NAME", comment: "NAME")
            cell.infoLabel?.text = venue?.name
        case venuePhoneRow:
            cell.headerLabel?.text = NSLocalizedString("PHONE", comment: "PHONE")
            cell.infoLabel?.text = venue?.telephone
        case venueWebsiteRow:
            cell.headerLabel?.text = NSLocalizedString("WEBSITE", comment: "WEBSITE")
            cell.infoLabel?.text = venue?.website
        case venueTwitterRow:
            cell.headerLabel?.text = NSLocalizedString("TWITTER", comment: "TWITTER")
            cell.infoLabel?.text = venue?.twitter
        case venueAddressRow:
            cell.headerLabel?.text = NSLocalizedString("ADDRESS", comment: "ADDRESS")
            cell.infoLabel?.text = venue?.address
        default:
            cell.headerLabel?.text = ""
            cell.infoLabel?.text = ""
        }
        
        return cell
    }
    
    // MARK: - IBActions
    @IBAction func saveVenue() {
        // pass venue to be added to delegate
        delegate?.newVenueAdded(venue!)
        
        // dismiss view once saved
        dismissViewControllerAnimated(true, completion: nil)
    }
}