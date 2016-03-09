//
//  PanScatterExample.swift
//  Examples
//
//  Created by iainbryson on 19/01/16.
//  Copyright (c) 2016 iainbryson. All rights reserved.
//
/*
This example shows how you can achieve a pan effect across a larger canvas than fits on screen.  We render the chart and axes into a frame which is 9 times the size of the visible portion of the chart -- essentially a 3 by 3 grid where the center square fills up the screen -- and allow panning around the area.  In order to keep the axes always in view, we split the chart into 3 separate views.  With appropriate clipping, this lets us scroll only the X portion of the x axis and the y portion of the y axis, so they're always visible and always show the current position in space.

*/

import UIKit
import SwiftCharts

private enum MyExampleModelDataType {
    case Type0, Type1, Type2, Type3
}

private enum Shape {
    case Triangle, Square, Circle, Cross
}

public class SimpleAxisLabelView: UIView {
    
    weak var chart: Chart?
    var axisLabelDrawer: ChartLabelDrawer?
    
    public init(frame: CGRect, text: String, settings: ChartLabelSettings, chart: Chart) {
        super.init(frame: frame)
        self.sharedInit()

        self.chart = chart // ugly
        
        let axisLabel = ChartAxisLabel(text: text, settings: settings)
        let labelSize = ChartUtils.textSize(axisLabel.text, font: settings.font)
        let settings = settings
        let newSettings = ChartLabelSettings(font: settings.font, fontColor: settings.fontColor, rotation: settings.rotation, rotationKeep: settings.rotationKeep)
        self.axisLabelDrawer = ChartLabelDrawer(text: axisLabel.text, screenLoc: CGPointMake(
            frame.origin.x + (frame.size.width / 2) + labelSize.height,
            (frame.size.height - 0.0 - labelSize.height)), settings: newSettings)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
    
    func sharedInit() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        axisLabelDrawer!.draw(context: context!, chart: chart!)
    }
}

class PanScatterExample: UIViewController, UIGestureRecognizerDelegate {
    
    private var charts = [String:Chart]()
    
    let panRecognizer = UIPanGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        panRecognizer.addTarget(self, action: "panChart:")
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)


        // Create a regular model so it's easy to tell that the axes and points are aligned.
        var models =  [(x: Double, y: Double, type: MyExampleModelDataType)]();

        for x in 0.stride(through: 450, by: 25) {
            for y in 0.stride(through: 450, by: 25) {
                models.append((x: Double(x), y: Double(y), .Type0 ))
            }
        }
        
        let layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)] = [
            .Type0 : (.Triangle, UIColor.redColor()),
            .Type1 : (.Square, UIColor.blueColor()),
            .Type2 : (.Circle, UIColor.greenColor()),
            .Type3 : (.Cross, UIColor.blackColor())
        ]

        let axisLabelHeight = CGFloat(20.0)
        
        // Use the whole superview, but carve out some space for the axis labels
        let visibleChartFrame = CGRectMake(self.view.bounds.origin.x + axisLabelHeight,
                                                self.view.bounds.origin.y,
                                                self.view.bounds.size.width - axisLabelHeight,
                                                self.view.bounds.size.height - axisLabelHeight)
        
        let underlyingChartFrame = CGRectMake((visibleChartFrame.origin.x - visibleChartFrame.size.width),
                                              (visibleChartFrame.origin.y - visibleChartFrame.size.height),
                                              3.0 * visibleChartFrame.size.width,
                                              3.0 * visibleChartFrame.size.height)

        let xValues = 0.stride(through: 450, by: 50).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = 0.stride(through: 300, by: 50).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        
        let xModel = ChartAxisModel(axisValues: xValues)
        let yModel = ChartAxisModel(axisValues: yValues)
        
        // TODO: This default CoordsSapce up being very wasteful when we split out the elements into their own views.  Because the various elements (x axis, y axis and plot area) are positioned by this helper relative to a larger underlying canvas, by default we'd need to allocate UIViews of the size of the underlying frame for each of them, tripling our memory consumption.
        // This problem can be avoided for the y axis since it "hugs" the left border (and we an create a tall, narrow UIView without needing to allocate a whole extra chart-sized one), and is not a huge deal for the plot area since the only space we need to waste is the offset where the y axis lives -- it already is mostly the size of the underlying frame.  But it's a big problem for the x axis as we end up having to allocate an UIView the entire size of the underlying frame so that it can render at the bottom of this frame.
        let underlyingCoordSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: underlyingChartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, _) = (underlyingCoordSpace.xAxis, underlyingCoordSpace.yAxis, underlyingCoordSpace.chartInnerFrame)

        let visibleCoordSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: visibleChartFrame, xModel: xModel, yModel: yModel)
        let (_, _, innerFrame) = (visibleCoordSpace.xAxis, visibleCoordSpace.yAxis, visibleCoordSpace.chartInnerFrame)

        
        let scatterLayers = self.toLayers(models, layerSpecifications: layerSpecifications, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame)
        
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: underlyingCoordSpace.chartInnerFrame, settings: guidelinesLayerSettings)

        // Create the Chart for the plot area
        let plotChart = Chart(
            frame: underlyingChartFrame,
            layers: [
                guidelinesLayer
                ] + scatterLayers
        )
        let plotAreaUIView = UIView(frame: CGRect(origin: CGPoint(x: visibleCoordSpace.chartInnerFrame.origin.x + visibleChartFrame.origin.x, y: (visibleCoordSpace.chartInnerFrame.origin.y+visibleChartFrame.origin.y)), size: visibleCoordSpace.chartInnerFrame.size))
        plotAreaUIView.clipsToBounds = true
        plotAreaUIView.backgroundColor = UIColor(red: 0.9, green: 0.5, blue: 0.9, alpha: 0.05) // debug colors
        plotAreaUIView.addSubview(plotChart.view)
        self.view.addSubview(plotAreaUIView)

        
        // take the axes from the full-size chart and create a new chart with it so it gets it's own view.

        let xAxisChart = Chart(frame: CGRect(origin: CGPointMake(underlyingChartFrame.origin.x + innerFrame.origin.x, underlyingChartFrame.origin.y + innerFrame.size.height*0.0), size: CGSize(width: underlyingChartFrame.size.width, height: underlyingChartFrame.size.height) ), layers: [underlyingCoordSpace.xAxis])
        xAxisChart.view.backgroundColor = UIColor(red: 0.9, green: 0.5, blue: 0.9, alpha: 0.05) // debug colors
        xAxisChart.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, -1*visibleChartFrame.size.height)
        
        let yAxisChart = Chart(frame: CGRect(origin: CGPointMake(underlyingChartFrame.origin.x - visibleChartFrame.origin.x, underlyingChartFrame.origin.y), size: CGSize(width: underlyingCoordSpace.chartInnerFrame.origin.x, height: underlyingChartFrame.size.height)), layers: [underlyingCoordSpace.yAxis])
        yAxisChart.view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.5, alpha: 0.05) // debug colors
        yAxisChart.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, +visibleChartFrame.size.width, 0.0)
        
        // view to clip out the bottom left rectangular region where the axes would tend to overlap each other
        let axisClipperSubview = UIView(frame: CGRect(origin: CGPoint(x: visibleChartFrame.origin.x, y: (visibleCoordSpace.chartInnerFrame.origin.y + visibleChartFrame.origin.y)), size: CGSizeMake(innerFrame.origin.x, innerFrame.size.height)))
        axisClipperSubview.clipsToBounds = true;
        
        // we can chose to clip either x or y:
        
        // Y axis clips x Axis
        //axisClipperSubview.addSubview(xAxisChart.view)
        //self.view.addSubview(yAxisChart.view)

        // X axis clips Y Axis
        axisClipperSubview.addSubview(yAxisChart.view)
        self.view.addSubview(xAxisChart.view)

        self.view.addSubview(axisClipperSubview)
        
        let xAxisView = SimpleAxisLabelView(frame: visibleChartFrame, text: "X Axis title", settings: labelSettings, chart: plotChart)
        let yAxisView = SimpleAxisLabelView(frame: visibleChartFrame, text: "Y Axis title", settings: labelSettings.defaultVertical(), chart: plotChart)

        self.view.addSubview(xAxisView)
        self.view.addSubview(yAxisView)

        self.charts = ["x" : xAxisChart, "plot" : plotChart, "y" : yAxisChart]
    }
    
    private func toLayers(models: [(x: Double, y: Double, type: MyExampleModelDataType)], layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)], xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect) -> [ChartLayer] {
        
        // group chartpoints by type
        let groupedChartPoints: Dictionary<MyExampleModelDataType, [ChartPoint]> = models.reduce(Dictionary<MyExampleModelDataType, [ChartPoint]>()) {(var dict, model) in
            let chartPoint = ChartPoint(x: ChartAxisValueDouble(model.x), y: ChartAxisValueDouble(model.y))
            if dict[model.type] != nil {
                dict[model.type]!.append(chartPoint)
                
            } else {
                dict[model.type] = [chartPoint]
            }
            return dict
        }
        
        // create layer for each group
        let dim: CGFloat = Env.iPad ? 14 : 7
        let size = CGSizeMake(dim, dim)
        let layers: [ChartLayer] = groupedChartPoints.map {(type, chartPoints) in
            let layerSpecification = layerSpecifications[type]!
            switch layerSpecification.shape {
            case .Triangle:
                return ChartPointsScatterTrianglesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color)
            case .Square:
                return ChartPointsScatterSquaresLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color)
            case .Circle:
                return ChartPointsScatterCirclesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color)
            case .Cross:
                return ChartPointsScatterCrossesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color)
            }
        }
        
        return layers
    }


    func panChart(pinchRecognizer: UIPinchGestureRecognizer) {
        let translation = panRecognizer.translationInView(self.view);

        self.charts["plot"]!.view.transform = CGAffineTransformTranslate(self.charts["plot"]!.view.transform, translation.x, translation.y)
        self.charts["x"]!.view.transform = CGAffineTransformTranslate(self.charts["x"]!.view.transform, translation.x, 0.0)
        self.charts["y"]!.view.transform = CGAffineTransformTranslate(self.charts["y"]!.view.transform, 0.0, translation.y)

        panRecognizer.setTranslation(CGPointZero, inView: self.view)
        print(translation)
    }
}
