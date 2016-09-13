//
//  ChartLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public protocol ChartLayer {
    
    // Execute actions after chart initialisation, e.g. add subviews
     func chartInitialized(chart: Chart)
    
    // Use this to draw directly in chart's context.
    // Don't do anything processor intensive here - this is executed as part of draw(rect) thus has to be quick.
    // Note that everything drawn here will appear behind subviews added by any layer (regardless of position in layers array)
    // Everything done here can also be done adding a subview in chartInialized and drawing on that. The reason this method exists is only performance - as long as we know the layers will appear always behind (e.g. axis lines, guidelines) there's no reason to create new views.
    func chartViewDrawing(context: CGContext, chart: Chart)
}
