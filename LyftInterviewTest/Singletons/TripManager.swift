//
//  LocationManager.swift
//  LyftInterviewTest
//
//  Created by John Tumminaro on 1/23/15.
//  Copyright (c) 2015 Tiny Little Gears. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

private let _sharedManager = TripManager()
private let tripLoggingEnabledKey = "com.lyftinterviewtest.userdefaults.logging.enabled"

class TripManager: NSObject, CLLocationManagerDelegate {
    
    class var sharedManager: TripManager {
        return _sharedManager
    }
    var loggingEnabled = NSUserDefaults.standardUserDefaults().boolForKey(tripLoggingEnabledKey)
    private let coreLocationManager = CLLocationManager()
    private let motionActivityManager = CMMotionActivityManager()
    private let geocoder = CLGeocoder()
    private let activityMonitorQueue = NSOperationQueue()
    
    // MARK: - NSObject
    
    override init() {
        super.init()
        coreLocationManager.delegate = self
        activityMonitorQueue.qualityOfService = .Background
    }
    
    // MARK: - Logging Methods
    
    func enableLogging() -> Bool {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: tripLoggingEnabledKey)
        return true
    }
    
    func disableLogging() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: tripLoggingEnabledKey)
    }
        
    // MARK: - CLLocationManager delegate
    
    
}
