//
//  ChartAxisLabelsGeneratorFunc.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Label generator that delegates to a closure, for greater flexibility
public class ChartAxisLabelsGeneratorFunc: ChartAxisLabelsGeneratorBase {

    let f: Double -> [ChartAxisLabel]

    /// Convenience initializer for function which maps scalar to a single label
    public convenience init(f: Double -> ChartAxisLabel) {
        self.init(f: {scalar in
            return [f(scalar)]
        })
    }
    
    public init(f: Double -> [ChartAxisLabel]) {
        self.f = f
    }
    
    public override func generate(scalar: Double) -> [ChartAxisLabel] {
        return f(scalar)
    }
}
