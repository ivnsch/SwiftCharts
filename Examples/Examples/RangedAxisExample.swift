//
//  RangedAxisExample.swift
//  SwiftCharts
//
//  Created by Ivan Schuetz on 17/02/2017.
//  Copyright © 2017 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class RangedAxisExample: UIViewController {
    
    fileprivate var chart: Chart? // arc
    
    private var didLayout: Bool = false

    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    private func initChart() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, fontColor: UIColor.white)
        
        let firstYear: Double = 1980
        let lastYear: Double = 2020
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 1st x-axis model: Has an axis value (tick) for each year. We use this for the small x-axis dividers.
        
        let xValuesGenerator = ChartAxisGeneratorMultiplier(1)
        
        var labCopy = labelSettings
        labCopy.fontColor = UIColor.red
        let xEmptyLabelsGenerator = ChartAxisLabelsGeneratorFunc {value in return
            ChartAxisLabel(text: "", settings: labCopy)
        }
        
        let xModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstYear, lastModelValue: lastYear, axisTitleLabels: [], axisValuesGenerator: xValuesGenerator, labelsGenerator:
            xEmptyLabelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 2nd x-axis model: Has an axis value (tick) for each <rangeSize>/2 years. We use this to show the x-axis labels
        
        let rangeSize: Double = view.frame.width < view.frame.height ? 12 : 6 // adjust intervals for orientation
        let rangedMult: Double = rangeSize / 2
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        
        let xRangedLabelsGenerator = ChartAxisLabelsGeneratorFunc {value -> ChartAxisLabel in
            if value < lastYear && value.truncatingRemainder(dividingBy: rangedMult) == 0 && value.truncatingRemainder(dividingBy: rangeSize) != 0 {
                let val1 = value - rangedMult
                let val2 = value + rangedMult
                return ChartAxisLabel(text: "\(String(format: "%.0f", val1)) - \(String(format: "%.0f", val2))", settings: labelSettings)
            } else {
                return ChartAxisLabel(text: "", settings: labelSettings)
            }
        }
        
        let xValuesRangedGenerator = ChartAxisGeneratorMultiplier(rangedMult)
        
        let xModelForRanges = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstYear, lastModelValue: lastYear, axisTitleLabels: [], axisValuesGenerator: xValuesRangedGenerator, labelsGenerator: xRangedLabelsGenerator)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 3rd x-axis model: Has an axis value (tick) for each <rangeSize> years. We use this to show the x-axis guidelines and long dividers
        
        let xValuesGuidelineGenerator = ChartAxisGeneratorMultiplier(rangeSize)
        let xModelForGuidelines = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstYear, lastModelValue: lastYear, axisTitleLabels: [], axisValuesGenerator: xValuesGuidelineGenerator, labelsGenerator: xEmptyLabelsGenerator)
        
        
        ////////////////////////////////////////////////////////////////////////////////////
        // y-axis model: Has an axis value (tick) for each 2 units. We use this to show the y-axis dividers, labels and guidelines.
    
        let generator = ChartAxisGeneratorMultiplier(2)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        
        let yModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: 0, lastModelValue: 16, axisTitleLabels: [], axisValuesGenerator: generator, labelsGenerator: labelsGenerator)

        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Chart frame, settings
        
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        chartSettings.axisStrokeWidth = 0.5
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.leading = -1
        chartSettings.trailing = 40
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // In order to transform the axis models into axis layers, and get the chart inner frame size, we need to use ChartCoordsSpace.
        // Note that in the case of the x-axes we need to use ChartCoordsSpace multiple times - each of these axes represent essentially the same x-axis, so we can't use multi-axes functionality (i.e. pass an array of x-axes to ChartCoordsSpace).
        
        let coordsSpace = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let coordsSpaceForRanges = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModelForRanges, yModel: yModel)
        let coordsSpaceForGuidelines = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModelForGuidelines, yModel: yModel)
        
        var (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        var (xRangedAxisLayer, _, _) = (coordsSpaceForRanges.xAxisLayer, coordsSpaceForRanges.yAxisLayer, coordsSpaceForRanges.chartInnerFrame)
        let (xGuidelinesAxisLayer, _, _) = (coordsSpaceForGuidelines.xAxisLayer, coordsSpaceForGuidelines.yAxisLayer, coordsSpaceForGuidelines.chartInnerFrame)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Lines layer
        
        let line1ChartPoints = line1ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        let line1Model = ChartLineModel(chartPoints: line1ChartPoints, lineColor: UIColor.white, lineWidth: 2, animDuration: 1, animDelay: 0)
        
        let line2ChartPoints = line2ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        let line2Model = ChartLineModel(chartPoints: line2ChartPoints, lineColor: UIColor(hexString: "1F82DF"), lineWidth: 2, animDuration: 1, animDelay: 0)
        
        let line3ChartPoints = line3ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        let line3Model = ChartLineModel(chartPoints: line3ChartPoints, lineColor: UIColor(hexString: "CE7CFA"), lineWidth: 2, animDuration: 1, animDelay: 0)
        
        let chartPointsLineLayer = ChartPointsLineLayer<ChartPoint>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [line1Model, line2Model, line3Model], pathGenerator: CubicLinePathGenerator(tension1: 0.2, tension2: 0.2))

        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Markers for the last chart points in each line, shown next to the right y-axis
        
        let viewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let h: CGFloat = Env.iPad ? 30 : 20
            let w: CGFloat = Env.iPad ? 60 : 50
            
            let center = chartPointModel.screenLoc
            let label = UILabel(frame: CGRect(x: chart.containerView.frame.maxX, y: center.y - h / 2, width: w, height: h))
            label.backgroundColor = {
                return chartPointsLineLayer.lineModels[chartPointModel.index].lineColors.first ?? UIColor.white
            }()
            
            label.textAlignment = NSTextAlignment.center
            label.text = chartPointModel.chartPoint.y.description
            label.font = ExamplesDefaults.labelFont
            
            let shape = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: h / 2))
            path.addLine(to: CGPoint(x: 20, y: 0))
            path.addLine(to: CGPoint(x: w, y: 0))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: 20, y: h))
            path.close()
            shape.path = path.cgPath
            label.layer.mask = shape
            
            return label
        }
        
        // Create layer with markers for last chart points.
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: [line1ChartPoints.last!, line2ChartPoints.last!, line3ChartPoints.last!], viewGenerator: viewGenerator, mode: .custom, clipViews: false)
        
        // In order for the x-position of the markers to remain fixed at the right y-axis during zooming and panning, we pass a custom transformer, which updates only the y-position of the markers.
        chartPointsLayer.customTransformer = {(model, view, layer) -> Void in
            var model = model
            model.screenLoc = layer.modelLocToScreenLoc(x: model.chartPoint.x.scalar, y: model.chartPoint.y.scalar)
            view.frame.origin = CGPoint(x: layer.chart?.containerView.frame.maxX ?? 0, y: model.screenLoc.y - 20 / 2)
        }
        
        // Finally we set a custom clip rect for the view where we display the markers, in order to not show them outside of the chart's boundaries, during zooming and panning. For now the size is hardcoded. This should be improved. Until then you can calculate the exact frame using the spacing settings and label (string) sizes.
        chartSettings.customClipRect = CGRect(x: 0, y: chartSettings.top, width: view.frame.width, height: view.frame.height - 120)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Guidelines layer. Note how we pass the x-axis layer we created specifically for the guidelines.
        
        let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.white, linesWidth: 0.3)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xGuidelinesAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Dividers layer with small lines. This is used both in x and y axes
        
        let dividersSettings =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 1, start: 2, end: 0)
        let dividersLayer = ChartDividersLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: .xAndY, settings: dividersSettings)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Dividers layer with long lines. This is used only in the x axis. Note how we pass the same axis layer we passed to the guidelines - we want to use the same intervals.
        
        let dividersSettings2 =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 0.5, start: 30, end: 0)
        let dividersLayer2 = ChartDividersLayer(xAxisLayer: xGuidelinesAxisLayer, yAxisLayer: yAxisLayer, axis: .x, settings: dividersSettings2)
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Disable frame updates for 2 of the 3 x-axis layers. This way the space will not be reserved multiple times. We need this only because the 3 layers represent the same x-axis (for a multi-axis chart this would not be necessary). Note that it's important to pass all 3 layers to the chart, although only one is actually visible, because otherwise the layers will not receive inner frame updates, which results in any layers that reference these layers not being positioned correctly.
        xRangedAxisLayer.canChangeFrameSize = false
        xAxisLayer.canChangeFrameSize = false
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // create chart instance with frame and layers
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                xRangedAxisLayer,
                xGuidelinesAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLayer,
                chartPointsLineLayer,
                dividersLayer,
                dividersLayer2
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
        
    }
    
    fileprivate let line1ModelData: [(Double, Double)] = [(1980.47, 9.47), (1980.85, 10.23), (1981.12, 10.93), (1982.09, 6.51), (1982.35, 8.37), (1982.91, 6.76), (1983.70, 9.30), (1984.31, 8.30), (1985.04, 10.00), (1985.22, 8.73), (1985.37, 5.75), (1985.92, 6.42), (1986.13, 5.30), (1987.08, 6.30), (1987.27, 4.95), (1988.46, 8.40), (1988.90, 7.78), (1989.93, 10.45), (1990.80, 9.21), (1991.60, 12.24), (1992.08, 9.78), (1992.64, 11.47), (1993.28, 9.54), (1994.64, 6.99), (1995.65, 9.07), (1997.01, 4.56), (1998.02, 7.61), (1998.29, 5.88), (1998.99, 6.69), (1999.28, 5.35), (2000.23, 5.92), (2000.77, 4.33), (2001.28, 6.28), (2001.82, 4.70), (2002.30, 8.38), (2003.21, 5.35), (2004.51, 10.47), (2005.48, 8.83), (2005.64, 12.54), (2006.61, 10.99), (2007.36, 12.64), (2007.95, 11.54), (2008.37, 11.85), (2008.66, 10.42), (2009.36, 12.12), (2009.73, 11.26), (2010.25, 12.43), (2010.76, 11.18), (2011.65, 13.91), (2012.37, 12.26), (2013.73, 13.97), (2014.42, 12.73), (2015.12, 13.62), (2015.78, 12.67), (2016.01, 11.83), (2016.65, 12.79), (2017.24, 11.59), (2017.68, 13.26), (2018.69, 9.64)]
    fileprivate let line2ModelData: [(Double, Double)] = [(1980.47, 12.47), (1980.85, 9.23), (1981.12, 12.93), (1982.09, 4.51), (1982.35, 10.37), (1982.91, 8.76), (1983.70, 12.30), (1984.31, 9.30), (1985.04, 11.00), (1985.22, 11.73), (1985.37, 7.75), (1985.92, 7.42), (1986.13, 6.30), (1987.08, 7.30), (1987.27, 5.95), (1988.46, 10.40), (1988.90, 8.78), (1989.93, 12.45), (1990.80, 10.21), (1991.60, 14.24), (1992.08, 9.78), (1992.64, 11.47), (1993.28, 12.54), (1994.64, 7.99), (1995.65, 12.07), (1997.01, 7.56), (1998.02, 8.61), (1998.29, 6.88), (1998.99, 7.69), (1999.28, 6.35), (2000.23, 6.92), (2000.77, 5.33), (2001.28, 8.28), (2001.82, 6.70), (2002.30, 8.38), (2003.21, 5.35), (2004.51, 9.47), (2005.48, 6.83), (2005.64, 10.54), (2006.61, 9.99), (2007.36, 10.64), (2007.95, 10.54), (2008.37, 9.85), (2008.66, 12.42), (2009.36, 14.12), (2009.73, 13.26), (2010.25, 14.43), (2010.76, 12.18), (2011.65, 14.91), (2012.37, 13.26), (2013.73, 15.97), (2014.42, 14.73), (2015.12, 12.62), (2015.78, 11.67), (2016.01, 12.83), (2016.65, 10.79), (2017.24, 8.59), (2017.68, 8.26), (2018.69, 10.64)]
    fileprivate let line3ModelData: [(Double, Double)] = [(1980.47, 2.47), (1980.85, 4.23), (1981.12, 5.93), (1982.09, 4.51), (1982.35, 7.37), (1982.91, 5.76), (1983.70, 4.30), (1984.31, 6.30), (1985.04, 5.00), (1985.22, 6.73), (1985.37, 2.75), (1985.92, 3.42), (1986.13, 1.30), (1987.08, 6.30), (1987.27, 3.95), (1988.46, 7.40), (1988.90, 5.78), (1989.93, 8.45), (1990.80, 5.21), (1991.60, 10.24), (1992.08, 6.78), (1992.64, 8.47), (1993.28, 6.54), (1994.64, 4.99), (1995.65, 7.07), (1997.01, 3.56), (1998.02, 6.61), (1998.29, 2.88), (1998.99, 4.69), (1999.28, 3.35), (2000.23, 2.92), (2000.77, 1.33), (2001.28, 2.28), (2001.82, 2.70), (2002.30, 7.38), (2003.21, 2.35), (2004.51, 9.47), (2005.48, 3.83), (2005.64, 7.54), (2006.61, 5.99), (2007.36, 6.64), (2007.95, 7.54), (2008.37, 5.85), (2008.66, 8.42), (2009.36, 11.12), (2009.73, 10.26), (2010.25, 10.43), (2010.76, 8.18), (2011.65, 9.91), (2012.37, 6.26), (2013.73, 8.97), (2014.42, 5.73), (2015.12, 9.62), (2015.78, 8.67), (2016.01, 5.83), (2016.65, 7.79), (2017.24, 6.59), (2017.68, 9.26), (2018.69, 6.64)]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !self.didLayout {
            self.didLayout = true
            self.initChart()
        }
    }
    
    
    @objc func rotated() {
        let orientation = UIApplication.shared.statusBarOrientation
        guard (lastOrientation.map{$0.rawValue != orientation.rawValue} ?? true) else {return}
        
        lastOrientation = orientation

        guard let chart = chart else {return}
        for view in chart.view.subviews {
            view.removeFromSuperview()
        }
        self.initChart()
        chart.view.setNeedsDisplay()

    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
