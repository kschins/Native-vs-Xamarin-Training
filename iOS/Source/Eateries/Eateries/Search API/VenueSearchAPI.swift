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
    private let CLIENT_SECRET = "DWROOB5ZAGLOFXOCGQPR02RXQ1NVE3FMUJYLSNH3CHULIKK0"
    private let VENUE_SEARCH_API_ENDPOINT = "https://api.foursquare.com/v2/venues/search"
    private let VENUE_EXPLORE_API_ENDPOINT = "https://api.foursquare.com/v2/venues/explore"
    private let VENUE_ID_API_ENDPOINT = "https://api.foursquare.com/v2/venues/"
    private let config: NSURLSessionConfiguration
    private let session: NSURLSession
    
    typealias VenueArrayCompletionClosure = (Array<FSVenue>) -> Void
    typealias VenueCompletionClosure = (FSVenue?, Bool) -> Void
    
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
        let url = NSURL(string: stringURL)
        
        // execute
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    self.parseVenuesFromJSON(data!, completionClosure: completionClosure)
                default:
                    print("Got an HTTP \(httpResponse.statusCode)")
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
        let url = NSURL(string: stringURL)
        
        // execute
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    self.parseVenuesFromJSON(data!, completionClosure: completionClosure)
                default:
                    print("Got an HTTP \(httpResponse.statusCode)")
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
    
    func fetchVenue(venueID: String, completionClosure: VenueCompletionClosure) {
        // setup URL
        let stringURL = VENUE_ID_API_ENDPOINT + venueID + "?" + foursquareAPIEnding()
        let url = NSURL(string: stringURL)
        
        // execute
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    self.parseVenueFromJSON(data!, completionClosure: completionClosure)
                default:
                    print("Got an HTTP \(httpResponse.statusCode)")
                    dispatch_async(dispatch_get_main_queue(), {
                        completionClosure(nil, false)
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionClosure(nil, false)
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
        let escapedTerm = term.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        return escapedTerm!
    }
    
    private func parseVenuesFromJSON(data: NSData, completionClosure: VenueArrayCompletionClosure) {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject],
            response = json["response"] as? [String: AnyObject],
            venues = response["venues"] as? [[String: AnyObject]]
            {
                var allVenues = [FSVenue]()
                
                for venue in venues {
                    // append venues to array
                    let newVenue = FSVenue(venue: venue)
                    
                    if newVenue.validVenue {
                        allVenues.append(newVenue)
                    }
                }
                
                // call completion on main thread
                dispatch_async(dispatch_get_main_queue(), {
                    completionClosure(allVenues)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionClosure([FSVenue]())
                })
            }
        } catch let error as NSError {
            print("Failed to parse JSON venues. Error : \(error.domain)")
        }
    }
    
    private func parseVenueFromJSON(data: NSData, completionClosure: VenueCompletionClosure) {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject],
            response = json["response"] as? [String: AnyObject],
            venue = response["venue"] as? [String: AnyObject]
            {
                // venue
                let newVenue = FSVenue(venue: venue)
                
                dispatch_async(dispatch_get_main_queue(), {
                    completionClosure(newVenue, true)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completionClosure(nil, false)
                })
            }
        } catch let error as NSError {
            print("Failed to parse JSON venue. Error: \(error.domain)")
        }
    }
}
