//
//  ScatterExample.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

private enum MyExampleModelDataType {
    case Type0, Type1, Type2, Type3
}

private enum Shape {
    case Triangle, Square, Circle, Cross
}

class ScatterExample: UIViewController {

    private var chart: Chart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let models: [(x: CGFloat, y: CGFloat, type: MyExampleModelDataType)] = [
            (246.56, 138.98, .Type1), (218.33, 132.71, .Type0), (187.79, 127.48, .Type0), (150.63, 135.5, .Type0), (185.05, 152.57, .Type3), (213.15, 155.71, .Type1), (252.79, 158.85, .Type2), (315.77, 150.62, .Type0), (220.55, 149.57, .Type3), (233.05, 163.08, .Type1), (203.91, 179.46, .Type2), (190.41, 158.73, .Type2), (157.78, 137.16, .Type3), (126.15, 147.57, .Type3), (155.34, 172.28, .Type1), (206.58, 151.36, .Type0), (257.59, 127.41, .Type1), (303.95, 126.36, .Type1), (332.95, 141.86, .Type0), (295.7, 156.5, .Type2), (259.54, 169.05, .Type2), (286.38, 177.41, .Type1), (328.75, 165.96, .Type3), (361.47, 137.07, .Type1), (361.47, 137.07, .Type3), (409.39, 128.71, .Type3), (420.54, 180.41, .Type2), (350.85, 187.73, .Type2), (274.35, 205.86, .Type2), (216.48, 180.76, .Type3), (196.01, 210, .Type1), (128.64, 151.85, .Type2), (81.67, 83.32, .Type0), (72.26, 48.12, .Type0), (149.29, 59.62, .Type3), (162.89, 105.28, .Type3), (194.91, 74, .Type2), (217.91, 101.89, .Type3), (173.27, 103.98, .Type1), (211.96, 141.62, .Type2), (225.51, 127.07, .Type2), (271.52, 95.7, .Type0), (306.89, 123.66, .Type2), (242.15, 144.57, .Type2), (255.74, 177.34, .Type2), (290.25, 163.75, .Type0), (313.07, 123.89, .Type1), (320.34, 94.05, .Type0), (221.19, 119.15, .Type3), (170.43, 83.68, .Type1), (150.57, 133.79, .Type1), (106.53, 176.61, .Type3), (154.98, 158.84, .Type2), (226.9, 156.84, .Type1), (272.82, 136.62, .Type1), (310.81, 121.98, .Type0), (346.14, 134.44, .Type2), (337.82, 155.17, .Type0), (314.34, 155.17, .Type3), (218.14, 145.76, .Type3), (152.07, 159.21, .Type3), (164.62, 187.1, .Type2), (243.72, 187.1, .Type3), (285.72, 188.14, .Type3), (340.29, 158.09, .Type0), (348.65, 112.62, .Type1), (401.29, 65.21, .Type2), (436.49, 42.21, .Type1), (409.44, 92.17, .Type3), (338.17, 138.39, .Type1), (204.67, 112.25, .Type2), (229.77, 82.27, .Type1), (316.59, 78.32, .Type3), (324.95, 49.74, .Type0), (355.18, 69.17, .Type2), (265.83, 89.99, .Type1), (156.42, 62.89, .Type0), (80.14, 92.68, .Type2), (123.58, 126.8, .Type0), (38.06, 92.38, .Type1), (86.07, 121.48, .Type3), (37.62, 167.49, .Type2), (71.95, 147.62, .Type1), (112.89, 150.76, .Type1), (67.2, 166.4, .Type3), (157.02, 165.79, .Type2), (195.58, 176.25, .Type2), (165.25, 128.5, .Type3), (235.13, 85.62, .Type2), (224.77, 138.54, .Type0), (179.33, 129.83, .Type0), (212.57, 159.67, .Type3), (267.76, 117.84, .Type0), (349.88, 81.29, .Type2), (388.57, 137.62, .Type0), (291.43, 155.39, .Type3), (239.5, 149.12, .Type0), (145.38, 159.23, .Type3), (114.02, 195.48, .Type2), (162.87, 195.48, .Type1), (215.16, 190.25, .Type1), (272.32, 206.98, .Type1), (332.27, 205.93, .Type3), (309.27, 169.68, .Type1), (237.81, 152.95, .Type1), (165.12, 159.14, .Type2), (81.83, 146.63, .Type0), (56.73, 76.22, .Type3), (38.95, 50.43, .Type0), (125.56, 96.3, .Type1), (142.29, 51.61, .Type1), (200.02, 98.27, .Type0), (134.64, 81.59, .Type2), (169.96, 126.1, .Type0), (230.27, 94.73, .Type0), (279.49, 95.77, .Type3), (172.06, 125.49, .Type2), (215.7, 149.36, .Type0), (263.67, 122.26, .Type2), (353.09, 136.9, .Type3), (277.11, 135.86, .Type1), (219.69, 146.31, .Type1), (212.37, 164.79, .Type3), (285.06, 161.7, .Type0), (339.21, 174.11, .Type3), (241.1, 166.79, .Type3), (229.94, 168.88, .Type0), (152.39, 176.89, .Type1), (113.98, 183.12, .Type0), (80.61, 194.62, .Type3), (143.52, 202.99, .Type0), (223.44, 187.45, .Type2), (287.61, 198.95, .Type2), (346.43, 208.27, .Type2), (319.73, 176.64, .Type2), (363.46, 135.95, .Type1), (308.39, 154.42, .Type2), (321.89, 170.71, .Type0), (374.53, 180.82, .Type1), (399.75, 213.87, .Type1), (303.51, 212.13, .Type3), (188.84, 227.12, .Type2), (235.83, 248.01, .Type3), (320.18, 219.78, .Type0), (401.52, 198.87, .Type3), (376.46, 152.99, .Type3), (410.62, 109.07, .Type3), (428.13, 119.7, .Type3), (414.54, 164.31, .Type2), (435.36, 200.47, .Type2), (437.45, 234.63, .Type3), (328.83, 193.85, .Type3), (372.57, 191.76, .Type3), (430.04, 213.62, .Type3), (323.72, 158.2, .Type0), (213.23, 109.06, .Type2), (133.06, 111.15, .Type2), (193.13, 98.6, .Type3), (250.3, 93.37, .Type0), (319.13, 97.55, .Type1), (350.32, 134.62, .Type1), (176.52, 122.07, .Type1), (92.23, 100.9, .Type1), (68.93, 88.05, .Type2), (124.21, 158.23, .Type3), (280.26, 172.13, .Type3), (175.21, 172.96, .Type2), (203.27, 186.51, .Type3), (206.4, 95.68, .Type2), (239.33, 79.04, .Type1), (285.34, 80.08, .Type3), (303.12, 109.01, .Type2), (202.87, 138.29, .Type2), (152.03, 102.74, .Type1), (130.41, 160.11, .Type3), (164.57, 137.11, .Type3), (203.13, 145.47, .Type2), (225.91, 168.2, .Type2), (251, 142.41, .Type1), (298.57, 140.32, .Type2), (264.8, 199.57, .Type2), (307.27, 207.85, .Type1), (212.13, 219, .Type2), (78.6, 213.77, .Type2), (31.68, 244.1, .Type1), (218.34, 116.63, .Type0), (343.47, 65.39, .Type1), (410.68, 44.62, .Type0), (427.37, 73.81, .Type2), (436.43, 204.17, .Type3), (45.53, 32.38, .Type2), (106.04, 67.79, .Type2), (156.57, 108.6, .Type1), (195.98, 71.18, .Type0), (240.23, 93.96, .Type2), (203.91, 112.65, .Type2), (236.4, 126.15, .Type2), (255.13, 92.91, .Type0), (283.27, 111.6, .Type2), (256.36, 159.82, .Type3), (217.94, 134.86, .Type1), (166.14, 158.21, .Type2), (202.33, 182.73, .Type3), (259.57, 183.69, .Type1), (259.57, 183.69, .Type2), (259.57, 135.82, .Type1), (120.49, 152.9, .Type0), (119.45, 112.34, .Type0), (106.9, 172.64, .Type1), (201.43, 221.75, .Type2), (300.62, 182.24, .Type3), (357.11, 173.88, .Type2), (390.3, 173.88, .Type3), (372.88, 219.19, .Type1), (309.44, 171.09, .Type2), (258.12, 95.89, .Type1), (339.37, 108.43, .Type2), (358.91, 122.5, .Type2), (377.74, 137.84, .Type1), (326, 140.97, .Type2), (243.04, 115.53, .Type1), (220.62, 99.98, .Type0), (96.91, 150.9, .Type0), (188.97, 163.4, .Type1), (317.27, 193.54, .Type2), (398.83, 234.32, .Type0), (105.38, 179.99, .Type3), (205.45, 105.63, .Type1), (286.34, 126.18, .Type2), (284.95, 140.47, .Type1), (374.53, 122.69, .Type0), (231.85, 159.27, .Type1), (213.73, 195.17, .Type2), (208.54, 153.53, .Type0), (153.61, 151.39, .Type3), (151.52, 119.38, .Type2), (193.59, 110.37, .Type2), (248.66, 113.5, .Type1), (303.85, 122.91, .Type2), (264.16, 155.29, .Type3), (218.24, 128.19, .Type1), (133.54, 115.29, .Type3), (150.18, 162.03, .Type3), (135.68, 173.44, .Type3), (142.86, 180.23, .Type2), (168.65, 175, .Type2), (168.65, 175, .Type0), (205.12, 172.91, .Type2), (153.02, 180.23, .Type3), (123.04, 166.63, .Type1), (112.63, 135.96, .Type1), (191.46, 140.1, .Type2), (157.04, 155.79, .Type2), (185.28, 124.46, .Type1), (212.33, 129.64, .Type1), (232.11, 158.43, .Type0), (257.11, 129.34, .Type1), (298.48, 106.52, .Type1), (345.19, 131.96, .Type2), (289.86, 151.83, .Type0), (211.08, 190.87, .Type1), (154.27, 241.06, .Type2), (73.49, 226.42, .Type0), (276.36, 75.29, .Type3), (219.12, 119.98, .Type3), (185.24, 83.17, .Type3), (76.46, 51.45, .Type0), (37.77, 37.51, .Type3), (176.36, 124.21, .Type0), (234.57, 126.3, .Type0), (188.88, 137.71, .Type1), (281.23, 149.21, .Type1), (325.62, 151.3, .Type1), (345.83, 152.35, .Type2), (253.27, 153.35, .Type3), (253.27, 153.35, .Type2), (191.8, 174.21, .Type0), (229.02, 179.31, .Type1), (271.75, 174.08, .Type1), (330.66, 163.62, .Type1), (207.65, 165.71, .Type0), (135.87, 179.26, .Type0), (85.55, 136.22, .Type3), (155.27, 137.27, .Type1), (128.61, 108.78, .Type3), (206.35, 111.91, .Type0), (206.35, 111.91, .Type0), (206.35, 111.91, .Type2), (144.84, 147.33, .Type2), (171.75, 135.92, .Type1), (236.93, 117.1, .Type2), (201.97, 135, .Type3), (265.41, 80.62, .Type3), (312.42, 96.21, .Type1), (232, 141.18, .Type0), (348.75, 132.65, .Type1), (325.05, 108.6, .Type0), (360.6, 137.79, .Type2), (322.05, 162.88, .Type0), (236.83, 179.57, .Type0), (164.33, 119.96, .Type2), (113.44, 107.41, .Type1), (139.45, 136.46, .Type0), (191.73, 136.46, .Type2), (254.92, 130.23, .Type2), (297.17, 142.09, .Type3), (258.57, 150.45, .Type2), (189.91, 168.23, .Type1), (133.58, 168.23, .Type1), (342.5, 166.09, .Type3), (150.75, 127.58, .Type3), (167.44, 192.93, .Type1), (245.92, 197.81, .Type1), (280.43, 149.01, .Type3), (280.43, 149.01, .Type1), (319.89, 131.37, .Type3), (204.96, 128.33, .Type3), (125.83, 111.25, .Type0), (344.74, 136.65, .Type0)
        ]
        
        let layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)] = [
            .Type0 : (.Triangle, UIColor.redColor()),
            .Type1 : (.Square, UIColor.blueColor()),
            .Type2 : (.Circle, UIColor.greenColor()),
            .Type3 : (.Cross, UIColor.blackColor())
        ]

        let xValues = Array(stride(from: 0, through: 450, by: 50)).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        let yValues = Array(stride(from: 0, through: 300, by: 50)).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)

        let scatterLayers = self.toLayers(models, layerSpecifications: layerSpecifications, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame)
        
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: guidelinesLayerSettings)
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer
            ] + scatterLayers
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }

    private func toLayers(models: [(x: CGFloat, y: CGFloat, type: MyExampleModelDataType)], layerSpecifications: [MyExampleModelDataType : (shape: Shape, color: UIColor)], xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect) -> [ChartLayer] {
        
        // group chartpoints by type
        let groupedChartPoints: Dictionary<MyExampleModelDataType, [ChartPoint]> = models.reduce(Dictionary<MyExampleModelDataType, [ChartPoint]>()) {(var dict, model) in
            let chartPoint = ChartPoint(x: ChartAxisValueFloat(model.x), y: ChartAxisValueFloat(model.y))
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
        let layers: [ChartLayer] = map(groupedChartPoints) {(type, chartPoints) in
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
}
