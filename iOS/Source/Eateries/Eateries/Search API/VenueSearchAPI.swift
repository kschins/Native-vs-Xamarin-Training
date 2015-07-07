//
//  VenueSearchAPI.swift
//  Eateries
//
//  Created by Kasey Schindler on 6/11/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation

enum VenueSearchError: Int {
    case BadRequest = 400
    case Unauthorized = 401
    case Forbidden = 403
    case NotFound = 404
    case MethodNotAllowed = 405
    case Conflict = 409
    case InternalServerError = 500
}

class VenueSearchAPI {
    // keys and URLs
    private let CLIENT_ID = "TKLBXOOZPWRUWWJ0LNXAEPVK4PVYIRXSRTGX5YCEFI2HRAVA"
    private let CLIENT_SECRET = ""
    private let VENUE_SEARCH_API_ENDPOINT = "https://api.foursquare.com/v2/venues/search"
    private let VENUE_EXPLORE_API_ENDPOINT = "https://api.foursquare.com/v2/venues/explore"
    private let VENUE_ID_API_ENDPOINT = "https://api.foursquare.com/v2/venues/"
    private let config: NSURLSessionConfiguration
    private let session: NSURLSession
    
    typealias VenueArrayCompletionClosure = (Array<FSVenue>) -> ()
    
    // MARK: - Initialization
    init() {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.HTTPAdditionalHeaders = ["Accept" : "application/json"]
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        sessionConfig.HTTPMaximumConnectionsPerHost = 1
        self.session = NSURLSession(configuration: sessionConfig)
        self.config = sessionConfig
    }
    
    // MARK: - Public Venue API using Foursquare
    
    func fetchVenues(queryTerm: String, location: String, completionClosure: VenueArrayCompletionClosure) {
        // setup URL
        let stringURL = VENUE_SEARCH_API_ENDPOINT + "?near=" + encodeString(location) + "&query=" + encodeString(queryTerm) + "&" + foursquareAPIEnding()
        println(stringURL)
        let url = NSURL(string: stringURL)
        
        // execute
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    self.parseVenuesFromJSON(data, completionClosure: completionClosure)
                default:
                    println("Got an HTTP \(httpResponse.statusCode)")
                    dispatch_async(dispatch_get_main_queue(), {
                        completionClosure([FSVenue]())
                    })
                }
            } else {
                // completion handler
                dispatch_async(dispatch_get_main_queue(), {
                    completionClosure([FSVenue]())
                })
            }
        })
        
        task.resume()
    }
    
    func fetchVenues(queryTerm: String, latitude: Double, longitude: Double, completionClosure: VenueArrayCompletionClosure) {
        // setup URL
        let latAndLong = "?ll=\(latitude),\(longitude)"
        let stringURL = VENUE_SEARCH_API_ENDPOINT + latAndLong + "&query=" + encodeString(queryTerm) + "&" + foursquareAPIEnding();
        println(stringURL)
        let url = NSURL(string: stringURL)
        
        // execute
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    self.parseVenuesFromJSON(data, completionClosure: completionClosure)
                default:
                    println("Got an HTTP \(httpResponse.statusCode)")
                    dispatch_async(dispatch_get_main_queue(), {
                        completionClosure([FSVenue]())
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionClosure([FSVenue]())
                })
            }
        })
        
        task.resume()
    }
    
    func fetchVenue(venueID: String, completionClosure: VenueArrayCompletionClosure) {
        // setup URL
        let stringURL = VENUE_ID_API_ENDPOINT + venueID + "?" + foursquareAPIEnding()
        println(stringURL)
        let url = NSURL(string: stringURL)
        
        // execute
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    self.parseVenuesFromJSON(data, completionClosure: completionClosure)
                default:
                    println("Got an HTTP \(httpResponse.statusCode)")
                    dispatch_async(dispatch_get_main_queue(), {
                        completionClosure([FSVenue]())
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionClosure([FSVenue]())
                })
            }
        })
        
        task.resume()
    }
    
    // MARK: - Private
    
    private func formattedVersion() -> String {
        // format = YYYYMMDD -> last supported date API is prepared for regarding Foursquare API
        return "20150706"
    }
    
    private func foursquareAPIEnding() -> String {
        return "client_id=" + CLIENT_ID + "&client_secret=" + CLIENT_SECRET + "&v=" + formattedVersion() + "&m=foursquare"
    }
    
    private func encodeString(stringToEncode: String) -> String {
        let term = stringToEncode.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil);
        let escapedTerm = term.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        return escapedTerm!
    }
    
    private func parseVenuesFromJSON(data: NSData, completionClosure: VenueArrayCompletionClosure) {
        var jsonError: NSError?
        
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [String: AnyObject],
        response = json["response"] as? [String: AnyObject],
        venues = response["venues"] as? [[String: AnyObject]]
        {
            var allVenues = [FSVenue]()
            
            for venue in venues {
                // append venues to array
                let newVenue = FSVenue(venue: venue)
                allVenues.append(newVenue)
            }
            
            // call completion on main thread
            dispatch_async(dispatch_get_main_queue(), {
                completionClosure(allVenues)
            })
        } else {
            if let jsonError = jsonError {
                println("json error: \(jsonError)")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completionClosure([FSVenue]())
            })
        }
    }
}
