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
    private let labelSettings: ChartLabelSettings
    
    public var date: NSDate {
        return ChartAxisValueDate.dateFromScalar(self.scalar)
    }
    
    public init(date: NSDate, formatter: NSDateFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: ChartAxisValueDate.scalarFromDate(date))
    }
    
    override public var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.formatter.stringFromDate(self.date), settings: self.labelSettings)
        axisLabel.hidden = self.hidden
        return [axisLabel]
    }
    
    public class func dateFromScalar(scalar: Double) -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(scalar))
    }
    
    public class func scalarFromDate(date: NSDate) -> Double {
        return Double(date.timeIntervalSince1970)
    }
}

