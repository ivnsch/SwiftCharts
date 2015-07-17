//
//  ChartConfig.swift
//  Examples
//
//  Settings wrappers for default charts.
//  These charts are assumed to have one x axis at the bottom and one y axis at the left.
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartConfig {
    public let chartSettings: ChartSettings
    public let xAxisConfig: ChartAxisConfig
    public let yAxisConfig: ChartAxisConfig
    public let xAxisLabelSettings: ChartLabelSettings
    public let yAxisLabelSettings: ChartLabelSettings
    
    public init(chartSettings: ChartSettings = ChartSettings(), xAxisConfig: ChartAxisConfig, yAxisConfig: ChartAxisConfig, xAxisLabelSettings: ChartLabelSettings = ChartLabelSettings(), yAxisLabelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.chartSettings = chartSettings
        self.xAxisConfig = xAxisConfig
        self.yAxisConfig = yAxisConfig
        self.xAxisLabelSettings = xAxisLabelSettings
        self.yAxisLabelSettings = yAxisLabelSettings
    }
}

public struct ChartAxisConfig {
    public let from: CGFloat
    public let to: CGFloat
    public let by: CGFloat
    
    public init(from: CGFloat, to: CGFloat, by: CGFloat) {
        self.from = from
        self.to = to
        self.by = by
    }
}