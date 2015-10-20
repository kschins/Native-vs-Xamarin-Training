//
//  InterfaceController.swift
//  watchEateries Extension
//
//  Created by Kasey Schindler on 10/20/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var collectionsTable: WKInterfaceTable!
    var collections = ["Chicago", "Sushi", "Pizza"]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        reloadTable()
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String,
        inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
            if segueIdentifier == "CollectionDetails" {
                let name = collections[rowIndex]
                
                return name
            }
            
            return nil
    }
    
    // MARK: - Displaying Data
    
    func reloadTable() {
        if collectionsTable.numberOfRows != collections.count {
            collectionsTable.setNumberOfRows(collections.count, withRowType: "CollectionRow")
        }
        
        var index = 0
        for name in collections {
            if let row = collectionsTable.rowControllerAtIndex(index) as? CollectionRow {
                row.collectionNameLabel.setText(name)
            }
            
            index++
        }
    }

}
