//
//  ChartLayerBase.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Convenience class to make protocol's methods optional
open class ChartLayerBase: ChartLayer {

    open func chartInitialized(chart: Chart) {}
    
    open func chartViewDrawing(context: CGContext, chart: Chart) {}
    
    public init() {}
}
