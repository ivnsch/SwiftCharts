//
//  ChartAxisValueDate.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValueDate: ChartAxisValue {
  
    private let formatter: NSDateFormatter
    
    public var date: NSDate {
        return ChartAxisValueDate.dateFromScalar(self.scalar)
    }
    
    public init(date: NSDate, formatter: NSDateFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        super.init(scalar: ChartAxisValueDate.scalarFromDate(date), labelSettings: labelSettings)
    }
    
    public class func dateFromScalar(scalar: Double) -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(scalar))
    }
    
    public class func scalarFromDate(date: NSDate) -> Double {
        return Double(date.timeIntervalSince1970)
    }

    // MARK: CustomStringConvertible

    override public var description: String {
        return self.formatter.stringFromDate(self.date)
    }
}

