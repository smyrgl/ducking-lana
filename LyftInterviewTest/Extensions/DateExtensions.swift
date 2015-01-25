//
//  DateExtensions.swift
//  LyftInterviewTest
//
//  Created by John Tumminaro on 1/24/15.
//  Copyright (c) 2015 Tiny Little Gears. All rights reserved.
//

import Foundation

extension NSDate {
    func minutesBetweenDate(otherDate: NSDate) -> Int {
        let interval = round(otherDate.timeIntervalSinceDate(self) / 60)
        return Int(interval)
    }
}