//
//  MultiTrackerExample.swift
//  SwiftCharts
//
//  Created by Nate Racklyeft on 6/25/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

// Configuration
private extension UIColor {
    static let secondaryLabelColor = UIColor(red: 142 / 255, green: 142 / 255, blue: 147 / 255, alpha: 1)

    static let gridColor = UIColor(white: 193 / 255, alpha: 1)

    static let glucoseTintColor = UIColor(red: 96 / 255, green: 201 / 255, blue: 248 / 255, alpha: 1)

    static let IOBTintColor: UIColor = UIColor(red: 254 / 255, green: 149 / 255, blue: 38 / 255, alpha: 1)
}

private let dateFormatter: DateFormatter = {
    let timeFormatter = DateFormatter()
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short
    
    return timeFormatter
}()

private let localDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    return dateFormatter
}()

private let decimalFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2

    return numberFormatter
}()

// MARK – Fixture data

private let glucosePoints: [ChartPoint] = [("2016-02-28T07:26:38", 95), ("2016-02-28T07:31:38", 93), ("2016-02-28T07:41:39", 92), ("2016-02-28T07:51:42", 92), ("2016-02-28T07:56:38", 94), ("2016-02-28T08:01:39", 94), ("2016-02-28T08:06:38", 95), ("2016-02-28T08:11:37", 95), ("2016-02-28T08:16:40", 100), ("2016-02-28T08:21:39", 99), ("2016-02-28T08:26:39", 99), ("2016-02-28T08:31:38", 97), ("2016-02-28T08:51:43", 101), ("2016-02-28T08:56:39", 105), ("2016-02-28T09:01:43", 101), ("2016-02-28T09:06:37", 102), ("2016-02-28T09:11:37", 107), ("2016-02-28T09:16:38", 109), ("2016-02-28T09:21:37", 113), ("2016-02-28T09:26:41", 114), ("2016-02-28T09:31:37", 112), ("2016-02-28T09:36:39", 111), ("2016-02-28T09:41:40", 111), ("2016-02-28T09:46:43", 112), ("2016-02-28T09:51:38", 113), ("2016-02-28T09:56:43", 112), ("2016-02-28T10:01:38", 111), ("2016-02-28T10:06:42", 112), ("2016-02-28T10:11:37", 115), ("2016-02-28T10:16:42", 119), ("2016-02-28T10:21:42", 121), ("2016-02-28T10:26:38", 127), ("2016-02-28T10:31:36", 129), ("2016-02-28T10:36:37", 132), ("2016-02-28T10:41:38", 135), ("2016-02-28T10:46:37", 138), ("2016-02-28T10:51:36", 137), ("2016-02-28T10:56:38", 141), ("2016-02-28T11:01:37", 146), ("2016-02-28T11:06:40", 151), ("2016-02-28T11:16:37", 163), ("2016-02-28T11:21:36", 169), ("2016-02-28T11:26:37", 177), ("2016-02-28T11:31:37", 183), ("2016-02-28T11:36:37", 187), ("2016-02-28T11:41:36", 190), ("2016-02-28T11:46:36", 192), ("2016-02-28T11:51:36", 194), ("2016-02-28T11:56:36", 194), ("2016-02-28T12:01:37", 192), ("2016-02-28T12:06:41", 192), ("2016-02-28T12:11:36", 183), ("2016-02-28T12:16:38", 176), ("2016-02-28T12:21:39", 165), ("2016-02-28T12:26:38", 156), ("2016-02-28T12:31:37", 144), ("2016-02-28T12:36:36", 138), ("2016-02-28T12:41:37", 131), ("2016-02-28T12:46:37", 125), ("2016-02-28T12:51:36", 118), ("2016-02-28T13:01:43", 104), ("2016-02-28T13:06:45", 97), ("2016-02-28T13:11:39", 92), ("2016-02-28T13:16:37", 88), ("2016-02-28T13:21:36", 88)].map {
    return ChartPoint(
        x: ChartAxisValueDate(date: localDateFormatter.date(from: $0.0)!, formatter: dateFormatter),
        y: ChartAxisValueInt($0.1)
    )
}

private let predictedGlucosePoints: [ChartPoint] = [("2016-02-28T13:21:36", 88), ("2016-02-28T13:25:00", 87), ("2016-02-28T13:30:00", 85), ("2016-02-28T13:35:00", 83), ("2016-02-28T13:40:00", 81), ("2016-02-28T13:45:00", 81), ("2016-02-28T13:50:00", 81), ("2016-02-28T13:55:00", 83), ("2016-02-28T14:00:00", 84), ("2016-02-28T14:05:00", 87), ("2016-02-28T14:10:00", 90), ("2016-02-28T14:15:00", 93), ("2016-02-28T14:20:00", 97), ("2016-02-28T14:25:00", 102), ("2016-02-28T14:30:00", 107), ("2016-02-28T14:35:00", 113), ("2016-02-28T14:40:00", 120), ("2016-02-28T14:45:00", 128), ("2016-02-28T14:50:00", 136), ("2016-02-28T14:55:00", 145), ("2016-02-28T15:00:00", 154), ("2016-02-28T15:05:00", 163), ("2016-02-28T15:10:00", 172), ("2016-02-28T15:15:00", 179), ("2016-02-28T15:20:00", 187), ("2016-02-28T15:25:00", 194), ("2016-02-28T15:30:00", 200), ("2016-02-28T15:35:00", 206), ("2016-02-28T15:40:00", 211), ("2016-02-28T15:45:00", 215), ("2016-02-28T15:50:00", 219), ("2016-02-28T15:55:00", 223), ("2016-02-28T16:00:00", 226), ("2016-02-28T16:05:00", 228), ("2016-02-28T16:10:00", 230), ("2016-02-28T16:15:00", 231), ("2016-02-28T16:20:00", 231), ("2016-02-28T16:25:00", 231), ("2016-02-28T16:30:00", 230), ("2016-02-28T16:35:00", 230), ("2016-02-28T16:40:00", 229), ("2016-02-28T16:45:00", 228), ("2016-02-28T16:50:00", 227), ("2016-02-28T16:55:00", 226), ("2016-02-28T17:00:00", 225), ("2016-02-28T17:05:00", 224), ("2016-02-28T17:10:00", 224), ("2016-02-28T17:15:00", 223), ("2016-02-28T17:20:00", 222), ("2016-02-28T17:25:00", 221), ("2016-02-28T17:30:00", 221), ("2016-02-28T17:35:00", 220), ("2016-02-28T17:40:00", 219), ("2016-02-28T17:45:00", 219), ("2016-02-28T17:50:00", 218), ("2016-02-28T17:55:00", 218), ("2016-02-28T18:00:00", 218), ("2016-02-28T18:05:00", 218), ("2016-02-28T18:10:00", 218)].map {
    return ChartPoint(
        x: ChartAxisValueDate(date: localDateFormatter.date(from: $0.0)!, formatter: dateFormatter),
        y: ChartAxisValueInt($0.1)
    )
}

private let IOBPoints: [ChartPoint] = [("2016-02-28T07:25:00", 0.0), ("2016-02-28T07:30:00", 0.0036944444444472783), ("2016-02-28T07:35:00", -0.041666666666665263), ("2016-02-28T07:40:00", -0.11298963260090503), ("2016-02-28T07:45:00", -0.18364018193611475), ("2016-02-28T07:50:00", -0.17905627846292443), ("2016-02-28T07:55:00", -0.19834382681098695), ("2016-02-28T08:00:00", -0.19192177354344478), ("2016-02-28T08:05:00", -0.18546870465908208), ("2016-02-28T08:10:00", -0.17906574601611175), ("2016-02-28T08:15:00", -0.17135469795520025), ("2016-02-28T08:20:00", -0.16450124880944814), ("2016-02-28T08:25:00", -0.18095248614585058), ("2016-02-28T08:30:00", -0.17286981664792092), ("2016-02-28T08:35:00", -0.1649428517240436), ("2016-02-28T08:40:00", -0.15630024940346263), ("2016-02-28T08:45:00", -0.15564973761315049), ("2016-02-28T08:50:00", -0.15484465042603354), ("2016-02-28T08:55:00", -0.15385632304648592), ("2016-02-28T09:00:00", -0.14503406786881623), ("2016-02-28T09:05:00", -0.13560430142200144), ("2016-02-28T09:10:00", 4.1236760598368143), ("2016-02-28T09:15:00", 4.7580045858653408), ("2016-02-28T09:20:00", 4.797507610088223), ("2016-02-28T09:25:00", 4.7470649930859192), ("2016-02-28T09:30:00", 4.8073808321227238), ("2016-02-28T09:35:00", 4.7574313425927555), ("2016-02-28T09:40:00", 4.6956867789037213), ("2016-02-28T09:45:00", 4.6245111681877402), ("2016-02-28T09:50:00", 4.5433444176942741), ("2016-02-28T09:55:00", 4.431270599886326), ("2016-02-28T10:00:00", 4.3347991573984439), ("2016-02-28T10:05:00", 4.232130329715214), ("2016-02-28T10:10:00", 4.123473669887483), ("2016-02-28T10:15:00", 4.1849607740674131), ("2016-02-28T10:20:00", 4.2908357326261486), ("2016-02-28T10:25:00", 4.3923300950301805), ("2016-02-28T10:30:00", 4.4880804898394571), ("2016-02-28T10:35:00", 4.5795239011041415), ("2016-02-28T10:40:00", 4.6167066079119099), ("2016-02-28T10:45:00", 4.648763226113056), ("2016-02-28T10:50:00", 4.5757548336618656), ("2016-02-28T10:55:00", 4.5483941239244547), ("2016-02-28T11:00:00", 4.4669082248258229), ("2016-02-28T11:05:00", 4.3572781110626684), ("2016-02-28T11:10:00", 4.2448651414495249), ("2016-02-28T11:15:00", 4.1302836952228299), ("2016-02-28T11:20:00", 4.8644613141889321), ("2016-02-28T11:25:00", 4.7735479450092804), ("2016-02-28T11:30:00", 4.6763723172632066), ("2016-02-28T11:35:00", 4.6263678363933698), ("2016-02-28T11:40:00", 4.6252248376336471), ("2016-02-28T11:45:00", 4.6715820280965836), ("2016-02-28T11:50:00", 4.6657775819812244), ("2016-02-28T11:55:00", 4.6070572580733025), ("2016-02-28T12:00:00", 4.3991804144755005), ("2016-02-28T12:05:00", 4.2207285890562476), ("2016-02-28T12:10:00", 4.0174866626399064), ("2016-02-28T12:15:00", 3.8273922804263738), ("2016-02-28T12:20:00", 3.6385602030825925), ("2016-02-28T12:25:00", 3.3894133230689309), ("2016-02-28T12:30:00", 3.1420958613914309), ("2016-02-28T12:35:00", 2.8973159487084286), ("2016-02-28T12:40:00", 2.6562913087973756), ("2016-02-28T12:45:00", 2.4197470432113661), ("2016-02-28T12:50:00", 2.1866578462641546), ("2016-02-28T12:55:00", 1.9592879884763279), ("2016-02-28T13:00:00", 1.7368620414389135), ("2016-02-28T13:05:00", 1.5198636712336329), ("2016-02-28T13:10:00", 1.3089436183182606), ("2016-02-28T13:15:00", 1.1535104030437469), ("2016-02-28T13:20:00", 1.029259238414155), ("2016-02-28T13:25:00", 0.92424875183689581), ("2016-02-28T13:30:00", 1.0693214999513172), ("2016-02-28T13:35:00", 1.2179252372806773), ("2016-02-28T13:40:00", 1.3686107583250724), ("2016-02-28T13:45:00", 1.5216601122146722), ("2016-02-28T13:50:00", 1.6756373722393785), ("2016-02-28T13:55:00", 1.830049276750918), ("2016-02-28T14:00:00", 1.7552739393101593), ("2016-02-28T14:05:00", 1.6800326149026008), ("2016-02-28T14:10:00", 1.6045615612089266), ("2016-02-28T14:15:00", 1.529552685984469), ("2016-02-28T14:20:00", 1.4551922972209459), ("2016-02-28T14:25:00", 1.3816704659238352), ("2016-02-28T14:30:00", 1.3106997507187577), ("2016-02-28T14:35:00", 1.2427108235823778), ("2016-02-28T14:40:00", 1.1777114790667285), ("2016-02-28T14:45:00", 1.1156548582553669), ("2016-02-28T14:50:00", 1.0565416809216186), ("2016-02-28T14:55:00", 0.99991680907617442), ("2016-02-28T15:00:00", 0.94574181090268616), ("2016-02-28T15:05:00", 0.89311904821375931), ("2016-02-28T15:10:00", 0.84250915821388683), ("2016-02-28T15:15:00", 0.79345730299880946), ("2016-02-28T15:20:00", 0.74576518876929832), ("2016-02-28T15:25:00", 0.69945200554164288), ("2016-02-28T15:30:00", 0.65458567086334363), ("2016-02-28T15:35:00", 0.61866148080393324), ("2016-02-28T15:40:00", 0.58390071320767833), ("2016-02-28T15:45:00", 0.55029240045115302), ("2016-02-28T15:50:00", 0.51829806202973916), ("2016-02-28T15:55:00", 0.48838055766253852), ("2016-02-28T16:00:00", 0.46089759917798961), ("2016-02-28T16:05:00", 0.43533222555553236), ("2016-02-28T16:10:00", 0.41120094219970449), ("2016-02-28T16:15:00", 0.38717483135971792), ("2016-02-28T16:20:00", 0.36362072793021766), ("2016-02-28T16:25:00", 0.34038412512290156), ("2016-02-28T16:30:00", 0.31764547529085824), ("2016-02-28T16:35:00", 0.29545546750125873), ("2016-02-28T16:40:00", 0.27331799993023986), ("2016-02-28T16:45:00", 0.25131871047913684), ("2016-02-28T16:50:00", 0.22953602018938493), ("2016-02-28T16:55:00", 0.20804019837577364), ("2016-02-28T17:00:00", 0.18689329832809301), ("2016-02-28T17:05:00", 0.16615003800600928), ("2016-02-28T17:10:00", 0.14585543305215659), ("2016-02-28T17:15:00", 0.12604606271228064), ("2016-02-28T17:20:00", 0.10674921606115091), ("2016-02-28T17:25:00", 0.08799217115883326), ("2016-02-28T17:30:00", 0.070225506888435554), ("2016-02-28T17:35:00", 0.053631040821926462), ("2016-02-28T17:40:00", 0.037669241351902909), ("2016-02-28T17:45:00", 0.02475357068905246), ("2016-02-28T17:50:00", 0.014701054938544136), ("2016-02-28T17:55:00", 0.007335418533029334), ("2016-02-28T18:00:00", 0.0024882220451422584), ("2016-02-28T18:05:00", 0.0), ("2016-02-28T18:10:00", 0.0)].map {
    return ChartPoint(
        x: ChartAxisValueDate(date: localDateFormatter.date(from: $0.0)!, formatter: dateFormatter),
        y: ChartAxisValueDouble($0.1, formatter: decimalFormatter)
    )
}


private let axisLabelSettings: ChartLabelSettings = ChartLabelSettings()


class MultiTrackerExample: UIViewController, UIGestureRecognizerDelegate {
    
    fileprivate var topChart: Chart?
    
    fileprivate var bottomChart: Chart?
    
    fileprivate lazy private(set) var chartLongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    // MARK: – Chart configuration
    
    fileprivate lazy private(set) var chartSettings: ChartSettings = {
        var chartSettings = ChartSettings()
        chartSettings.top = 12
        chartSettings.bottom = 0
        chartSettings.trailing = 8
        chartSettings.axisTitleLabelsToLabelsSpacing = 0
        chartSettings.labelsToAxisSpacingX = 6
        chartSettings.clipInnerFrame = false
        return chartSettings
    }()
    
    private let guideLinesLayerSettings: ChartGuideLinesLayerSettings = ChartGuideLinesLayerSettings()
    
    fileprivate lazy private(set) var axisLineColor = UIColor.clear
    
    fileprivate var xAxisValues: [ChartAxisValue]? {
        didSet {
            if let xAxisValues = xAxisValues {
                xAxisModel = ChartAxisModel(axisValues: xAxisValues, lineColor: axisLineColor, labelSpaceReservationMode: .fixed(20))
            } else {
                xAxisModel = nil
            }
        }
    }
    
    fileprivate var xAxisModel: ChartAxisModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chartLongPressGestureRecognizer.delegate = self
        chartLongPressGestureRecognizer.minimumPressDuration = 0.01
        view.addGestureRecognizer(chartLongPressGestureRecognizer)

        generateXAxisValues()

        let fullFrame = ExamplesDefaults.chartFrame(view.bounds)
        let (topFrame, bottomFrame) = fullFrame.divided(atDistance: fullFrame.height / 2, from: .minYEdge)

        topChart = generateGlucoseChartWithFrame(topFrame)
        bottomChart = generateIOBChartWithFrame(frame: bottomFrame)

        for chart in [topChart, bottomChart] {
            if let view = chart?.view {
                self.view.addSubview(view)
            }
        }
    }
    
    fileprivate func generateXAxisValues() {
        let points = glucosePoints + predictedGlucosePoints

        guard points.count > 1 else {
            self.xAxisValues = []
            return
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h a"

        let xAxisValues = ChartAxisValuesStaticGenerator.generateXAxisValuesWithChartPoints(points, minSegmentCount: 5, maxSegmentCount: 10, multiple: TimeInterval(60 * 60), axisValueGenerator: { ChartAxisValueDate(date: ChartAxisValueDate.dateFromScalar($0), formatter: timeFormatter, labelSettings: axisLabelSettings)
            }, addPaddingSegmentIfEdge: false)
        xAxisValues.first?.hidden = true
        xAxisValues.last?.hidden = true

        self.xAxisValues = xAxisValues
    }
    
    fileprivate func generateGlucoseChartWithFrame(_ frame: CGRect) -> Chart? {
        guard glucosePoints.count > 1, let xAxisValues = xAxisValues, let xAxisModel = xAxisModel else {
            return nil
        }

        let allPoints = glucosePoints + predictedGlucosePoints

        // TODO: The segment/multiple values are unit-specific
        let yAxisValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(allPoints, minSegmentCount: 2, maxSegmentCount: 4, multiple: 25, axisValueGenerator: { ChartAxisValueDouble($0, labelSettings: axisLabelSettings)}, addPaddingSegmentIfEdge: true)

        let yAxisModel = ChartAxisModel(axisValues: yAxisValues, lineColor: axisLineColor, labelSpaceReservationMode: .fixed(30))

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: frame, xModel: xAxisModel, yModel: yAxisModel)

        let (xAxisLayer, yAxisLayer) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer)

        let gridLayer = ChartGuideLinesForValuesLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, settings: guideLinesLayerSettings, axisValuesX: Array(xAxisValues.dropLast(1)), axisValuesY: [])

        let circles = ChartPointsScatterCirclesLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: glucosePoints, displayDelay: 0, itemSize: CGSize(width: 4, height: 4), itemFillColor: UIColor.glucoseTintColor)

        var prediction: ChartLayer?

        if predictedGlucosePoints.count > 1 {
            let lineModel = ChartLineModel(
                chartPoints: predictedGlucosePoints,
                lineColor: UIColor.glucoseTintColor.withAlphaComponent(0.75),
                lineWidth: 1,
                animDuration: 0.0001,
                animDelay: 0,
                dashPattern: [6, 5]
            )

            prediction = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel])
        }

        let highlightLayer = ChartPointsTouchHighlightLayer(
            xAxisLayer: xAxisLayer,
            yAxisLayer: yAxisLayer,
            chartPoints: allPoints,
            tintColor: UIColor.glucoseTintColor,
            labelCenterY: chartSettings.top,
            gestureRecognizer: chartLongPressGestureRecognizer,
            onCompleteHighlight: nil
        )

        let layers: [ChartLayer?] = [
            gridLayer,
            xAxisLayer,
            yAxisLayer,
            highlightLayer,
            prediction,
            circles
        ]
        
        return Chart(frame: frame, innerFrame: coordsSpace.chartInnerFrame, settings: chartSettings, layers: layers.flatMap { $0 })
    }

    private func generateIOBChartWithFrame(frame: CGRect) -> Chart? {
        guard IOBPoints.count > 1, let xAxisValues = xAxisValues, let xAxisModel = xAxisModel else {
            return nil
        }

        var containerPoints = IOBPoints

        // Create a container line at 0
        if let first = IOBPoints.first {
            containerPoints.insert(ChartPoint(x: first.x, y: ChartAxisValueInt(0)), at: 0)
        }

        if let last = IOBPoints.last {
            containerPoints.append(ChartPoint(x: last.x, y: ChartAxisValueInt(0)))
        }

        let yAxisValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(IOBPoints, minSegmentCount: 2, maxSegmentCount: 3, multiple: 0.5, axisValueGenerator: { ChartAxisValueDouble($0, labelSettings: axisLabelSettings)}, addPaddingSegmentIfEdge: false)

        let yAxisModel = ChartAxisModel(axisValues: yAxisValues, lineColor: axisLineColor, labelSpaceReservationMode: .fixed(30))

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: frame, xModel: xAxisModel, yModel: yAxisModel)

        let (xAxisLayer, yAxisLayer) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer)
        let (xAxis, yAxis) = (xAxisLayer.axis, yAxisLayer.axis)

        // The IOB area
        let lineModel = ChartLineModel(chartPoints: IOBPoints, lineColor: UIColor.IOBTintColor, lineWidth: 2, animDuration: 0, animDelay: 0)
        let IOBLine = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, lineModels: [lineModel], pathGenerator: StraightLinePathGenerator())
        
        let IOBArea = ChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, chartPoints: containerPoints, areaColors: [UIColor.IOBTintColor.withAlphaComponent(0.75), UIColor.clear], animDuration: 0, animDelay: 0, addContainerPoints: false, pathGenerator: IOBLine.pathGenerator)
        
        // Grid lines
        let gridLayer = ChartGuideLinesForValuesLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, settings: guideLinesLayerSettings, axisValuesX: Array(xAxisValues.dropLast(1)), axisValuesY: yAxisValues)

        // 0-line
        let dummyZeroChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
        let zeroGuidelineLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, chartPoints: [dummyZeroChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let width: CGFloat = 0.5
            let viewFrame = CGRect(x: chart.contentView.bounds.minX, y: chartPointModel.screenLoc.y - width / 2, width: chart.contentView.bounds.size.width, height: width)

            let v = UIView(frame: viewFrame)
            v.backgroundColor = UIColor.IOBTintColor
            return v
        })

        let highlightLayer = ChartPointsTouchHighlightLayer(
            xAxisLayer: xAxisLayer,
            yAxisLayer: yAxisLayer,
            chartPoints: IOBPoints,
            tintColor: UIColor.IOBTintColor,
            labelCenterY: chartSettings.top,
            gestureRecognizer: chartLongPressGestureRecognizer,
            onCompleteHighlight: nil
        )

        let layers: [ChartLayer?] = [
            gridLayer,
            xAxisLayer,
            yAxisLayer,
            zeroGuidelineLayer,
            highlightLayer,
            IOBArea,
            IOBLine,
        ]

        return Chart(frame: frame, innerFrame: coordsSpace.chartInnerFrame, settings: chartSettings, layers: layers.flatMap { $0 })
    }
}


/*
 Here we extend ChartPointsTouchHighlightLayer to contain its initialization
 */
private extension ChartPointsTouchHighlightLayer {

    convenience init(
        xAxisLayer: ChartAxisLayer,
        yAxisLayer: ChartAxisLayer,
        chartPoints: [T],
        tintColor: UIColor,
        labelCenterY: CGFloat = 0,
        gestureRecognizer: UILongPressGestureRecognizer? = nil,
        onCompleteHighlight: (()->Void)? = nil
    ) {
        self.init(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, gestureRecognizer: gestureRecognizer, onCompleteHighlight: onCompleteHighlight,
                  modelFilter: { (screenLoc, chartPointModels) -> ChartPointLayerModel<T>? in
                    if let index = chartPointModels.map({ $0.screenLoc.x }).findClosestElementIndexToValue(screenLoc.x) {
                        return chartPointModels[index]
                    } else {
                        return nil
                    }
            },
                  viewGenerator: { (chartPointModel, layer, chart) -> U? in
                    let containerView = U(frame: chart.contentView.bounds)

                    let xAxisOverlayView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 3 + containerView.frame.size.height), size: xAxisLayer.frame.size))
                    xAxisOverlayView.backgroundColor = UIColor.white
                    xAxisOverlayView.isOpaque = true
                    containerView.addSubview(xAxisOverlayView)
                    
                    let point = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 16)
                    point.fillColor = tintColor.withAlphaComponent(0.5)
                    containerView.addSubview(point)
                    
                    if let text = chartPointModel.chartPoint.y.labels.first?.text {
                        let label = UILabel()
                        if #available(iOS 9.0, *) {
                            label.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
                        } else {
                            label.font = UIFont.systemFont(ofSize: 15)
                        }
                        
                        label.text = text
                        label.textColor = tintColor
                        label.textAlignment = .center
                        label.sizeToFit()
                        label.frame.size.height += 4
                        label.frame.size.width += label.frame.size.height / 2
                        label.center.y = containerView.frame.origin.y
                        label.center.x = chartPointModel.screenLoc.x
                        label.frame.origin.x = min(max(label.frame.origin.x, containerView.frame.origin.x), containerView.frame.maxX - label.frame.size.width)
                        label.frame.origin.makeIntegralInPlaceWithDisplayScale(chart.view.traitCollection.displayScale)
                        label.layer.borderColor = tintColor.cgColor
                        label.layer.borderWidth = 1 / chart.view.traitCollection.displayScale
                        label.layer.cornerRadius = label.frame.size.height / 2
                        label.backgroundColor = UIColor.white
                        
                        containerView.addSubview(label)
                    }
                    
                    if let text = chartPointModel.chartPoint.x.labels.first?.text {
                        let label = UILabel()
                        label.font = axisLabelSettings.font
                        label.text = text
                        label.textColor = axisLabelSettings.fontColor
                        label.sizeToFit()
                        label.center = CGPoint(x: chartPointModel.screenLoc.x, y: xAxisOverlayView.center.y)
                        label.frame.origin.makeIntegralInPlaceWithDisplayScale(chart.view.traitCollection.displayScale)
                        
                        containerView.addSubview(label)
                    }
                    
                    return containerView
            }
        )
    }
}


private extension CGPoint {
    /**
     Rounds the coordinates to whole-pixel values

     - parameter scale: The display scale to use. Defaults to the main screen scale.
     */
    mutating func makeIntegralInPlaceWithDisplayScale(_ scale: CGFloat = 0) {
        var scale = scale

        // It's possible for scale values retrieved from traitCollection objects to be 0.
        if scale == 0 {
            scale = UIScreen.main.scale
        }
        x = round(x * scale) / scale
        y = round(y * scale) / scale
    }
}


private extension BidirectionalCollection where Index: Strideable, Iterator.Element: Comparable, Index.Stride == Int {
    
    /**
     Returns the insertion index of a new value in a sorted collection

     Based on some helpful responses found at [StackOverflow](http://stackoverflow.com/a/33674192)

     - parameter value: The value to insert
     
     - returns: The appropriate insertion index, between `startIndex` and `endIndex`
     */
    func findInsertionIndexForValue(_ value: Iterator.Element) -> Index {
        var low = startIndex
        var high = endIndex

        while low != high {
            let mid = low.advanced(by: low.distance(to: high) / 2)
            
            if self[mid] < value {
                low = mid.advanced(by: 1)
            } else {
                high = mid
            }
        }

        return low
    }
}


private extension BidirectionalCollection where Index: Strideable, Iterator.Element: Strideable, Index.Stride == Int {
    /**
     Returns the index of the closest element to a specified value in a sorted collection

     - parameter value: The value to match

     - returns: The index of the closest element, or nil if the collection is empty
     */
    func findClosestElementIndexToValue(_ value: Iterator.Element) -> Index? {
        let upperBound = findInsertionIndexForValue(value)

        if upperBound == startIndex {
            if upperBound == endIndex {
                return nil
            }
            return upperBound
        }

        let lowerBound = upperBound.advanced(by: -1)

        if upperBound == endIndex {
            return lowerBound
        }

        if value.distance(to: self[upperBound]) < self[lowerBound].distance(to: value) {
            return upperBound
        }
        
        return lowerBound
    }
}
