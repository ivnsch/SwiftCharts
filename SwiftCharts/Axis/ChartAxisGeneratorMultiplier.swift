//
//  ChartAxisGeneratorMultiplier.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

public class ChartAxisGeneratorMultiplier: ChartAxisValuesGenerator {

    let multiplier: Double
    
    public init(_ multiplier: Double) {
        self.multiplier = multiplier
    }
    
    public func generate(axis: ChartAxis) -> [Double] {
        let modelStart = floor(axis.first / multiplier) * multiplier
        var values = [Double]()
        var scalar = modelStart
        while scalar <= axis.last {
            values.append(scalar)
            scalar = scalar + multiplier
        }
        return values
    }
}