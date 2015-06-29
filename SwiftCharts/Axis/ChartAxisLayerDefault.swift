//
//  ChartAxisLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisSettings {
    var screenLeading: CGFloat = 0
    var screenTrailing: CGFloat = 0
    var screenTop: CGFloat = 0
    var screenBottom: CGFloat = 0
    var labelsSpacing: CGFloat = 5
    var labelsToAxisSpacingX: CGFloat = 5
    var labelsToAxisSpacingY: CGFloat = 5
    var axisTitleLabelsToLabelsSpacing: CGFloat = 5
    var lineColor:UIColor = UIColor.blackColor()
    var axisStrokeWidth: CGFloat = 2.0
    var isAxisLineVisible: Bool = true
    
    convenience init(_ chartSettings: ChartSettings) {
        self.init()
        self.labelsSpacing = chartSettings.labelsSpacing
        self.labelsToAxisSpacingX = chartSettings.labelsToAxisSpacingX
        self.labelsToAxisSpacingY = chartSettings.labelsToAxisSpacingY
        self.axisTitleLabelsToLabelsSpacing = chartSettings.axisTitleLabelsToLabelsSpacing
        self.screenLeading = chartSettings.leading
        self.screenTop = chartSettings.top
        self.screenTrailing = chartSettings.trailing
        self.screenBottom = chartSettings.bottom
        self.axisStrokeWidth = chartSettings.axisStrokeWidth
    }
}

class ChartAxisLayerDefault: ChartAxisLayer {
    
    let p1: CGPoint
    let p2: CGPoint
    let axisValues: [ChartAxisValue]
    let axisTitleLabels: [ChartAxisLabel]
    let settings: ChartAxisSettings
    
    // exposed for subclasses
    var lineDrawer: ChartLineDrawer?
    var labelDrawers: [ChartLabelDrawer] = []
    var axisTitleLabelDrawers: [ChartLabelDrawer] = []
    
    var rect: CGRect {
        return CGRectMake(self.p1.x, self.p1.y, self.width, self.height)
    }
    
    var axisValuesScreenLocs: [CGFloat] {
        return self.axisValues.map{self.screenLocForScalar($0.scalar)}
    }
    
    var visibleAxisValuesScreenLocs: [CGFloat] {
        return self.axisValues.reduce(Array<CGFloat>()) {u, axisValue in
            return axisValue.hidden ? u : u + [self.screenLocForScalar(axisValue.scalar)]
        }
    }
    
    // smallest screen space between axis values
    var minAxisScreenSpace: CGFloat {
        return self.axisValuesScreenLocs.reduce((CGFloat.max, -CGFloat.max)) {tuple, screenLoc in
            let minSpace = tuple.0
            let previousScreenLoc = tuple.1
            return (min(minSpace, abs(screenLoc - previousScreenLoc)), screenLoc)
        }.0
    }
    
    var length: CGFloat {
        fatalError("override")
    }
    
    var modelLength: CGFloat {
        if let first = self.axisValues.first, let last = self.axisValues.last {
            return last.scalar - first.scalar
        } else {
            return 0
        }
    }
    
    lazy var axisTitleLabelsHeight: CGFloat = {
        return self.axisTitleLabels.reduce(0) {sum, label in
            sum + self.labelMaybeSize(label).height
        }
    }()

    lazy var axisTitleLabelsWidth: CGFloat = {
        return self.axisTitleLabels.reduce(0) {sum, label in
            sum + self.labelMaybeSize(label).width
        }
    }()

    var width: CGFloat {
        fatalError("override")
    }
    
    var lineP1: CGPoint {
        fatalError("override")
    }

    var lineP2: CGPoint {
        fatalError("override")
    }
    
    var height: CGFloat {
        fatalError("override")
    }
    
    var low: Bool {
        fatalError("override")
    }

    // p1: screen location corresponding to smallest axis value
    // p2: screen location corresponding to biggest axis value
    required init(p1: CGPoint, p2: CGPoint, axisValues: [ChartAxisValue], axisTitleLabels: [ChartAxisLabel], settings: ChartAxisSettings)  {
        self.p1 = p1
        self.p2 = p2
        self.axisValues = axisValues.sorted {(ca1, ca2) -> Bool in // ensure sorted
            ca1.scalar < ca2.scalar
        }
        self.axisTitleLabels = axisTitleLabels
        self.settings = settings
    }
    
    func chartInitialized(#chart: Chart) {
        self.initDrawers()
    }

    func chartViewDrawing(#context: CGContextRef, chart: Chart) {
        if self.settings.isAxisLineVisible {
            if let lineDrawer = self.lineDrawer {
                CGContextSetLineWidth(context, CGFloat(self.settings.axisStrokeWidth))
                lineDrawer.triggerDraw(context: context, chart: chart)
            }
        }
        
        for labelDrawer in self.labelDrawers {
            labelDrawer.triggerDraw(context: context, chart: chart)
        }
        for axisTitleLabelDrawer in self.axisTitleLabelDrawers {
            axisTitleLabelDrawer.triggerDraw(context: context, chart: chart)
        }
    }
    
    
    func initDrawers() {
        fatalError("override")
    }
    
    func generateLineDrawer(#offset: CGFloat) -> ChartLineDrawer {
        fatalError("override")
    }
    
    func generateAxisTitleLabelsDrawers(#offset: CGFloat) -> [ChartLabelDrawer] {
        fatalError("override")
    }
    
    func generateLabelDrawers(#offset: CGFloat) -> [ChartLabelDrawer] {
        fatalError("override")
    }

    func labelMaybeSize(labelMaybe: ChartAxisLabel?) -> CGSize {
        return labelMaybe?.textSize ?? CGSizeZero
    }
    
    final func screenLocForScalar(scalar: CGFloat) -> CGFloat {
        if let firstScalar = self.axisValues.first?.scalar {
            return self.screenLocForScalar(scalar, firstAxisScalar: firstScalar)
        } else {
            println("Warning: requesting empty axis for screen location")
            return 0
        }
    }

    func innerScreenLocForScalar(scalar: CGFloat, firstAxisScalar: CGFloat) -> CGFloat {
        return self.length * (scalar - firstAxisScalar) / self.modelLength
    }
    
    func screenLocForScalar(scalar: CGFloat, firstAxisScalar: CGFloat) -> CGFloat {
        fatalError("must override")
    }
    
    

}
