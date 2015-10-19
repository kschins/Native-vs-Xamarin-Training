//
//  VenueMapAnnotation.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/19/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import MapKit

class VenueMapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let index: Int
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, index: Int) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.index = index
        
        super.init()
    }
}
