//
//  CollectionInterfaceController.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/20/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import WatchKit

class CollectionInterfaceController: WKInterfaceController {
    @IBOutlet weak var venuesTable: WKInterfaceTable!
    
    var collection: String!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let collection = context as? String {
            self.collection = collection
            setTitle(collection)
        }
    }
}