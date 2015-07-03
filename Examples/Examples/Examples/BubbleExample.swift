//
//  ScatterExample.swift
//  Examples
//
//  Created by ischuetz on 16/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import CoreGraphics

class BubbleExample: UIViewController {

    private var chart: Chart?
    
    private let colorBarHeight: CGFloat = 50

    private let useViewsLayer = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - colorBarHeight)
        let colorBar = ColorBar(frame: CGRectMake(0, chartFrame.origin.y + chartFrame.size.height, self.view.frame.size.width, self.colorBarHeight), c1: UIColor.redColor(), c2: UIColor.greenColor())
        self.view.addSubview(colorBar)
        
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        func toColor(percentage: CGFloat) -> UIColor {
            return colorBar.colorForPercentage(percentage).colorWithAlphaComponent(0.6)
        }
        
        let chartPoints: [ChartPointBubble] = [
            (2, 2, 100, toColor(0)),
            (2.1, 5, 250, toColor(0)),
            (4, 4, 200, toColor(0.2)),
            (2.3, 5, 150, toColor(0.7)),
            (6, 7, 120, toColor(0.9)),
            (8, 3, 50, toColor(1)),
            (2, 4.5, 80, toColor(0.7)),
            (2, 5.2, 50, toColor(0.4)),
            (2, 4, 100, toColor(0.3)),
            (2.7, 5.5, 200, toColor(0.5)),
            (1.7, 2.8, 150, toColor(0.7)),
            (4.4, 8, 120, toColor(0.9)),
            (5, 6.3, 250, toColor(1)),
            (6, 8, 100, toColor(0)),
            (4, 8.5, 200, toColor(0.5)),
            (8, 5, 200, toColor(0.6)),
            (8.5, 10, 150, toColor(0.7)),
            (9, 11, 120, toColor(0.6)),
            (10, 6, 100, toColor(1)),
            (11, 7, 100, toColor(0)),
            (11, 4, 200, toColor(0.5)),
            (11.5, 10, 150, toColor(0.7)),
            (12, 7, 120, toColor(0.9)),
            (12, 9, 250, toColor(0.8))
            
        ].map{ChartPointBubble(x: ChartAxisValueFloat(CGFloat($0), labelSettings: labelSettings), y: ChartAxisValueFloat(CGFloat($1)), diameterScalar: $2, bgColor: $3)}

        let xValues = Array(stride(from: -2, through: 14, by: 2)).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = Array(stride(from: -2, through: 12, by: 2)).map {ChartAxisValueInt($0, labelSettings: labelSettings)}

        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.redColor(), animDuration: 0.5, animDelay: 0)
        
        let bubbleLayer = self.bubblesLayer(xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame, chartPoints: chartPoints)
        
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: guidelinesLayerSettings)

        let guidelinesHighlightLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.redColor(), linesWidth: 1, dotWidth: 4, dotSpacing: 4)
        let guidelinesHighlightLayer = ChartGuideLinesForValuesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: guidelinesHighlightLayerSettings, axisValuesX: [ChartAxisValueFloat(0)], axisValuesY: [ChartAxisValueFloat(0)])
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                guidelinesHighlightLayer,
                bubbleLayer
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    // We can use a view based layer for easy animation (or interactivity), in which case we use the default chart points layer with a generator to create bubble views.
    // On the other side, if we don't need animation or want a better performance, we use ChartPointsBubbleLayer, which instead of creating views, renders directly to the chart's context.
    private func bubblesLayer(#xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect, chartPoints: [ChartPointBubble]) -> ChartLayer {
        
        let maxBubbleDiameter: CGFloat = 30, minBubbleDiameter: CGFloat = 2
        
        if self.useViewsLayer == true {
                
            let (minDiameterScalar: CGFloat, maxDiameterScalar: CGFloat) = chartPoints.reduce((min: CGFloat(0), max: CGFloat(0))) {tuple, chartPoint in
                (min: min(tuple.min, chartPoint.diameterScalar), max: max(tuple.max, chartPoint.diameterScalar))
            }
            
            let diameterFactor = (maxBubbleDiameter - minBubbleDiameter) / (maxDiameterScalar - minDiameterScalar)

            return ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints, viewGenerator: {(chartPointModel, layer, chart) -> UIView? in

                let diameter = chartPointModel.chartPoint.diameterScalar * diameterFactor
                
                let rect = CGRectMake(chartPointModel.screenLoc.x - diameter / 2, chartPointModel.screenLoc.y - diameter / 2, diameter, diameter)
                let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: diameter)
                circleView.fillColor = chartPointModel.chartPoint.bgColor
                circleView.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
                circleView.borderWidth = 1
                circleView.animDelay = Float(chartPointModel.index) * 0.2
                circleView.animDuration = 1.2
                circleView.animDamping = 0.4
                circleView.animInitSpringVelocity = 0.5
                return circleView
            })
            
        } else {
            return ChartPointsBubbleLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: chartInnerFrame, chartPoints: chartPoints)
        }
    }

    class ColorBar: UIView {
        
        let dividers: [CGFloat]
        
        let gradientImg: UIImage
        
        lazy var imgData: UnsafePointer<UInt8> = {
            let provider = CGImageGetDataProvider(self.gradientImg.CGImage)
            let pixelData = CGDataProviderCopyData(provider)
            return CFDataGetBytePtr(pixelData)
        }()
        
        init(frame: CGRect, c1: UIColor, c2: UIColor) {
            
            var gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = CGRectMake(0, 0, frame.width, 30)
            gradient.colors = [UIColor.blueColor().CGColor, UIColor.cyanColor().CGColor, UIColor.yellowColor().CGColor, UIColor.redColor().CGColor]
            gradient.startPoint = CGPointMake(0, 0.5)
            gradient.endPoint = CGPointMake(1.0, 0.5)


            let imgHeight = 1
            let imgWidth = Int(gradient.bounds.size.width)
            
            let bitmapBytesPerRow = imgWidth * 4
            let bitmapByteCount = bitmapBytesPerRow * imgHeight
            
            let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
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
            
            let segmentSize = gradient.frame.size.width / 6
            self.dividers = Array(stride(from: segmentSize, through: gradient.frame.size.width, by: segmentSize))

            super.init(frame: frame)

            self.layer.insertSublayer(gradient, atIndex: 0)
            
            let numberFormatter = NSNumberFormatter()
            numberFormatter.maximumFractionDigits = 2
            
            for x in stride(from: segmentSize, through: gradient.frame.size.width - 1, by: segmentSize) {
                
                let dividerW: CGFloat = 1
                let divider = UIView(frame: CGRectMake(x - dividerW / 2, 25, dividerW, 5))
                divider.backgroundColor = UIColor.blackColor()
                self.addSubview(divider)
                
                let text = "\(numberFormatter.stringFromNumber(x / gradient.frame.size.width)!)"
                let labelWidth = ChartUtils.textSize(text, font: ExamplesDefaults.labelFont).width
                let label = UILabel()
                label.center = CGPointMake(x - labelWidth / 2, 30)
                label.font = ExamplesDefaults.labelFont
                label.text = text
                label.sizeToFit()

                self.addSubview(label)
            }
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
