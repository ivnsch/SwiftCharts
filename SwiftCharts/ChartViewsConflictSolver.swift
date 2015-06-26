//
//  ChartViewsConflictSolver.swift
//  SwiftCharts
//
//  Created by ischuetz on 30/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// For now as class, which in this case is acceptable. Protocols currently don't work very well with generics.
public class ChartViewsConflictSolver<T: ChartPoint, U: UIView> {
    
    // Reposition views in case of overlapping
    func solveConflicts(views views: [ChartPointsViewsLayer<T, U>.ViewWithChartPoint]) {}
}
