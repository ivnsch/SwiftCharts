//
//  ChartAxisLabelsGeneratorNumberSuffix.swift
//  SwiftCharts
//
//  Created by ischuetz on 21/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

public class ChartAxisLabelsGeneratorNumberSuffix: ChartAxisLabelsGenerator {
    
    public let labelSettings: ChartLabelSettings
    
    public let units = ["K", "M", "G", "T", "P", "E"]
    
    public init(labelSettings: ChartLabelSettings) {
        self.labelSettings = labelSettings
    }

    // src: http://stackoverflow.com/a/23290016/930450
    public func generate(scalar: Double) -> [ChartAxisLabel] {
        let sign = scalar < 0 ? "-" : ""
        
        let absScalar = fabs(scalar)

        let text: String = {
            if (absScalar < 1000) {
                return "\(sign)\(absScalar)"
                
            } else {
                let exp = Int(log10(absScalar) / 3)
                let roundedScalar = round(10 * absScalar / pow(1000, Double(exp))) / 10
                return "\(sign)\(roundedScalar)\(units[exp-1])"
            }
        }()

        return [ChartAxisLabel(text: text, settings: labelSettings)]
    }
}