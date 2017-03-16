//
//  ScatterExample.swift
//  Examples
//
//  Created by ischuetz on 16/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import CoreGraphics
import SwiftCharts

class BubbleExample: UIViewController {

    fileprivate var chart: Chart?
    
    fileprivate let colorBarHeight: CGFloat = 50

    fileprivate let useViewsLayer = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = ExamplesDefaults.chartFrame(view.bounds)
        let chartFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height - colorBarHeight)
        let colorBar = ColorBar(frame: CGRect(x: 0, y: chartFrame.origin.y + chartFrame.size.height, width: view.frame.size.width, height: colorBarHeight), c1: UIColor.red, c2: UIColor.green)
        view.addSubview(colorBar)
        
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        func toColor(_ percentage: Double) -> UIColor {
            return colorBar.colorForPercentage(percentage).withAlphaComponent(0.6)
        }

        let rawData: [(Double, Double, Double, UIColor)] = [
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
        ]

        let chartPoints: [ChartPointBubble] = rawData.map{ChartPointBubble(x: ChartAxisValueDouble($0, labelSettings: labelSettings), y: ChartAxisValueDouble($1), diameterScalar: $2, bgColor: $3)}

        let xValues = stride(from: -2, through: 14, by: 2).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = stride(from: -2, through: 12, by: 2).map {ChartAxisValueInt($0, labelSettings: labelSettings)}

        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))

        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let bubbleLayer = bubblesLayer(xAxisLayer, yAxisLayer: yAxisLayer, chartInnerFrame: innerFrame, chartPoints: chartPoints)
        
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)

        let guidelinesHighlightLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.red, linesWidth: 1, dotWidth: 4, dotSpacing: 4)
        let guidelinesHighlightLayer = ChartGuideLinesForValuesDottedLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, settings: guidelinesHighlightLayerSettings, axisValuesX: [ChartAxisValueDouble(0)], axisValuesY: [ChartAxisValueDouble(0)])
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                guidelinesHighlightLayer,
                bubbleLayer
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }
    
    // We can use a view based layer for easy animation (or interactivity), in which case we use the default chart points layer with a generator to create bubble views.
    // On the other side, if we don't need animation or want a better performance, we use ChartPointsBubbleLayer, which instead of creating views, renders directly to the chart's context.
    fileprivate func bubblesLayer(_ xAxisLayer: ChartAxisLayer, yAxisLayer: ChartAxisLayer, chartInnerFrame: CGRect, chartPoints: [ChartPointBubble]) -> ChartLayer {
        
        let maxBubbleDiameter: Double = 30, minBubbleDiameter: Double = 2
        
        if useViewsLayer == true {
                
            let (minDiameterScalar, maxDiameterScalar): (Double, Double) = chartPoints.reduce((min: 0, max: 0)) {tuple, chartPoint in
                (min: min(tuple.min, chartPoint.diameterScalar), max: max(tuple.max, chartPoint.diameterScalar))
            }
            
            let diameterFactor = (maxBubbleDiameter - minBubbleDiameter) / (maxDiameterScalar - minDiameterScalar)

            return ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: {(chartPointModel, layer, chart) -> UIView? in

                let diameter = CGFloat(chartPointModel.chartPoint.diameterScalar * diameterFactor)
                
                let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: diameter)
                circleView.fillColor = chartPointModel.chartPoint.bgColor
                circleView.borderColor = UIColor.black.withAlphaComponent(0.6)
                circleView.borderWidth = 1
                
                circleView.animDelay = Float(chartPointModel.index) * 0.2
                circleView.animDuration = 1.2
                circleView.animDamping = 0.4
                circleView.animInitSpringVelocity = 0.5
            
                return circleView
            })
            
        } else {
            return ChartPointsBubbleLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints)
        }
    }

    class ColorBar: UIView {
        
        let dividers: [CGFloat]
        
        let gradientImg: UIImage
        
        lazy private(set) var imgData: UnsafePointer<UInt8> = {
            let provider = self.gradientImg.cgImage!.dataProvider
            let pixelData = provider!.data
            return CFDataGetBytePtr(pixelData)
        }()
        
        init(frame: CGRect, c1: UIColor, c2: UIColor) {
            
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = CGRect(x: 0, y: 0, width: frame.width, height: 30)
            gradient.colors = [UIColor.blue.cgColor, UIColor.cyan.cgColor, UIColor.yellow.cgColor, UIColor.red.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)


            let imgHeight = 1
            let imgWidth = Int(gradient.bounds.size.width)
            
            let bitmapBytesPerRow = imgWidth * 4
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue

            let context = CGContext (data: nil,
                width: imgWidth,
                height: imgHeight,
                bitsPerComponent: 8,
                bytesPerRow: bitmapBytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo)
            
            UIGraphicsBeginImageContext(gradient.bounds.size)
            gradient.render(in: context!)
            
            let gradientImg = UIImage(cgImage: context!.makeImage()!)
            
            UIGraphicsEndImageContext()
            self.gradientImg = gradientImg
            
            let segmentSize = gradient.frame.size.width / 6
            dividers = Array(stride(from: segmentSize, through: gradient.frame.size.width, by: segmentSize))

            super.init(frame: frame)

            layer.insertSublayer(gradient, at: 0)
            
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 2
            
            for x in stride(from: segmentSize, through: gradient.frame.size.width - 1, by: segmentSize) {
                
                let dividerW: CGFloat = 1
                let divider = UIView(frame: CGRect(x: x - dividerW / 2, y: 25, width: dividerW, height: 5))
                divider.backgroundColor = UIColor.black
                addSubview(divider)
                
                let text = "\(numberFormatter.string(from: NSNumber(value: Float(x / gradient.frame.size.width)))!)"
                let labelWidth = text.width(ExamplesDefaults.labelFont)
                let label = UILabel()
                label.center = CGPoint(x: x - labelWidth / 2, y: 30)
                label.font = ExamplesDefaults.labelFont
                label.text = text
                label.sizeToFit()

                addSubview(label)
            }
        }
        
        func colorForPercentage(_ percentage: Double) -> UIColor {

            let data = imgData
            
            let xNotRounded = gradientImg.size.width * CGFloat(percentage)
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
