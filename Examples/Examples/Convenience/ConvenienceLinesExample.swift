//
//  ConvenienceLinesExample.swift
//  Examples
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class ConvenienceLinesExample: UIViewController {
    
    fileprivate var chart: Chart? // arc
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chartConfig = ChartConfigXY(
            chartSettings: ExamplesDefaults.chartSettingsWithPanZoom,
            xAxisConfig: ChartAxisConfig(from: 2, to: 14, by: 2),
            yAxisConfig: ChartAxisConfig(from: 0, to: 14, by: 2),
            xAxisLabelSettings: ExamplesDefaults.labelSettings,
            yAxisLabelSettings: ExamplesDefaults.labelSettings.defaultVertical()
        )
        
        let chart = LineChart(
            frame: ExamplesDefaults.chartFrame(view.bounds),
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            lines: [
                (chartPoints: [(2.0, 10.6), (4.2, 5.1), (7.3, 3.0), (8.1, 5.5), (14.0, 8.0)], color: UIColor.red),
                (chartPoints: [(2.0, 2.6), (4.2, 4.1), (7.3, 1.0), (8.1, 11.5), (14.0, 3.0)], color: UIColor.blue)
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }
}
