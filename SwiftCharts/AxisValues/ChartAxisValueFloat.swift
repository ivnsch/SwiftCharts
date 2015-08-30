//
//  ChartAxisValueFloat.swift
//  swift_charts
//
//  Created by ischuetz on 15/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

//@availability(*, deprecated=0.2.5, message="use ChartAxisValueDouble instead")
/**
    DEPRECATED use ChartAxisValueDouble instead
    Above annotation causes warning inside this file and it was not possible to supress (tried http://stackoverflow.com/a/6921972/930450 etc.)
*/
public class ChartAxisValueFloat: ChartAxisValue {
    
    public let formatter: NSNumberFormatter
    let labelSettings: ChartLabelSettings

    public var float: CGFloat {
        return CGFloat(self.scalar)
    }
  
    override public var text: String {
        return self.formatter.stringFromNumber(self.float)!
    }
    
    public init(_ float: CGFloat, formatter: NSNumberFormatter = ChartAxisValueFloat.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: Double(float))
    }
   
    override public var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    
    override public func copy(scalar: Double) -> ChartAxisValueFloat {
        return ChartAxisValueFloat(CGFloat(scalar), formatter: self.formatter, labelSettings: self.labelSettings)
    }
    
    static var defaultFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
