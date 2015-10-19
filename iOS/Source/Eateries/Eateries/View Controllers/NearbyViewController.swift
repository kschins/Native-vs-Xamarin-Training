//
//  NearbyViewController.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/19/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import UIKit
import MapKit

class NearbyViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView : MKMapView?
    var allVenues: [Venue]?
    
    let regionRadius: CLLocationDistance = 2000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Nearby", comment: "Nearby")
    }
    
    // MARK: - Location Methods and Displaying Annotations
    
    func centerMapOnLocation(location : CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView?.setRegion(coordinateRegion, animated: true)
    }

    func displayNearbyVenues(location: CLLocation) {
        var index = 0

        for venue in allVenues! {
            // check if location is nearby
            let venueLocation = CLLocation(latitude: (venue.address?.latitude?.doubleValue)!, longitude: (venue.address?.longitude?.doubleValue)!)
            let distance = venueLocation.distanceFromLocation(location)
            
            if distance < regionRadius {
                // add annotation
                let coordinate = CLLocationCoordinate2D(latitude: (venue.address?.latitude?.doubleValue)!, longitude: (venue.address?.longitude?.doubleValue)!)
                let venueAnnotation = VenueMapAnnotation(title: venue.name!, subtitle: venue.mainVenueCollectionName!, coordinate: coordinate, index: index)
                
                mapView?.addAnnotation(venueAnnotation)
            }
            
            index++
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let annotation = sender as! VenueMapAnnotation
        let selectedVenue = allVenues?[annotation.index]
        let venueVC = segue.destinationViewController as! VenueViewController
        venueVC.savedVenue = selectedVenue
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // zoom into current location and show if saved places are nearby
        centerMapOnLocation(userLocation.location!)
        
        // now display nearby venues, if any, within region
        displayNearbyVenues(userLocation.location!)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? VenueMapAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: -5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            }
        
            return view
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // open venue details
        let venueAnnotation = view.annotation as! VenueMapAnnotation
        performSegueWithIdentifier("Show Venue Details", sender: venueAnnotation)
    }
}
