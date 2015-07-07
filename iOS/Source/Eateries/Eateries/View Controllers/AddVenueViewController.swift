//
//  AddVenueViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 6/13/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreLocation

class AddVenueViewController: UITableViewController, UITextFieldDelegate {

    // variables
    var searchedPlaces = [FSVenue]()
    var currentLocation: CLLocation?
    weak var queryTextField : UITextField!
    weak var locationTextField : UITextField!
    weak var searchLabel : UILabel!
    weak var activityIndicator : UIActivityIndicatorView!
    
    // constants
    let venueSearch = VenueSearchAPI()
    let searchTermRow = 0
    let locationRow = 1
    let querySection = 0
    let searchSection = 1
    let resultsSection = 2
    
    // view tags
    let textfieldTag = 99
    let activityIndicatorTag = 100
    let labelTag = 101
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        title = "Venue Search"
        
        // offset table view to hide Foursquare
        tableView.contentInset = UIEdgeInsetsMake(-50.0, 0, 0, 0);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // dismiss keyboard, if showing
        queryTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        if searchedPlaces.count > 0 {
            return 3
        } else {
            return 2
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if section == resultsSection {
            return searchedPlaces.count
        } else if section == querySection {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == querySection {
            let cell = tableView.dequeueReusableCellWithIdentifier("Name Cell", forIndexPath: indexPath) as! UITableViewCell
            let cellTextField = cell.viewWithTag(textfieldTag) as? UITextField
            cellTextField?.delegate = self
            
            if indexPath.row == searchTermRow {
                // query
                queryTextField = cellTextField
                queryTextField.returnKeyType = UIReturnKeyType.Next
                queryTextField.placeholder = NSLocalizedString("Name, category, or cuisine", comment: "Query TextField Placeholder")
            } else {
                // location
                locationTextField = cellTextField
                locationTextField.returnKeyType = UIReturnKeyType.Search
                
                // set placeholder text
                if currentLocation == nil {
                    locationTextField.placeholder = NSLocalizedString("City, State, and/or Postal Code", comment: "No Location Placeholder")
                } else {
                    locationTextField.placeholder = NSLocalizedString("Currently Using Your Current Location", comment: "Current Location Placeholder")
                }
            }
            
            return cell
        } else if indexPath.section == searchSection {
            let cell = tableView.dequeueReusableCellWithIdentifier("Search Cell", forIndexPath: indexPath) as! UITableViewCell
            searchLabel = cell.viewWithTag(labelTag) as? UILabel
            activityIndicator = cell.viewWithTag(activityIndicatorTag) as? UIActivityIndicatorView
            
            return cell
        } else {
            // results
            let cell = tableView.dequeueReusableCellWithIdentifier("Venue Cell", forIndexPath: indexPath) as! UITableViewCell
            
            // Configure the cell...
            var currentVenue = searchedPlaces[indexPath.row]
            cell.textLabel?.text = currentVenue.name
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == searchSection {
            // execute search
            queryForVenues()
        }
        
        // deselect
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == resultsSection {
            return NSLocalizedString("Results", comment: "Results")
        } else {
            return ""
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // pass venue to detail view
        let venueVC = segue.destinationViewController as! VenueViewController
        let indexPath = tableView.indexPathForSelectedRow()
        let selectedVenue = searchedPlaces[indexPath!.row]
        venueVC.venue = selectedVenue
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func queryForVenues() {
        // resign keyboards
        queryTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        
        // hide label and show activity indicator
        searchLabel.hidden = true
        activityIndicator.startAnimating()
        
        // put together search items
        let queryTerm = queryTextField.text
        
        if locationTextField.text.isEmpty {
            // use current location, if there is one
        } else {
            // use text from location text field
            venueSearch.fetchVenues(queryTerm, location: locationTextField.text, completionClosure: {venues in
                // update table view and venues
                self.searchedPlaces = venues
                self.tableView.reloadData()
                
                // reset search views
                self.activityIndicator.stopAnimating()
                self.searchLabel.hidden = false
            })
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == queryTextField {
            locationTextField.becomeFirstResponder()
        } else {
            locationTextField.resignFirstResponder()
            
            // search
            queryForVenues()
        }
        
        return true
    }
}
