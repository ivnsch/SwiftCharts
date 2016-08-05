//
//  NSDate.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

var systemCalendar: NSCalendar {
    return NSCalendar.currentCalendar()
}

extension NSDate {
    
    var day: Int {
        return systemCalendar.components([.Day], fromDate: self).day
    }

    var month: Int {
        return systemCalendar.components([.Month], fromDate: self).month
    }
    
    var year: Int {
        return systemCalendar.components([.Year], fromDate: self).year
    }
    
    func components(unitFlags: NSCalendarUnit) -> NSDateComponents {
        return systemCalendar.components(unitFlags, fromDate: self)
    }
    
    func component(unit: NSCalendarUnit) -> Int {
        let components = systemCalendar.components([unit], fromDate: self)
        return components.valueForComponent(unit)
    }
    
    func addComponent(value: Int, unit: NSCalendarUnit) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.setValue(value, forComponent: unit)
        return systemCalendar.dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    
    static func toDateComponents(timeInterval: NSTimeInterval, unit: NSCalendarUnit) -> NSDateComponents {
        let date1 = NSDate()
        let date2 = NSDate(timeInterval: timeInterval, sinceDate: date1)
        return systemCalendar.components(unit, fromDate: date1, toDate: date2, options: [])
    }
    
    func timeInterval(date: NSDate, unit: NSCalendarUnit) -> Int {
        let interval = timeIntervalSinceDate(date)
        let components = NSDate.toDateComponents(interval, unit: unit)
        return components.valueForComponent(unit)
    }
}