//
//  NewVenueCollectionViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 6/11/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreData

class NewVenueCollectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    // MARK: - IBOutlets and Local Variables
    @IBOutlet weak var tableView : UITableView?
    @IBOutlet weak var collectionView : UICollectionView?
    weak var nameTextField : UITextField?
    var selectedIndexPathForIcon : NSIndexPath?
    
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
        cell.layer.cornerRadius = 25.0
        cell.iconImageView?.image = UIImage(named: iconNames[indexPath.row] as! String)
        
        if (selectedIndexPathForIcon != nil && selectedIndexPathForIcon?.row == indexPath.row) {
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
        
        // save selected index path
        selectedIndexPathForIcon = indexPath
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
        if (section == nonSwipeableSection) {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == nonSwipeableSection) {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Name Cell", forIndexPath: indexPath) as! UITableViewCell
        
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
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "Venue Collection Segue") {
            //VenueCollectionViewController collectionVC = segue.destinationViewController
            
        }
    }
    
    // MARK: - IBActions
    @IBAction func dismissView() {
        nameTextField?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveVenue() {
        // save
        
        // now dismiss
        dismissView()
    }
}
