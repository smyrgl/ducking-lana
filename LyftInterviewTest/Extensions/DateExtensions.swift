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
        return Int(otherDate.timeIntervalSinceDate(self) / 60)
    }
}