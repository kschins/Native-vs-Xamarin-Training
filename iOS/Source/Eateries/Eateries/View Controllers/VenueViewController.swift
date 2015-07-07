//
//  VenueViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/6/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit

class VenueViewController : UITableViewController {
    
    var venue: FSVenue?
    
    // constants
    let venueNameRow = 0
    let venuePhoneRow = 1
    let venueWebsiteRow = 2
    let venueAddressRow = 3
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // add save button in right bar button if coming from add venue view controller
        
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        // Configure the cell...
        switch (indexPath.row) {
            case venueNameRow:
                cell.textLabel?.text = venue?.name
            case venuePhoneRow:
                cell.textLabel?.text = venue?.telephone
            case venueWebsiteRow:
                cell.textLabel?.text = venue?.website
            case venueAddressRow:
                cell.textLabel?.text = venue?.address
            default:
                cell.textLabel?.text = ""
        }
        
        return cell
    }
}