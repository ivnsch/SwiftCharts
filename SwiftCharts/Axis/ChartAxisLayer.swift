//
//  ChartAxisLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A protocol for all axis layers
public protocol ChartAxisLayer: ChartLayer {

    /// The location of the smallest axis value
    var p1: CGPoint {get}

    /// The location of the largest axis value
    var p2: CGPoint {get}

    /// The axis values shown in the layer
    var axisValues: [ChartAxisValue] {get}

    /// The bounding rectangle of the layer. This should take into account all labels, their rotation and any spacing between them
    var rect: CGRect {get}

    /// The screen locations that corresponds with the axis values
    var axisValuesScreenLocs: [CGFloat] {get}

    /// The screen locations that correspond with the visible axis values
    var visibleAxisValuesScreenLocs: [CGFloat] {get}

    /// The smallest screen distance between axis values
    var minAxisScreenSpace: CGFloat {get}

    /// The length of the axis along its dimension
    var length: CGFloat {get}

    /// The difference between the first and last axis values
    var modelLength: CGFloat {get}

    /// Whether the axis is low (leading or bottom) or high (trailing or top)
    var low: Bool {get}

    var lineP1: CGPoint {get}
    var lineP2: CGPoint {get}

    /**
     Calculates the location along the axis dimension for a given axis value's scalar value to be displayed

     - parameter scalar: An axis value's scalar value

     - returns: The location along the axis' dimension that the axis value should be displayed
     */
    func screenLocForScalar(_ scalar: Double) -> CGFloat
}
