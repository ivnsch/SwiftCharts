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
    
    public var first: Double? {
        return values.first
    }
    
    public var last: Double? {
        return values.last
    }
    
    var values: [Double]
    
    public init(values: [Double]) {
        self.values = values
    }

    public func axisInitialized(axis: ChartAxis) {}
    
    public func generate(axis: ChartAxis) -> [Double] {
        return values.filter{$0 >= axis.firstVisible && $0 <= axis.lastVisible}
    }
}