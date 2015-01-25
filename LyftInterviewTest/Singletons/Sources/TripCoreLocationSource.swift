//
//  TripCoreLocationSource.swift
//  LyftInterviewTest
//
//  Created by John Tumminaro on 1/24/15.
//  Copyright (c) 2015 Tiny Little Gears. All rights reserved.
//

import Foundation
import CoreLocation

private let errorDomain = "com.lyftinterviewtest.tripsource.corelocation.errors"
private let tripStartLocationKey = "com.lyftinterviewtest.tripsource.corelocation.tripstart"
private let stopTimeBeforeTripEnds = 60.0

enum TripCoreLocationSourceErrorCodes: Int {
    case AuthorizationError = 101
}

class TripCoreLocationSource: NSObject, TripManagerSource, CLLocationManagerDelegate, Printable {
    
    var tripInProgress = false
    var startupCompletionHandler:((started: Bool, error: NSError?) -> ())?
    weak var delegate: TripSourceDelegate?
    private let locationManager = CLLocationManager()
    private var tripStartLocation: CLLocation?
    private var tripStopLocation: CLLocation?
    override var description: String {
        return TripCoreLocationSource.sourceName()
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        if let data = NSUserDefaults.standardUserDefaults().dataForKey(tripStartLocationKey) {
            // Check if there is a stored trip start that never finished.  If so resume it.
            if let previousStartLoc = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CLLocation {
                println("Resuming trip")
                tripStartLocation = previousStartLoc
                tripInProgress = true
            }
        }
    }
    
    // MARK: - Trip Manager Source
    class func sourceName() -> String {
        return "Core Location Source"
    }
    
    class func sourceAvailable() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func start(completion: (started: Bool, error: NSError?) -> ()) {
        println("Starting Core Location Source")
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            println("Core location services not authorized, requesting authorization")
            startupCompletionHandler = completion
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else if authStatus == .Authorized {
            println("Core location services authorized, starting updates")
            locationManager.startUpdatingLocation()
            completion(started: true, error: nil)
        } else {
            completion(started: false, error: TripCoreLocationSource.authorizationError())
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        tripStartLocation = nil
        tripStopLocation = nil
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("Location manager did change authorization status")
        if let completionHandler = startupCompletionHandler {
            if status == .Authorized {
                completionHandler(started: true, error: nil)
                startupCompletionHandler = nil
            } else if status == .Restricted || status == .Denied {
                completionHandler(started: false, error: TripCoreLocationSource.authorizationError())
                startupCompletionHandler = nil
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Location manager updated locations")
        if tripInProgress {
            // Enumerate in reverse so we get the first reported instance of the trip being stopped.
            for location in locations.reverse() {
                if let loc = location as? CLLocation {
                    if loc.speed < driveMetersPerSecond {
                        // If there is already a candidate for the trip stopping, check to see if the stop period has been long enough.
                        if let stopLoc = tripStopLocation {
                            if loc.timestamp.timeIntervalSinceDate(stopLoc.timestamp) > stopTimeBeforeTripEnds {
                                stopTrip()
                            }
                        } else {
                            // If this is the first location fix below the threshold marked for the trip being over then set it as the stop event.
                            tripStopLocation = loc
                        }
                    } else {
                        // If the locations have increased speed beyond the threshold then discard the stop candidate.
                        tripStopLocation = nil
                    }
                }
            }
        } else {
            // Enumerate in reverse checking for the first start event.
            for location in locations.reverse() {
                if let loc = location as? CLLocation {
                    if loc.speed > driveMetersPerSecond {
                        tripStartLocation = loc
                        // Save the start location in the user defaults in case the app is terminated.
                        let data = NSKeyedArchiver.archivedDataWithRootObject(loc)
                        NSUserDefaults.standardUserDefaults().setObject(data, forKey: tripStartLocationKey)
                        startTrip()
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func startTrip() {
        println("Starting trip")
        tripInProgress = true
        if let del = delegate {
            del.sourceDidStartTrip(self)
        }
    }
    
    private func stopTrip() {
        println("Stopping trip")
        // Generate the report before clearing out the stored properties.  It is a struct so this is fine.
        let report = TripReport(startLocation: tripStartLocation!, endLocation: tripStopLocation!)
        tripStartLocation = nil
        // Clear out the user defaults reference so we don't get dupe trips.
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: tripStartLocationKey)
        tripStopLocation = nil
        tripInProgress = false
        if let del = delegate {
            del.sourceDidEndTrip(self, report: report)
        }
    }
    
    private class func authorizationError() -> NSError {
        return NSError(domain: errorDomain,
            code: TripCoreLocationSourceErrorCodes.AuthorizationError.rawValue,
            userInfo: [NSLocalizedDescriptionKey: "Error getting location authorization"])
    }
    
}