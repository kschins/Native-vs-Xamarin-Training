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
    var venue: FSVenue!
    var addVenue = false
    var delegate: VenueAddedProtocol?
    var loadingVenueInformation = true
    
    // constants
    let venueNameRow = 0
    let venuePhoneRow = 1
    let venueWebsiteRow = 2 // don't show this row if venue doesn't contain this information
    let venueTwitterRow = 3 // don't show this row if venue doesn't contain this information
    let venuePriceRow = 4
    let venueAddressRow = 5
    let venueDetailRows = 6
    let venueSearchAPI = VenueSearchAPI()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let venue = venue {
            // fetch all details for this venue since not all vital information is sent when searching venues
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show()
            
            venueSearchAPI.fetchVenue(venue.venueID, completionClosure: {(venue, success) in
                // no longer loading
                self.loadingVenueInformation = false
                PKHUD.sharedHUD.hide(animated: false)
                
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
            // not loading anything
            loadingVenueInformation = false
            
            // remove save button since just viewing details
            if !addVenue {
                navigationItem.rightBarButtonItem = nil
                
                // set right navigation item to share button
                let shareItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareButtonTapped")
                navigationItem.rightBarButtonItem = shareItem
            }
            
            venue = FSVenue(venue: savedVenue!)
        }
        
        // title
        title = venue.name
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if loadingVenueInformation {
            return 0
        } else {
            
            return venueDetailRows
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! VenueDetailCell
        
        // Configure the cell...
        switch (indexPath.row) {
        case venueNameRow:
            cell.headerLabel?.text = NSLocalizedString("NAME", comment: "NAME")
            cell.infoLabel?.text = venue.name
            cell.selectionStyle = .None
        case venuePhoneRow:
            cell.headerLabel?.text = NSLocalizedString("PHONE", comment: "PHONE")
            cell.infoLabel?.text = venue.telephone
        case venueWebsiteRow:
            cell.headerLabel?.text = NSLocalizedString("WEBSITE", comment: "WEBSITE")
            
            if let website = venue.website {
                cell.infoLabel?.text = website
            } else {
                cell.infoLabel?.text = ""
            }
        case venueTwitterRow:
            cell.headerLabel?.text = NSLocalizedString("TWITTER", comment: "TWITTER")
            
            if let twitter = venue.twitter {
                cell.infoLabel?.text = "@\(twitter)"
            } else {
                cell.infoLabel?.text = ""
            }
        case venuePriceRow:
            cell.selectionStyle = .None
            cell.headerLabel?.text = NSLocalizedString("PRICE", comment: "PRICE")
            cell.infoLabel?.attributedText = venue.displayPrice()
        case venueAddressRow:
            cell.headerLabel?.text = NSLocalizedString("ADDRESS", comment: "ADDRESS")
            cell.infoLabel?.text = venue.displayAddress()
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
            if venue.telephone != nil {
                let phone = venue.strippedVenueTelephone()
                UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + phone)!)
            }
        case venueWebsiteRow:
            // open safari
            if let url = venue.website {
                openWithSafariVC(url)
            }
        case venueTwitterRow:
            // open twitter in safari
            if let url = venue.twitter {
                let twitterURL = "https://twitter.com/" + url
                openWithSafariVC(twitterURL)
            }
        case venueAddressRow:
            // open apple maps
            if let lat = venue.latitude, long = venue.longitude {
                let regionDistance: CLLocationDistance = 1000
                let coordinates = CLLocationCoordinate2DMake(lat, long)
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = venue.name
                mapItem.openInMapsWithLaunchOptions(options)
            }
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
    
    func shareButtonTapped() {
        let textToShare = venue!.name
        
        if let linkToShare = venue!.website {
            let shareSheet = UIActivityViewController(activityItems: [textToShare, linkToShare], applicationActivities: nil)
            presentViewController(shareSheet, animated: true, completion: nil)
        } else {
            let shareSheet = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            presentViewController(shareSheet, animated: true, completion: nil)
        }
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}