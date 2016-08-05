//
//  ChartAxisLabelGeneratorDate.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisLabelsGeneratorDate: ChartAxisLabelsGenerator {
    
    let labelSettings: ChartLabelSettings
    
    public let formatter: NSDateFormatter
    
    public init(labelSettings: ChartLabelSettings, formatter: NSDateFormatter = ChartAxisLabelsGeneratorDate.defaultFormatter) {
        self.labelSettings = labelSettings
        self.formatter = formatter
    }
    
    public func generate(scalar: Double) -> [ChartAxisLabel] {
        let text = self.formatter.stringFromDate(NSDate(timeIntervalSince1970: scalar))
        return [ChartAxisLabel(text: text, settings: labelSettings)]
    }
    
    static var defaultFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}
