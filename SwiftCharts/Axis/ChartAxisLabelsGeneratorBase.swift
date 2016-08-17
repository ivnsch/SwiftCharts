//
//  ChartAxisLabelsGeneratorBase.swift
//  SwiftCharts
//
//  Created by ischuetz on 17/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

public class ChartAxisLabelsGeneratorBase: ChartAxisLabelsGenerator {

    public var onlyShowCompleteLabels: Bool = false
    
    public func generate(scalar: Double) -> [ChartAxisLabel] {
        fatalError("Override")
    }
}
