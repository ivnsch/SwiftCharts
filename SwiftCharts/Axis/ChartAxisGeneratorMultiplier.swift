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
        
        // Update intervals when zooming duplicates / halves
        // In order to do this, we round the zooming factor to the lowest value in 2^0, 2^1...2^n sequence (this corresponds to 1x, 2x...nx zooming) and divide the original multiplier by this
        // For example, given a 2 multiplier, when zooming in, zooming factors in 2x..<4x are rounded down to 2x, and dividing our multiplier by 2x, we get a 1 multiplier, meaning during zoom  2x..<4x the values have 1 interval length. If continue zooming in, for 4x..<8x, we get a 0.5 multiplier, etc.
        let zoomedMultiplier = multiplier / pow(2, floor(log2(axis.zoomFactor)))
        
        let modelStart = floor(axis.firstVisible / zoomedMultiplier) * zoomedMultiplier
        
        var values = [Double]()
        var scalar = modelStart
        while scalar <= axis.lastVisible {
            values.append(scalar)
            scalar = scalar + zoomedMultiplier
        }
        
        return values
    }
}