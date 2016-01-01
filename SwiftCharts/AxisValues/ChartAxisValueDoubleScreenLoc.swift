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

    // screenLocFloat: model value which will be used to calculate screen position
    // actualFloat: scalar which this axis value really represents
    public init(screenLocDouble: Double, actualDouble: Double, formatter: NSNumberFormatter = ChartAxisValueDouble.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.actualDouble = actualDouble
        super.init(screenLocDouble, formatter: formatter, labelSettings: labelSettings)
    }
    
    // MARK: CustomStringConvertible
    
    override public var description: String {
        return self.formatter.stringFromNumber(self.actualDouble)!
    }
}
