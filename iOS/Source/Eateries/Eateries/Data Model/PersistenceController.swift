//
//  PersistenceController.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/1/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import CoreData

class PersistenceController: NSObject {
   
    typealias CallbackClosure = Void -> Void
    private(set) var managedObjectContext : NSManagedObjectContext?
    private var privateContext : NSManagedObjectContext?
    private var initCallback : CallbackClosure?
    
    init(callback: CallbackClosure) {
        super.init()
        self.initCallback = callback
        self.initializeCoreData()
    }
    
    func save() {
        
    }
    
    // MARK: - Private
    private func initializeCoreData() {
        
    }
}
