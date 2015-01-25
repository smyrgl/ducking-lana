//
//  LocationManager.swift
//  LyftInterviewTest
//
//  Created by John Tumminaro on 1/23/15.
//  Copyright (c) 2015 Tiny Little Gears. All rights reserved.
//

import Foundation
import CoreLocation

private let _sharedManager = TripManager()
private let tripLoggingEnabledKey = "com.lyftinterviewtest.userdefaults.logging.enabled"
private let errorDomain = "com.lyftinterviewtest.tripsource.tripmanager.errors"
let driveMetersPerSecond = 4.4704

private enum TripManagerErrorCodes: Int {
    case UnsupportedDevice = 201
}

struct TripReport {
    let startLocation: CLLocation
    let endLocation: CLLocation
}

// Protocol which allows for an abstraction of the use of Core Motion or Core Location sources depending on device capabilities.
protocol TripManagerSource: class {
    class func sourceName() -> String
    class func sourceAvailable() -> Bool
    func start(completion: (started: Bool, error: NSError?) -> ())
    func stop()
    var tripInProgress: Bool { get }
    var delegate: TripSourceDelegate? { get set }
}

protocol TripSourceDelegate: class {
    func sourceDidStartTrip(source: TripManagerSource)
    func sourceDidEndTrip(source: TripManagerSource, report: TripReport)
}

class TripManager: TripSourceDelegate {
    
    class var sharedManager: TripManager {
        return _sharedManager
    }
    var loggingEnabled = NSUserDefaults.standardUserDefaults().boolForKey(tripLoggingEnabledKey)
    var source: TripManagerSource?
    private let geocoder = CLGeocoder()
    private lazy var tripManagerContext = NSManagedObjectContext.MR_context()
    
    init() {
        if TripCoreMotionSource.sourceAvailable() {
            source = TripCoreMotionSource()
            source?.delegate = self
        } else if TripCoreLocationSource.sourceAvailable() {
            source = TripCoreLocationSource()
            source?.delegate = self
        }
        if NSUserDefaults.standardUserDefaults().boolForKey(tripLoggingEnabledKey) {
            // In this case the log should be running but the app was terminated.  Restart logging automatically.
            if let theSource = source {
                println("Automatically starting trip logging")
                theSource.start({ (started, error) -> () in
                    if started {
                        println("Trip logging started")
                    } else if let err = error {
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: tripLoggingEnabledKey)
                        UIAlertView.alertWithError(err)
                    }
                })
            }
        }
    }
    
    // MARK: - Logging Methods
    
    func enableLogging(completion: (started: Bool, error: NSError?) -> ()) {
        println("Enabling trip manager logging")
        if let logSource = source {
            println("Starting trip manager with source \(logSource)")
            logSource.start { (started, error) -> () in
                if started {
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: tripLoggingEnabledKey)
                }
                completion(started: started, error: error)
            }
        } else {
           println("No sources available for this device")
            let error = NSError(domain: errorDomain,
                code: TripManagerErrorCodes.UnsupportedDevice.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "This device hardware has no supported methods for location tracking."])
            completion(started: false, error: error)
        }
    }
    
    func disableLogging() {
        println("Disabling trip manager logging")
        if let theSource = source {
            theSource.stop()
        }
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: tripLoggingEnabledKey)
    }
    
    // MARK: - Trip source delegate
    
    func sourceDidStartTrip(source: TripManagerSource) {
        println("Trip manager source did start trip")
    }
    
    func sourceDidEndTrip(source: TripManagerSource, report: TripReport) {
        MagicalRecord.saveWithBlock { (context) -> Void in
            println("Trip manager source did stop trip")
            var trip = Trip.MR_createEntityInContext(context)
            trip.startTime = report.startLocation.timestamp
            trip.endTime = report.endLocation.timestamp
            
            var startPlace = Place.MR_createEntityInContext(context)
            startPlace.latitude = report.startLocation.coordinate.latitude
            startPlace.longitude = report.startLocation.coordinate.longitude
            trip.start = startPlace
            
            var endPlace = Place.MR_createEntityInContext(context)
            endPlace.latitude = report.endLocation.coordinate.latitude
            endPlace.longitude = report.endLocation.coordinate.longitude
            trip.end = endPlace
            
            self.geocoder.reverseGeocodeLocation(report.startLocation,
                completionHandler: { (placemarks, error) -> Void in
                    let sPlace = startPlace.MR_inContext(context)
                    if let placemark = placemarks.first as? CLPlacemark {
                        sPlace.displayName = placemark.name
                    } else {
                        sPlace.displayName = "\(sPlace.latitude) \(sPlace.longitude)"
                    }
            })
            
            self.geocoder.reverseGeocodeLocation(report.endLocation,
                completionHandler: { (placemarks, error) -> Void in
                    let ePlace = endPlace.MR_inContext(context)
                    if let placemark = placemarks.first as? CLPlacemark {
                        ePlace.displayName = placemark.name
                    } else {
                        ePlace.displayName = "\(ePlace.latitude) \(ePlace.longitude)"
                    }
            })
        }
    }
}