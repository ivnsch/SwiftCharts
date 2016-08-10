//
//  ChartAxis.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxis: CustomStringConvertible {
    
    /// First model value
    public internal(set) var first: Double
    
    /// Last model value
    public internal(set) var last: Double
    
    // Screen location (relative to chart view's frame) corresponding to first model value
    public internal(set) var firstScreen: CGFloat
    
    // Screen location (relative to chart view's frame) corresponding to last model value
    public internal(set) var lastScreen: CGFloat
    
    public internal(set) var firstVisibleScreen: CGFloat
    public internal(set) var lastVisibleScreen: CGFloat
    
    public let paddingFirstScreen: CGFloat
    public let paddingLastScreen: CGFloat
    
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
    
    public var screenToModelRatio: CGFloat {
        return screenLength / CGFloat(length)
    }
    
    public var modelToScreenRatio: CGFloat {
        return CGFloat(length) / screenLength
    }
    
    var firstInit: Double
    var lastInit: Double
    var firstScreenInit: CGFloat
    var lastScreenInit: CGFloat
    
    public required init(first: Double, last: Double, firstScreen: CGFloat, lastScreen: CGFloat, paddingFirstScreen: CGFloat, paddingLastScreen: CGFloat) {
        self.first = first
        self.last = last
        self.firstInit = first
        self.lastInit = last
        self.firstScreen = firstScreen
        self.lastScreen = lastScreen
        self.firstScreenInit = firstScreen
        self.lastScreenInit = lastScreen
        self.paddingFirstScreen = paddingFirstScreen
        self.paddingLastScreen = paddingLastScreen
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
    func internalScreenLocForScalar(scalar: Double) -> CGFloat {
        return CGFloat(scalar - first) * screenToModelRatio
    }
    
    // TODO rename content instead of inner
    // Calculate screen location (relative to axis length, taking into account inverted y axis). It's not required that scalar is between first and last model values.
    public func innerScreenLocForScalar(scalar: Double) -> CGFloat {
        fatalError("Override")
    }
    
    public func innerScalarForScreenLoc(screenLoc: CGFloat) -> Double {
        fatalError("Override")
    }
    
    func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        fatalError("Override")
    }
    
    func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        fatalError("Override")
    }

    func pan(deltaX: CGFloat, deltaY: CGFloat) {
        fatalError("Override")
    }
    
    func offsetFirstScreen(offset: CGFloat) {
        firstScreen += offset
        firstScreenInit += offset
        firstVisibleScreen += offset
    }

    func offsetLastScreen(offset: CGFloat) {
        lastScreen += offset
        lastScreenInit += offset
        lastVisibleScreen += offset
    }
    
    public func screenToModelLength(screenLength: CGFloat) -> Double {
        return scalarForScreenLoc(screenLength) - scalarForScreenLoc(0)
    }
    
    public func modelToScreenLength(modelLength: Double) -> CGFloat {
        return screenLocForScalar(modelLength) - screenLocForScalar(0)
    }
    
    public var firstModelValueInBounds: Double {
        fatalError("Overrode")
    }
    
    public var lastModelValueInBounds: Double {
        fatalError("Overrode")
    }
    
    public var description: String {
        return "{\(self.dynamicType), first: \(first), last: \(last), firstInit: \(firstInit), lastInit: \(lastInit), zoomFactor: \(zoomFactor), firstScreen: \(firstScreen), lastScreen: \(lastScreen), firstVisible: \(firstVisible), lastVisible: \(lastVisible), firstVisibleScreen: \(firstVisibleScreen), lastVisibleScreen: \(lastVisibleScreen), paddingFirstScreen: \(paddingFirstScreen), paddingLastScreen: \(paddingLastScreen))}"
    }
    
    public func copy(first: Double? = nil, last: Double? = nil, firstScreen: CGFloat? = nil, lastScreen: CGFloat? = nil, paddingFirstScreen: CGFloat? = nil, paddingLastScreen: CGFloat? = nil) -> ChartAxis {
        return self.dynamicType.init(
            first: first ?? self.first,
            last: last ?? self.last,
            firstScreen: firstScreen ?? self.firstScreen,
            lastScreen: lastScreen ?? self.lastScreen,
            paddingFirstScreen: paddingFirstScreen ?? self.paddingFirstScreen,
            paddingLastScreen: paddingLastScreen ?? self.paddingLastScreen
        )
    }
}
