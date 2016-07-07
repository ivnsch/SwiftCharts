//
//  ChartAxis.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxis {
    
    /// First model value
    public let first: Double
    
    /// Last model value
    public let last: Double
    
    // Screen location (relative to chart view's frame) corresponding to first model value
    public var firstScreen: CGFloat
    
    // Screen location (relative to chart view's frame) corresponding to last model value
    public var lastScreen: CGFloat
    
    public let firstVisibleScreen: CGFloat
    public let lastVisibleScreen: CGFloat
    
    var firstVisible: Double {
        return scalarForScreenLoc(firstVisibleScreen)
    }
    
    var lastVisible: Double {
        return scalarForScreenLoc(lastVisibleScreen)
    }
    
    var zoomFactor: Double {
        return abs(length / visibleLength)
    }
    
    // The space between first and last model values. Can be negative (used for mirrored axes)
    public var length: Double {
        fatalError("override")
    }
    
    // The space between first and last screen locations. Can be negative (used for mirrored axes)
    public var screenLength: CGFloat {
        fatalError("override")
    }
    
    public var visibleLength: Double {
        fatalError("override")
    }
    
    public var visibleScreenLength: CGFloat {
        fatalError("override")
    }
    
    public init(first: Double, last: Double, firstScreen: CGFloat, lastScreen: CGFloat) {
        self.first = first
        self.last = last
        self.firstScreen = firstScreen
        self.lastScreen = lastScreen
        self.firstVisibleScreen = firstScreen
        self.lastVisibleScreen = lastScreen
    }
    
    /// Calculates screen location (relative to chart view's frame) of model value. It's not required that scalar is between first and last model values.
    public func screenLocForScalar(scalar: Double) -> CGFloat {
        fatalError("Override")
    }
    
    /// Calculates model value corresponding to screen location (relative to chart view's frame). It's not required that screenLoc is between firstScreen and lastScreen values.
    public func scalarForScreenLoc(screenLoc: CGFloat) -> Double {
        fatalError("Override")
    }
    
    /// Calculates screen location (relative to axis length) of model value. It's not required that scalar is between first and last model values.
    func innerScreenLocForScalar(scalar: Double) -> CGFloat {
        return screenLength * CGFloat(scalar - first) / CGFloat(length)
    }
}