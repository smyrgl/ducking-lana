private let timeFormatterCacheKey = "com.lyftinterviewtest.cache.trip.timeformatter"

@objc(Trip)

class Trip: _Trip {
    
    var valid: Bool {
        if let startDisplay = start?.displayName {
            if let endDisplay = end?.displayName {
                return true
            }
        }
        return false
    }

    var displayString: String {
        var displayString = ""
        if let theStart = start {
            if let startDisplay = theStart.displayName {
                displayString += "\(startDisplay) > "
                if let theEnd = end {
                    if let endDisplay = theEnd.displayName {
                        displayString += "\(endDisplay)"
                    }
                } else {
                    displayString += "In progress"
                }
            }
        }
        return displayString
    }
    
    var durationDisplayString: String {
        var displayString = ""
        if let sTime = startTime {
            displayString += "\(Trip.sharedTimeFormatter().stringFromDate(sTime))-"
            if let eTime = endTime {
                displayString += "\(Trip.sharedTimeFormatter().stringFromDate(eTime)) (\(sTime.minutesBetweenDate(eTime)))"
            } else {
                displayString += "Now"
            }
        }
        
        return displayString
    }
    
    var isComplete: Bool {
        return start != nil && end != nil
    }
    
    // Formatters are expensive to create, cache the formatter in the thread dictionary so that they are lazily created and shared without sacrificing the ability to use Trip objects across threads.
    
    private class func sharedTimeFormatter() -> NSDateFormatter {
        if let sharedFormatter = NSThread.currentThread().threadDictionary[timeFormatterCacheKey] as? NSDateFormatter {
            return sharedFormatter
        } else {
            let sharedFormatter = NSDateFormatter()
            sharedFormatter.dateFormat = "HH:mm"
            sharedFormatter.timeZone = NSTimeZone.systemTimeZone()
            NSThread.currentThread().threadDictionary[timeFormatterCacheKey] = sharedFormatter
            return sharedFormatter
        }
    }

}
