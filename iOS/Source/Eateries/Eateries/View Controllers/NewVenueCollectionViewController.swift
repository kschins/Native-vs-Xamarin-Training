//
//  NewVenueCollectionViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 6/11/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreData

protocol NewVenueCollectionProtocol {
    func newVenueCollectionAdded(venueCollection : VenueCollection)
}

class NewVenueCollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    // MARK: - IBOutlets and Local Variables
    @IBOutlet weak var tableView : UITableView?
    @IBOutlet weak var collectionView : UICollectionView?
    weak var nameTextField : UITextField!
    var selectedIcon : Int?
    var delegate: NewVenueCollectionProtocol?
    
    // MARK: - Constants
    let textFieldTag = 99
    let nonSwipeableSection = 0
    let swipeableSection = 1
    let iconNames: NSArray = ["Airplane", "Arena", "Barley", "Beach", "Beer Bottle", "Beer Glass", "Beer Mug", "Bento", "Big Ben", "Birthday Cake", "Bread", "Campfire", "Candy", "Capitol", "Car", "Carrot", "Champagne", "Cheese", "Chicken", "Cinnamon Roll", "Citrus", "City", "Cocktail", "Coconut Cocktail", "Coffee To Go", "Coffee", "Cookies", "Cooking Pot", "Corkscrew", "Crab", "Cruise Ship", "Cupcake", "Cutlery", "Doughnut", "Duck", "Eggs", "Eiffel Tower", "Farm", "Father", "Fish", "Flippers", "Forest", "French Fries", "Grapes", "Guitar", "Hamburger", "Heart", "Hot Chocolate", "Hot Dog", "Ice Cream bowl", "Kebab", "Lamb Rack", "Log Cabin", "Microphone", "Milk", "Mother", "Museum", "Music Transcript", "Noodles", "Pacifier", "Pastry Bag", "Peanuts", "Picnic", "Pig", "Pizza", "Pretzel", "Rabbit", "Railroad Car", "Saxophone", "Shrimp", "Sombrero", "Soy", "Spaghetti", "Statue of Liberty", "Steak", "Strawberry", "Suitcase", "Sushi", "Taco", "Taj Mahal", "Tea", "Teapot", "Tomato", "Vegan Food", "Water Bottle", "Wine Bottle", "Wine Glass", "Wrap", "Yacht"]
    
    // MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconNames.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Icon Cell", forIndexPath: indexPath) as! IconCollectionViewCell
        cell.layer.cornerRadius = 20.0
        cell.iconImageView?.image = UIImage(named: iconNames[indexPath.row] as! String)
        
        if (selectedIcon != nil && selectedIcon == indexPath.row) {
            cell.contentView.backgroundColor = UIColor.lightGrayColor()
        } else {
            cell.contentView.backgroundColor = nil
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // resign text field in case it was still showing
        nameTextField?.resignFirstResponder()
        
        // highlight selected item
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor.lightGrayColor()
        
        // save selected icon
        selectedIcon = indexPath.row
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // remove selection
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = nil
    }

    // MARK: - UITableViewDelegate & UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if section == nonSwipeableSection {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == nonSwipeableSection {
            return NSLocalizedString("Collection Name", comment: "Collection Name")
        }
        else {
            return NSLocalizedString("Collection Icon", comment: "Collection Icon")
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Name Cell", forIndexPath: indexPath) 
        
        // Configure the cell...
        nameTextField = cell.viewWithTag(textFieldTag) as? UITextField
        nameTextField?.delegate = self
        
        return cell
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - IBActions
    @IBAction func dismissView() {
        nameTextField?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveVenue() {
        // save - verify name and image are selected
        if nameTextField.text!.isEmpty {
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("A venue collection name is required.", comment: "Venue Collection Name Error"), preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            
            // show
            presentViewController(alertController, animated: true, completion: nil)
        } else if selectedIcon == nil {
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("A venue collection icon is required.", comment: "Venue Collection Icon Error"), preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            
            // show
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // actually save
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            let newCollection = VenueCollection.insertNewObject(managedContext)
            newCollection.name = nameTextField.text!
            newCollection.iconImageName = iconNames[selectedIcon!] as! String
            newCollection.creationDate = NSDate()
            newCollection.canDelete = NSNumber(bool: true)
            
            // save
            appDelegate.saveContext()
            
            // protocol called
            delegate?.newVenueCollectionAdded(newCollection)
            
            // now dismiss
            dismissView()
        }
    }
}
