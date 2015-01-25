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

// Protocol which allows for an abstraction of the use of different location sources depending on device capabilities.
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
        if TripCoreLocationSource.sourceAvailable() {
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let context = NSManagedObjectContext.MR_context()
            
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
            
            let semaphore = dispatch_semaphore_create(1)
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

            self.geocoder.reverseGeocodeLocation(report.startLocation,
                completionHandler: { (placemarks, error) -> Void in
                    if let placemark = placemarks.first as? CLPlacemark {
                        startPlace.displayName = placemark.name
                    } else {
                        startPlace.displayName = "\(startPlace.latitude) \(startPlace.longitude)"
                    }
                    dispatch_semaphore_signal(semaphore)
            })
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            self.geocoder.reverseGeocodeLocation(report.endLocation,
                completionHandler: { (placemarks, error) -> Void in
                    if let placemark = placemarks.first as? CLPlacemark {
                        endPlace.displayName = placemark.name
                    } else {
                        endPlace.displayName = "\(endPlace.latitude) \(endPlace.longitude)"
                    }
                    dispatch_semaphore_signal(semaphore)
            })
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            context.MR_saveToPersistentStoreAndWait()
            dispatch_semaphore_signal(semaphore)
        })
    }
    
}
