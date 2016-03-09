//
//  ChartAxisValueDate.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValueDate: ChartAxisValue {
  
    private let formatter: (NSDate) -> String

    public var date: NSDate {
        return ChartAxisValueDate.dateFromScalar(self.scalar)
    }

    public init(date: NSDate, formatter: (NSDate) -> String, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        super.init(scalar: ChartAxisValueDate.scalarFromDate(date), labelSettings: labelSettings)
    }

    convenience public init(date: NSDate, formatter: NSDateFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.init(date: date, formatter: { formatter.stringFromDate($0) }, labelSettings: labelSettings)
    }
    
    public class func dateFromScalar(scalar: Double) -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(scalar))
    }
    
    public class func scalarFromDate(date: NSDate) -> Double {
        return Double(date.timeIntervalSince1970)
    }

    // MARK: CustomStringConvertible

    override public var description: String {
        return self.formatter(self.date)
    }
}

