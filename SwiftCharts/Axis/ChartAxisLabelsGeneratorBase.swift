//
//  ChartAxisLabelsGeneratorBase.swift
//  SwiftCharts
//
//  Created by ischuetz on 17/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Needed for common stored properties which are not possible in the extension (without workarounds)
public class ChartAxisLabelsGeneratorBase: ChartAxisLabelsGenerator {

    public var onlyShowCompleteLabels: Bool = false
    
    public var maxStringPTWidth: CGFloat? = nil
    
    public func generate(scalar: Double) -> [ChartAxisLabel] {
        fatalError("Override")
    }
    
    public func fonts(scalar: Double) -> [UIFont] {
        fatalError("Override")
    }
}