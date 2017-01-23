//
//  ScatterExample.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

private enum MyExampleModelDataType {
    case type0, type1, type2, type3
}

private enum Shape {
    case triangle, square, circle, cross
}

class ScatterExample: UIViewController {

    fileprivate var chart: Chart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let models: [(x: Double, y: Double, type: MyExampleModelDataType)] = [
            (246.56, 138.98, .type1), (218.33, 132.71, .type0), (187.79, 127.48, .type0), (150.63, 135.5, .type0), (185.05, 152.57, .type3), (213.15, 155.71, .type1), (252.79, 158.85, .type2), (315.77, 150.62, .type0), (220.55, 149.57, .type3), (233.05, 163.08, .type1), (203.91, 179.46, .type2), (190.41, 158.73, .type2), (157.78, 137.16, .type3), (126.15, 147.57, .type3), (155.34, 172.28, .type1), (206.58, 151.36, .type0), (257.59, 127.41, .type1), (303.95, 126.36, .type1), (332.95, 141.86, .type0), (295.7, 156.5, .type2), (259.54, 169.05, .type2), (286.38, 177.41, .type1), (328.75, 165.96, .type3), (361.47, 137.07, .type1), (361.47, 137.07, .type3), (409.39, 128.71, .type3), (420.54, 180.41, .type2), (350.85, 187.73, .type2), (274.35, 205.86, .type2), (216.48, 180.76, .type3), (196.01, 210, .type1), (128.64, 151.85, .type2), (81.67, 83.32, .type0), (72.26, 48.12, .type0), (149.29, 59.62, .type3), (162.89, 105.28, .type3), (194.91, 74, .type2), (217.91, 101.89, .type3), (173.27, 103.98, .type1), (211.96, 141.62, .type2), (225.51, 127.07, .type2), (271.52, 95.7, .type0), (306.89, 123.66, .type2), (242.15, 144.57, .type2), (255.74, 177.34, .type2), (290.25, 163.75, .type0), (313.07, 123.89, .type1), (320.34, 94.05, .type0), (221.19, 119.15, .type3), (170.43, 83.68, .type1), (150.57, 133.79, .type1), (106.53, 176.61, .type3), (154.98, 158.84, .type2), (226.9, 156.84, .type1), (272.82, 136.62, .type1), (310.81, 121.98, .type0), (346.14, 134.44, .type2), (337.82, 155.17, .type0), (314.34, 155.17, .type3), (218.14, 145.76, .type3), (152.07, 159.21, .type3), (164.62, 187.1, .type2), (243.72, 187.1, .type3), (285.72, 188.14, .type3), (340.29, 158.09, .type0), (348.65, 112.62, .type1), (401.29, 65.21, .type2), (436.49, 42.21, .type1), (409.44, 92.17, .type3), (338.17, 138.39, .type1), (204.67, 112.25, .type2), (229.77, 82.27, .type1), (316.59, 78.32, .type3), (324.95, 49.74, .type0), (355.18, 69.17, .type2), (265.83, 89.99, .type1), (156.42, 62.89, .type0), (80.14, 92.68, .type2), (123.58, 126.8, .type0), (38.06, 92.38, .type1), (86.07, 121.48, .type3), (37.62, 167.49, .type2), (71.95, 147.62, .type1), (112.89, 150.76, .type1), (67.2, 166.4, .type3), (157.02, 165.79, .type2), (195.58, 176.25, .type2), (165.25, 128.5, .type3), (235.13, 85.62, .type2), (224.77, 138.54, .type0), (179.33, 129.83, .type0), (212.57, 159.67, .type3), (267.76, 117.84, .type0), (349.88, 81.29, .type2), (388.57, 137.62, .type0), (291.43, 155.39, .type3), (239.5, 149.12, .type0), (145.38, 159.23, .type3), (114.02, 195.48, .type2), (162.87, 195.48, .type1), (215.16, 190.25, .type1), (272.32, 206.98, .type1), (332.27, 205.93, .type3), (309.27, 169.68, .type1), (237.81, 152.95, .type1), (165.12, 159.14, .type2), (81.83, 146.63, .type0), (56.73, 76.22, .type3), (38.95, 50.43, .type0), (125.56, 96.3, .type1), (142.29, 51.61, .type1), (200.02, 98.27, .type0), (134.64, 81.59, .type2), (169.96, 126.1, .type0), (230.27, 94.73, .type0), (279.49, 95.77, .type3), (172.06, 125.49, .type2), (215.7, 149.36, .type0), (263.67, 122.26, .type2), (353.09, 136.9, .type3), (277.11, 135.86, .type1), (219.69, 146.31, .type1), (212.37, 164.79, .type3), (285.06, 161.7, .type0), (339.21, 174.11, .type3), (241.1, 166.79, .type3), (229.94, 168.88, .type0), (152.39, 176.89, .type1), (113.98, 183.12, .type0), (80.61, 194.62, .type3), (143.52, 202.99, .type0), (223.44, 187.45, .type2), (287.61, 198.95, .type2), (346.43, 208.27, .type2), (319.73, 176.64, .type2), (363.46, 135.95, .type1), (308.39, 154.42, .type2), (321.89, 170.71, .type0), (374.53, 180.82, .type1), (399.75, 213.87, .type1), (303.51, 212.13, .type3), (188.84, 227.12, .type2), (235.83, 248.01, .type3), (320.18, 219.78, .type0), (401.52, 198.87, .type3), (376.46, 152.99, .type3), (410.62, 109.07, .type3), (428.13, 119.7, .type3), (414.54, 164.31, .type2), (435.36, 200.47, .type2), (437.45, 234.63, .type3), (328.83, 193.85, .type3), (372.57, 191.76, .type3), (430.04, 213.62, .type3), (323.72, 158.2, .type0), (213.23, 109.06, .type2), (133.06, 111.15, .type2), (193.13, 98.6, .type3), (250.3, 93.37, .type0), (319.13, 97.55, .type1), (350.32, 134.62, .type1), (176.52, 122.07, .type1), (92.23, 100.9, .type1), (68.93, 88.05, .type2), (124.21, 158.23, .type3), (280.26, 172.13, .type3), (175.21, 172.96, .type2), (203.27, 186.51, .type3), (206.4, 95.68, .type2), (239.33, 79.04, .type1), (285.34, 80.08, .type3), (303.12, 109.01, .type2), (202.87, 138.29, .type2), (152.03, 102.74, .type1), (130.41, 160.11, .type3), (164.57, 137.11, .type3), (203.13, 145.47, .type2), (225.91, 168.2, .type2), (251, 142.41, .type1), (298.57, 140.32, .type2), (264.8, 199.57, .type2), (307.27, 207.85, .type1), (212.13, 219, .type2), (78.6, 213.77, .type2), (31.68, 244.1, .type1), (218.34, 116.63, .type0), (343.47, 65.39, .type1), (410.68, 44.62, .type0), (427.37, 73.81, .type2), (436.43, 204.17, .type3), (45.53, 32.38, .type2), (106.04, 67.79, .type2), (156.57, 108.6, .type1), (195.98, 71.18, .type0), (240.23, 93.96, .type2), (203.91, 112.65, .type2), (236.4, 126.15, .type2), (255.13, 92.91, .type0), (283.27, 111.6, .type2), (256.36, 159.82, .type3), (217.94, 134.86, .type1), (166.14, 158.21, .type2), (202.33, 182.73, .type3), (259.57, 183.69, .type1), (259.57, 183.69, .type2), (259.57, 135.82, .type1), (120.49, 152.9, .type0), (119.45, 112.34, .type0), (106.9, 172.64, .type1), (201.43, 221.75, .type2), (300.62, 182.24, .type3), (357.11, 173.88, .type2), (390.3, 173.88, .type3), (372.88, 219.19, .type1), (309.44, 171.09, .type2), (258.12, 95.89, .type1), (339.37, 108.43, .type2), (358.91, 122.5, .type2), (377.74, 137.84, .type1), (326, 140.97, .type2), (243.04, 115.53, .type1), (220.62, 99.98, .type0), (96.91, 150.9, .type0), (188.97, 163.4, .type1), (317.27, 193.54, .type2), (398.83, 234.32, .type0), (105.38, 179.99, .type3), (205.45, 105.63, .type1), (286.34, 126.18, .type2), (284.95, 140.47, .type1), (374.53, 122.69, .type0), (231.85, 159.27, .type1), (213.73, 195.17, .type2), (208.54, 153.53, .type0), (153.61, 151.39, .type3), (151.52, 119.38, .type2), (193.59, 110.37, .type2), (248.66, 113.5, .type1), (303.85, 122.91, .type2), (264.16, 155.29, .type3), (218.24, 128.19, .type1), (133.54, 115.29, .type3), (150.18, 162.03, .type3), (135.68, 173.44, .type3), (142.86, 180.23, .type2), (168.65, 175, .type2), (168.65, 175, .type0), (205.12, 172.91, .type2), (153.02, 180.23, .type3), (123.04, 166.63, .type1), (112.63, 135.96, .type1), (191.46, 140.1, .type2), (157.04, 155.79, .type2), (185.28, 124.46, .type1), (212.33, 129.64, .type1), (232.11, 158.43, .type0), (257.11, 129.34, .type1), (298.48, 106.52, .type1), (345.19, 131.96, .type2), (289.86, 151.83, .type0), (211.08, 190.87, .type1), (154.27, 241.06, .type2), (73.49, 226.42, .type0), (276.36, 75.29, .type3), (219.12, 119.98, .type3), (185.24, 83.17, .type3), (76.46, 51.45, .type0), (37.77, 37.51, .type3), (176.36, 124.21, .type0), (234.57, 126.3, .type0), (188.88, 137.71, .type1), (281.23, 149.21, .type1), (325.62, 151.3, .type1), (345.83, 152.35, .type2), (253.27, 153.35, .type3), (253.27, 153.35, .type2), (191.8, 174.21, .type0), (229.02, 179.31, .type1), (271.75, 174.08, .type1), (330.66, 163.62, .type1), (207.65, 165.71, .type0), (135.87, 179.26, .type0), (85.55, 136.22, .type3), (155.27, 137.27, .type1), (128.61, 108.78, .type3), (206.35, 111.91, .type0), (206.35, 111.91, .type0), (206.35, 111.91, .type2), (144.84, 147.33, .type2), (171.75, 135.92, .type1), (236.93, 117.1, .type2), (201.97, 135, .type3), (265.41, 80.62, .type3), (312.42, 96.21, .type1), (232, 141.18, .type0), (348.75, 132.65, .type1), (325.05, 108.6, .type0), (360.6, 137.79, .type2), (322.05, 162.88, .type0), (236.83, 179.57, .type0), (164.33, 119.96, .type2), (113.44, 107.41, .type1), (139.45, 136.46, .type0), (191.73, 136.46, .type2), (254.92, 130.23, .type2), (297.17, 142.09, .type3), (258.57, 150.45, .type2), (189.91, 168.23, .type1), (133.58, 168.23, .type1), (342.5, 166.09, .type3), (150.75, 127.58, .type3), (167.44, 192.93, .type1), (245.92, 197.81, .type1), (280.43, 149.01, .type3), (280.43, 149.01, .type1), (319.89, 131.37, .type3), (204.96, 128.33, .type3), (125.83, 111.25, .type0), (344.74, 136.65, .type0)
        ]
        
        let layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)] = [
            .type0 : (.triangle, UIColor.red),
            .type1 : (.square, UIColor.blue),
            .type2 : (.circle, UIColor.green),
            .type3 : (.cross, UIColor.black)
        ]

        
        let xValues = stride(from: 0, through: 450, by: 50).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = stride(from: 0, through: 300, by: 50).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)

        let scatterLayers = toLayers(models, layerSpecifications: layerSpecifications, xAxis: xAxisLayer, yAxis: yAxisLayer, chartInnerFrame: innerFrame)
        
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer
            ] + scatterLayers
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }

    fileprivate func toLayers(_ models: [(x: Double, y: Double, type: MyExampleModelDataType)], layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)], xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect) -> [ChartLayer] {
        
        // group chartpoints by type
        var groupedChartPoints: Dictionary<MyExampleModelDataType, [ChartPoint]> = [:]
        for model in models {
            let chartPoint = ChartPoint(x: ChartAxisValueDouble(model.x), y: ChartAxisValueDouble(model.y))
            if groupedChartPoints[model.type] != nil {
                groupedChartPoints[model.type]!.append(chartPoint)
                
            } else {
                groupedChartPoints[model.type] = [chartPoint]
            }
        }

        let tapSettings = ChartPointsTapSettings()
        
        // create layer for each group
        let dim: CGFloat = Env.iPad ? 14 : 7
        let size = CGSize(width: dim, height: dim)
        let layers: [ChartLayer] = groupedChartPoints.map {(type, chartPoints) in
            let layerSpecification = layerSpecifications[type]!
            switch layerSpecification.shape {
                case .triangle:
                    return ChartPointsScatterTrianglesLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color, tapSettings: tapSettings)
                case .square:
                    return ChartPointsScatterSquaresLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color, tapSettings: tapSettings)
                case .circle:
                    return ChartPointsScatterCirclesLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color, tapSettings: tapSettings)
                case .cross:
                    return ChartPointsScatterCrossesLayer(xAxis: xAxis.axis, yAxis: yAxis.axis, chartPoints: chartPoints, itemSize: size, itemFillColor: layerSpecification.color, tapSettings: tapSettings)
            }
        }
        
        return layers
    }
}
