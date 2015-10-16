//
//  VenueViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/6/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import SafariServices
import MapKit

protocol VenueAddedProtocol {
    func newVenueAdded(newVenue : FSVenue)
}

class VenueViewController : UITableViewController, SFSafariViewControllerDelegate {
    
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
        
        // title
        title = venue?.name
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
            cell.selectionStyle = .None
        case venuePhoneRow:
            cell.headerLabel?.text = NSLocalizedString("PHONE", comment: "PHONE")
            cell.infoLabel?.text = venue?.telephone
        case venueWebsiteRow:
            cell.headerLabel?.text = NSLocalizedString("WEBSITE", comment: "WEBSITE")
            
            if let website = venue?.website {
                cell.infoLabel?.text = "@\(website)"
            } else {
                cell.infoLabel?.text = ""
            }
        case venueTwitterRow:
            cell.headerLabel?.text = NSLocalizedString("TWITTER", comment: "TWITTER")
            
            if let twitter = venue?.twitter {
                cell.infoLabel?.text = "@\(twitter)"
            } else {
                cell.infoLabel?.text = ""
            }
        case venueAddressRow:
            cell.headerLabel?.text = NSLocalizedString("ADDRESS", comment: "ADDRESS")
            cell.infoLabel?.text = venue?.displayAddress()
        default:
            cell.headerLabel?.text = ""
            cell.infoLabel?.text = ""
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case venuePhoneRow:
            // call - if number is valid
            let phone = venue?.strippedVenueTelephone()
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + phone!)!)
        case venueWebsiteRow:
            // open safari
            openWithSafariVC((venue?.website)!)
        case venueTwitterRow:
            // open twitter in safari
            let twitterURL = "https://twitter.com/" + (venue?.twitter)!
            openWithSafariVC(twitterURL)
        case venueAddressRow:
            // open apple maps
            let regionDistance: CLLocationDistance = 1000
            let coordinates = CLLocationCoordinate2DMake((venue?.latitude)!, (venue?.longitude)!)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = venue?.name
            mapItem.openInMapsWithLaunchOptions(options)
        default:
            break
        }
        
        // deselect row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == venueAddressRow {
            return 80
        } else {
            return 55
        }
    }
    
    // MARK: - IBActions
    @IBAction func saveVenue() {
        // pass venue to be added to delegate
        delegate?.newVenueAdded(venue!)
        
        // dismiss view once saved
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private Methods
    func openWithSafariVC(urlString: String) {
        let svc = SFSafariViewController(URL: NSURL(string: urlString)!)
        svc.delegate = self
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    // MARK: - SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}