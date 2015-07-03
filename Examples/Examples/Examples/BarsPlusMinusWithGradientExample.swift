//
//  BarsPlusMinusWithGradientExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class BarsPlusMinusWithGradientExample: UIViewController {
    
    private var chart: Chart? // arc
    
    private let gradientPicker: GradientPicker // to pick the colors of the bars
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.gradientPicker = GradientPicker(width: 200)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        let vals: [(title: String, val: CGFloat)] = [
            ("U", -75),
            ("T", -65),
            ("S", -50),
            ("R", -45),
            ("Q", -40),
            ("P", -30),
            ("O", -20),
            ("N", -10),
            ("M", -5),
            ("L", -0),
            ("K", 10),
            ("J", 15),
            ("I", 20),
            ("H", 30),
            ("G", 35),
            ("F", 40),
            ("E", 50),
            ("D", 60),
            ("C", 65),
            ("B", 70),
            ("A", 75)
        ]
        
        let (minVal: CGFloat, maxVal: CGFloat) = vals.reduce((min: CGFloat(0), max: CGFloat(0))) {tuple, val in
            (min: min(tuple.min, val.val), max: max(tuple.max, val.val))
        }
        let length: CGFloat = maxVal - minVal
        
        let zero = ChartAxisValueFloat(0)
        let bars: [ChartBarModel] = Array(enumerate(vals)).map {index, tuple in
            let percentage = (tuple.val - minVal - 0.01) / length // FIXME without -0.01 bar with 1 (100 perc) is black
            let color = self.gradientPicker.colorForPercentage(percentage).colorWithAlphaComponent(0.6)
            return ChartBarModel(constant: ChartAxisValueFloat(CGFloat(index)), axisValue1: zero, axisValue2: ChartAxisValueFloat(tuple.val), bgColor: color)
        }
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let xValues = Array(stride(from: -80, through: 80, by: 20)).map {ChartAxisValueFloat($0, labelSettings: labelSettings)}
        let yValues =
            [ChartAxisValueString(order: -1)] +
            Array(enumerate(vals)).map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
            [ChartAxisValueString(order: vals.count)]
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))

        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        
        // calculate coords space in the background to keep UI smooth
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let coordsSpace = ChartCoordsSpaceLeftTopSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
                
                let barsLayer = ChartBarsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: true, barWidth: Env.iPad ? 40 : 16, animDuration: 0.5)
                
                var settings = ChartGuideLinesLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
                let guidelinesLayer = ChartGuideLinesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: .X, settings: settings)
                
                // create x zero guideline as view to be in front of the bars
                let dummyZeroXChartPoint = ChartPoint(x: ChartAxisValueFloat(0), y: ChartAxisValueFloat(0))
                let xZeroGuidelineLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: [dummyZeroXChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
                    let width: CGFloat = 2
                    let v = UIView(frame: CGRectMake(chartPointModel.screenLoc.x - width / 2, innerFrame.origin.y, width, innerFrame.size.height))
                    v.backgroundColor = UIColor(red: 1, green: 69 / 255, blue: 0, alpha: 1)
                    return v
                })
                
                let chart = Chart(
                    frame: chartFrame,
                    layers: [
                        xAxis,
                        yAxis,
                        guidelinesLayer,
                        barsLayer,
                        xZeroGuidelineLayer
                    ]
                )
                
                self.view.addSubview(chart.view)
                self.chart = chart
            }
        }
    }
    
    private class GradientPicker {
        
        let gradientImg: UIImage
        
        lazy var imgData: UnsafePointer<UInt8> = {
            let provider = CGImageGetDataProvider(self.gradientImg.CGImage)
            let pixelData = CGDataProviderCopyData(provider)
            return CFDataGetBytePtr(pixelData)
        }()
        
        init(width: CGFloat) {
            
            var gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = CGRectMake(0, 0, width, 1)
            gradient.colors = [UIColor.redColor().CGColor, UIColor.yellowColor().CGColor, UIColor.cyanColor().CGColor, UIColor.blueColor().CGColor]
            gradient.startPoint = CGPointMake(0, 0.5)
            gradient.endPoint = CGPointMake(1.0, 0.5)
            
            let imgHeight = 1
            let imgWidth = Int(gradient.bounds.size.width)
            
            let bitmapBytesPerRow = imgWidth * 4
            let bitmapByteCount = bitmapBytesPerRow * imgHeight
            
            let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
            
            let context = CGBitmapContextCreate (nil,
                imgWidth,
                imgHeight,
                8,
                bitmapBytesPerRow,
                colorSpace,
                bitmapInfo)
            
            UIGraphicsBeginImageContext(gradient.bounds.size)
            gradient.renderInContext(context)
            let gradientImg = UIImage(CGImage: CGBitmapContextCreateImage(context))!
            
            UIGraphicsEndImageContext()
            self.gradientImg = gradientImg
        }
        
        func colorForPercentage(percentage: CGFloat) -> UIColor {
            
            let data = self.imgData
            
            let xNotRounded = self.gradientImg.size.width * percentage
            let x = 4 * (floor(abs(xNotRounded / 4)))
            let pixelIndex = Int(x * 4)
            
            let color = UIColor(
                red: CGFloat(data[pixelIndex + 0]) / 255.0,
                green: CGFloat(data[pixelIndex + 1]) / 255.0,
                blue: CGFloat(data[pixelIndex + 2]) / 255.0,
                alpha: CGFloat(data[pixelIndex + 3]) / 255.0
            )
            return color
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}





