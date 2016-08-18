//
//  ChartAxisLabelsGeneratorFixed.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

public class ChartAxisLabelsGeneratorFixed: ChartAxisLabelsGeneratorBase {
    
    public let dict: [Double: [ChartAxisLabel]]
    
    public convenience init(axisValues: [ChartAxisValue]) {
        var dict = [Double: [ChartAxisLabel]]()
        for axisValue in axisValues {
            if !axisValue.hidden {
                dict[axisValue.scalar] = axisValue.labels
            }
            
        }
        self.init(dict: dict)
    }
    
    public init(dict: [Double: [ChartAxisLabel]]) {
        self.dict = dict
    }
    
    public override func generate(scalar: Double) -> [ChartAxisLabel] {
        return dict[scalar] ?? []
    }
    
    public override func fonts(scalar: Double) -> [UIFont] {
        return dict[scalar].map {labels in labels.map{$0.settings.font}} ?? []
    }
}