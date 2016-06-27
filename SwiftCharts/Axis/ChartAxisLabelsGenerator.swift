//
//  ChartAxisLabelsGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates labels for an axis value. Note: Y axis currently supports only one label per axis value (1 element array)
public protocol ChartAxisLabelsGenerator {
    
    func generate(scalar: Double) -> [ChartAxisLabel]
}