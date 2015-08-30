//
//  ChartAxisValueDoubleScreenLoc.swift
//  SwiftCharts
//
//  Created by ischuetz on 30/08/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValueDoubleScreenLoc: ChartAxisValueDouble {
    
    private let actualDouble: Double
    
    var screenLocDouble: Double {
        return self.scalar
    }
    
    override public var text: String {
        return self.formatter.stringFromNumber(self.actualDouble)!
    }
    
    // screenLocFloat: model value which will be used to calculate screen position
    // actualFloat: scalar which this axis value really represents
    public init(screenLocDouble: Double, actualDouble: Double, formatter: NSNumberFormatter = ChartAxisValueFloat.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.actualDouble = actualDouble
        super.init(screenLocDouble, formatter: formatter, labelSettings: labelSettings)
    }
    
    override public var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
}
