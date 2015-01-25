//
//  AlertViewExtensions.swift
//  LyftInterviewTest
//
//  Created by John Tumminaro on 1/24/15.
//  Copyright (c) 2015 Tiny Little Gears. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

private let permissionMessage = "To use background location for tracking, you need to select \"Always\" in Location Services Setting."
private let restrictedMessage = "You device has restricted location services for this app, please check settings."

class LocationAlertViewDelegate: NSObject, UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(settingsUrl)
            }
        }
    }
}

extension UIAlertView {
    class func alertWithError(error: NSError) {
        if error.code == TripCoreLocationSourceErrorCodes.AuthorizationError.rawValue {
            displayLocationAuthAlert()
        } else {
            let alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    private class func displayLocationAuthAlert() {
        let status = CLLocationManager.authorizationStatus()
        if status == .Restricted {
            let alert = UIAlertView(title: "Location services restricted",
                message: restrictedMessage,
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
        } else {
            let title = (status == .Denied) ? "Location services are disabled": "Background location is disabled"
            let alert = UIAlertView(title: title, message: permissionMessage, delegate: LocationAlertViewDelegate(), cancelButtonTitle: "Cancel", otherButtonTitles: "Settings")
            alert.show()
        }
    }
}