//
//  TripCoreMotionSource.swift
//  LyftInterviewTest
//
//  Created by John Tumminaro on 1/24/15.
//  Copyright (c) 2015 Tiny Little Gears. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation

class TripCoreMotionSource: TripManagerSource, Printable {
    
    var tripInProgress = false
    let motionActivityManager = CMMotionActivityManager()
    let motionActivityQueue = NSOperationQueue()
    private var tripStartLocation: CLLocation?
    private var tripStopLocation: CLLocation?
    weak var delegate: TripSourceDelegate?
    var description: String {
        return TripCoreLocationSource.sourceName()
    }

    init() {
        motionActivityQueue.qualityOfService = .Background
    }
    
    // MARK: - Trip Manager Source
    class func sourceName() -> String {
        return "Core Motion Source"
    }
    
    class func sourceAvailable() -> Bool {
        return CMMotionActivityManager.isActivityAvailable()
    }
    
    func start(completion: (started: Bool, error: NSError?) -> ()) {
        motionActivityManager.startActivityUpdatesToQueue(motionActivityQueue,
            withHandler: { (activity) -> Void in
                self.activityChanged(activity)
        })
        completion(started: true, error: nil)
    }
        
    func stop() {
        
    }
    
    // MARK: - Private
    
    private func activityChanged(newActivity: CMMotionActivity) {
        println("Activity changed")
        if tripInProgress && !newActivity.automotive {
            
        } else if !tripInProgress && newActivity.automotive {
            
        }
    }
}