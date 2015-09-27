//
//  ChartAxisValueDouble.swift
//  SwiftCharts
//
//  Created by ischuetz on 30/08/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValueDouble: ChartAxisValue {
    
    public let formatter: NSNumberFormatter
    let labelSettings: ChartLabelSettings
    
    override public var text: String {
        return self.formatter.stringFromNumber(self.scalar)!
    }

    public convenience init(_ int: Int, formatter: NSNumberFormatter = ChartAxisValueDouble.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.init(Double(int), formatter: formatter, labelSettings: labelSettings)
    }
    
    public init(_ double: Double, formatter: NSNumberFormatter = ChartAxisValueDouble.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: double)
    }
    
    override public var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    
    override public func copy(scalar: Double) -> ChartAxisValueDouble {
        return ChartAxisValueDouble(scalar, formatter: self.formatter, labelSettings: self.labelSettings)
    }
    
    static var defaultFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
