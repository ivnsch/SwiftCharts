//
//  BarsPlusMinusWithGradientExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class BarsPlusMinusWithGradientExample: UIViewController {
    
    fileprivate var chart: Chart? // arc
    
    fileprivate let gradientPicker: GradientPicker? // to pick the colors of the bars
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        gradientPicker = GradientPicker(width: 200)
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
        
        let (minVal, maxVal): (CGFloat, CGFloat) = vals.reduce((min: CGFloat(0), max: CGFloat(0))) {tuple, val in
            (min: min(tuple.min, val.val), max: max(tuple.max, val.val))
        }
        let length: CGFloat = maxVal - minVal
        
        let zero = ChartAxisValueDouble(0)
        let bars: [ChartBarModel] = vals.enumerated().map {index, tuple in
            let percentage = (tuple.val - minVal - 0.01) / length // FIXME without -0.01 bar with 1 (100 perc) is black
            let color = gradientPicker?.colorForPercentage(percentage).withAlphaComponent(0.6) ?? {print("No gradient picker, defaulting to black"); return UIColor.black}()
            return ChartBarModel(constant: ChartAxisValueDouble(Double(index)), axisValue1: zero, axisValue2: ChartAxisValueDouble(Double(tuple.val)), bgColor: color)
        }
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        let xGenerator = ChartAxisGeneratorMultiplier(20)
        
        let xModel = ChartAxisModel(firstModelValue: -80, lastModelValue: 80, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings)], axisValuesGenerator: xGenerator, labelsGenerator: labelsGenerator)

        let yValues = [ChartAxisValueString(order: -1)] + vals.enumerated().map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} + [ChartAxisValueString(order: vals.count)]
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        // calculate coords space in the background to keep UI smooth
        DispatchQueue.global(qos: .background).async {
            
            let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

            let coordsSpace = ChartCoordsSpaceLeftTopSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
            
            DispatchQueue.main.async {
                
                let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
                
                let barViewSettings = ChartBarViewSettings(animDuration: 0.5, selectionViewUpdater: ChartViewSelectorBrightness(selectedFactor: 0.5))
                let barsLayer = ChartBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, bars: bars, horizontal: true, barWidth: Env.iPad ? 40 : 16, settings: barViewSettings)
                
                let settings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
                let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: .x, settings: settings)
                
                // create x zero guideline as view to be in front of the bars
                let dummyZeroXChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
                let xZeroGuidelineLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: [dummyZeroXChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
                    let width: CGFloat = 2
                    let v = UIView(frame: CGRect(x: chartPointModel.screenLoc.x - width / 2, y: chart.contentView.bounds.origin.y, width: width, height: innerFrame.size.height))
                    v.backgroundColor = UIColor(red: 1, green: 69 / 255, blue: 0, alpha: 1)
                    return v
                })
                
                let chart = Chart(
                    frame: chartFrame,
                    innerFrame: innerFrame,
                    settings: chartSettings,
                    layers: [
                        xAxisLayer,
                        yAxisLayer,
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
    
    fileprivate class GradientPicker {
        
        let gradientImg: UIImage
        
        lazy private(set) var imgData: UnsafePointer<UInt8>? = {
            let pixelData = self.gradientImg.cgImage?.dataProvider?.data
            return CFDataGetBytePtr(pixelData)
        }()
        
        init?(width: CGFloat) {
            
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = CGRect(x: 0, y: 0, width: width, height: 1)
            gradient.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor, UIColor.cyan.cgColor, UIColor.blue.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            let imgHeight = 1
            let imgWidth = Int(gradient.bounds.size.width)
            
            let bitmapBytesPerRow = imgWidth * 4
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue

            guard let context = CGContext(data: nil,
                width: imgWidth,
                height: imgHeight,
                bitsPerComponent: 8,
                bytesPerRow: bitmapBytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo) else {
                    print("Couldn't create context")
                    return nil
            }
            
            UIGraphicsBeginImageContext(gradient.bounds.size)
            gradient.render(in: context)
            
            guard let gradientImg = (context.makeImage().map{UIImage(cgImage: $0)}) else {
                print("Couldn't create image")
                UIGraphicsEndImageContext()
                return nil
            }

            UIGraphicsEndImageContext()
            self.gradientImg = gradientImg
        }
        
        func colorForPercentage(_ percentage: CGFloat) -> UIColor {
            guard let data = imgData else {print("Couldn't get imgData, returning black"); return UIColor.black}
            
            let xNotRounded = gradientImg.size.width * percentage
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





