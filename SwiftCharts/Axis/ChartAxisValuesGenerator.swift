//
//  ChartAxisValuesGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates axis values to be displayed
public protocol ChartAxisValuesGenerator {
    
    func axisLayerInitialized(layer: ChartAxisLayer)
    
    func generate(axis: ChartAxis) -> [Double]
}