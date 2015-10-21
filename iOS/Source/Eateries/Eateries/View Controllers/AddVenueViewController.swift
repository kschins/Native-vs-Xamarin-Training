//
//  AddVenueViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 6/13/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreLocation

protocol VenueAddedToCollectionProtocol {
    func addVenueToCollection(newVenue: FSVenue)
}

class AddVenueViewController: UITableViewController, UITextFieldDelegate, VenueAddedProtocol {

    // variables
    var searchedPlaces = [FSVenue]()
    var initialLoad = true
    var currentLocation: CLLocation?
    var delegate: VenueAddedToCollectionProtocol?
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
    
    // location
    var theLocationManager: LocationManager!
    
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
        
        // init location manager
        theLocationManager = LocationManager(callback: {theLocation in
            // do something with the location
            self.currentLocation = theLocation
            self.locationTextField.placeholder = NSLocalizedString("Currently Using Your Current Location", comment: "Current Location Placeholder")
        })
        
        // need to get current location, ask user if we can use their location to make searching for venues easier
        let locationStatus = LocationManager.accessToUserLocation()
        
        if locationStatus == .Success {
            // get current location
            theLocationManager.getUsersCurrentLocation()
        } else {
            // handle error appropriately
            showUserLocationDialog(locationStatus)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // show keyboard for name
        if initialLoad {
            queryTextField.becomeFirstResponder()
            initialLoad = false
        }
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
            let cell = tableView.dequeueReusableCellWithIdentifier("Name Cell", forIndexPath: indexPath) 
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
            let cell = tableView.dequeueReusableCellWithIdentifier("Search Cell", forIndexPath: indexPath) 
            searchLabel = cell.viewWithTag(labelTag) as? UILabel
            activityIndicator = cell.viewWithTag(activityIndicatorTag) as? UIActivityIndicatorView
            
            return cell
        } else {
            // results
            let cell = tableView.dequeueReusableCellWithIdentifier("Venue Cell", forIndexPath: indexPath) 
            
            // Configure the cell...
            let currentVenue = searchedPlaces[indexPath.row]
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
        let indexPath = tableView.indexPathForSelectedRow
        let selectedVenue = searchedPlaces[indexPath!.row]
        venueVC.venue = selectedVenue
        venueVC.addVenue = true
        venueVC.delegate = self
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
        
        if locationTextField.text!.isEmpty {
            // use current location, if there is one
            if currentLocation == nil {
                // user must manually enter in location, or we need to fetch for the current location again
                print("No location to use for search...")
                self.activityIndicator.stopAnimating()
                self.searchLabel.hidden = false
            } else {
                // search by lat and long
                let latitude = currentLocation!.coordinate.latitude
                let longitude = currentLocation!.coordinate.longitude
                
                venueSearch.fetchVenues(queryTerm!, latitude: latitude, longitude: longitude, completionClosure: {venues in
                    // update table view and venues
                    self.searchedPlaces = venues
                    self.tableView.reloadData()
                    
                    // reset search views
                    self.activityIndicator.stopAnimating()
                    self.searchLabel.hidden = false
                })
            }
        } else {
            // use text from location text field
            venueSearch.fetchVenues(queryTerm!, location: locationTextField.text!, completionClosure: {venues in
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
    
    // MARK: - VenueAddedProtocol
    
    func newVenueAdded(newVenue: FSVenue) {
        delegate?.addVenueToCollection(newVenue)
        
        // dismiss
        dismissView()
    }
    
    // MARK: - User Location Access Handling
    
    func showUserLocationDialog(locationStatus : LocationAccessStatus) {
        if locationStatus == .Denied {
            // point user to settings so they can turn this feature on
            let alertController = UIAlertController(title: NSLocalizedString("Location services have been denied for use by Eateries.", comment: "Location Denied"), message: NSLocalizedString("You can allow your location to be used by tapping the Settings button.", comment: "Settings Explanation"), preferredStyle: UIAlertControllerStyle.Alert)
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: UIAlertActionStyle.Cancel, handler: {(alert: UIAlertAction!) in
                // take user to settings app
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.Default, handler: nil)
            
            // add actions
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            // show
            presentViewController(alertController, animated: true, completion: nil)
        } else if locationStatus == .Disabled {
            // device doesn't support location
            let alertController = UIAlertController(title: NSLocalizedString("Location services are turned off or not available on this device.", comment: "Location Unavailable"), message: NSLocalizedString("If they are turned off, you can turn them back on in Settings.", comment: "Location Unavailable Settings"), preferredStyle: UIAlertControllerStyle.Alert)
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: UIAlertActionStyle.Cancel, handler: {(alert: UIAlertAction!) in
                // take user to settings app
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.Default, handler: nil)
            
            // add actions
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            // show
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // undetermined, explain why we need access then request it if they allow us
            let alertController = UIAlertController(title: NSLocalizedString("Eateries has not been given access to use your location yet. Do you want to give Eateries access to your location?", comment: "Location Permission"), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: UIAlertActionStyle.Cancel, handler: {(alert: UIAlertAction) in
                // request location
                self.theLocationManager.getUsersCurrentLocation()
            })
            
            let noAction = UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: UIAlertActionStyle.Default, handler: nil)
            
            // add actions
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            // show
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
