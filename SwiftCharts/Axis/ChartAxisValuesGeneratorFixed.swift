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
    
    public convenience init(values: [ChartAxisValue]) {
        self.init(values: values.map{$0.scalar})
    }

    public init(values: [Double]) {
        self.values = values
    }

    public func axisInitialized(axis: ChartAxis) {}
    
    public func generate(axis: ChartAxis) -> [Double] {
        let (first, last) = axis.firstVisible > axis.lastVisible ? (axis.lastVisible, axis.firstVisible) : (axis.firstVisible, axis.lastVisible)
        return values.filter{$0 >= first && $0 <= last}
    }
}