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
    
    /// Optional fixed padding value which overwrites paddingFirstScreen/paddingLastScreen when determining if model values are in bounds. This is useful e.g. when setting an initial zoom level, and scaling the padding proportionally such that it appears constant for different zoom levels. In this case it may be necessary to store the un-scaled padding in these variables to keep the bounds constant.
    public var fixedPaddingFirstScreen: CGFloat?
    public var fixedPaddingLastScreen: CGFloat?
    
    var firstVisible: Double {
        return scalarForScreenLoc(firstVisibleScreen)
    }
    
    var lastVisible: Double {
        return scalarForScreenLoc(lastVisibleScreen)
    }
    
    public var zoomFactor: Double {
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
    
    public var screenLengthInit: CGFloat {
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
    
    public required init(first: Double, last: Double, firstScreen: CGFloat, lastScreen: CGFloat, paddingFirstScreen: CGFloat = 0, paddingLastScreen: CGFloat = 0, fixedPaddingFirstScreen: CGFloat? = nil, fixedPaddingLastScreen: CGFloat? = nil) {
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
        self.fixedPaddingFirstScreen = fixedPaddingFirstScreen
        self.fixedPaddingLastScreen = fixedPaddingLastScreen
        self.firstVisibleScreen = firstScreen
        self.lastVisibleScreen = lastScreen
        
        adjustModelBoundariesForPadding()
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
        
        adjustModelBoundariesForPadding()
    }

    func offsetLastScreen(offset: CGFloat) {
        lastScreen += offset
        lastScreenInit += offset
        lastVisibleScreen += offset
        
        adjustModelBoundariesForPadding()
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
        return "{\(self.dynamicType), first: \(first), last: \(last), firstInit: \(firstInit), lastInit: \(lastInit), zoomFactor: \(zoomFactor), firstScreen: \(firstScreen), lastScreen: \(lastScreen), firstVisible: \(firstVisible), lastVisible: \(lastVisible), firstVisibleScreen: \(firstVisibleScreen), lastVisibleScreen: \(lastVisibleScreen), paddingFirstScreen: \(paddingFirstScreen), paddingLastScreen: \(paddingLastScreen), length: \(length), screenLength: \(screenLength), firstModelValueInBounds: \(firstModelValueInBounds), lastModelValueInBounds: \(lastModelValueInBounds))}"
    }
    
    var innerRatio: Double {
        return (lastInit - firstInit) / Double(screenLengthInit - paddingFirstScreen - paddingLastScreen)
    }
    
    func toModelInner(screenLoc: CGFloat) -> Double {
        fatalError("Override")
    }
    
    func isInBoundaries(screenCenter: CGFloat, screenSize: CGSize) -> Bool {
        fatalError("Override")
    }
    
    /// NOTE: this changes the model domain, which means that after this, view based chart points should be (re)generated using the updated ratio. For rendering layers this is not an issue since they request the position from the axis on each update. View based layers / content view children only update according to the transform of the parent, which is derived directly from the gestures and doesn't take into account the axes. This means in praxis that currently it's not possible to use view based layers together with padding and inner frame with varying size. Either the inner frame size has to be fixed, by setting fixed label size for all axes, or it must not have padding, or use a rendering based layer. TODO re-regenerate views on model domain update? This can lead though to stuterring when panning between labels of different sizes. Doing this at the end of the gesture would mean that during the gesture the chart points and axes can be not aligned correctly. Don't resize inner frame during the gesture (at least for view based layers)? In this case long labels would have to be cut during the gesture, and resize the frame / re-generate the chart points when the gesture ends.
    private func adjustModelBoundariesForPadding() {
        if paddingFirstScreen != 0 || paddingLastScreen != 0 {
            self.first = toModelInner(firstScreenInit)
            self.last = toModelInner(lastScreenInit)
        }
    }
    
    public func copy(first: Double? = nil, last: Double? = nil, firstScreen: CGFloat? = nil, lastScreen: CGFloat? = nil, paddingFirstScreen: CGFloat? = nil, paddingLastScreen: CGFloat? = nil, fixedPaddingFirstScreen: CGFloat? = nil, fixedPaddingLastScreen: CGFloat? = nil) -> ChartAxis {
        return self.dynamicType.init(
            first: first ?? self.first,
            last: last ?? self.last,
            firstScreen: firstScreen ?? self.firstScreen,
            lastScreen: lastScreen ?? self.lastScreen,
            paddingFirstScreen: paddingFirstScreen ?? self.paddingFirstScreen,
            paddingLastScreen: paddingLastScreen ?? self.paddingLastScreen,
            fixedPaddingFirstScreen:  fixedPaddingFirstScreen ?? self.fixedPaddingFirstScreen,
            fixedPaddingLastScreen:  fixedPaddingLastScreen ?? self.fixedPaddingLastScreen
        )
    }
}
