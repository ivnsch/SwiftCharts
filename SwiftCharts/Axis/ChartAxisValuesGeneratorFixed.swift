//
//  ChartAxisValuesGeneratorFixed.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates a fixed axis values array
public class ChartAxisValuesGeneratorFixed: ChartAxisValuesGenerator {
    
    let values: [Double]
    
    public init(values: [Double]) {
        self.values = values
    }

    public func generate(axis: ChartAxis) -> [Double] {
        return values
    }
}