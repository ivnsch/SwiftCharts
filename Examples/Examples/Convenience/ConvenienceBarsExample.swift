//
//  ConvenienceBarsExample.swift
//  Examples
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class ConvenienceBarsExample: UIViewController {
    
    fileprivate var chart: Chart? // arc
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chartConfig = BarsChartConfig(
            chartSettings: ExamplesDefaults.chartSettingsWithPanZoom,
            valsAxisConfig: ChartAxisConfig(from: 0, to: 8, by: 2),
            xAxisLabelSettings: ExamplesDefaults.labelSettings,
            yAxisLabelSettings: ExamplesDefaults.labelSettings.defaultVertical()
        )
        
        let chart = BarsChart(
            frame: ExamplesDefaults.chartFrame(view.bounds),
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            bars: [
                ("A", 2),
                ("B", 4.5),
                ("C", 3),
                ("D", 5.4),
                ("E", 6.8),
                ("F", 0.5)
            ],
            color: UIColor.red,
            barWidth: Env.iPad ? 40 : 20
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }
}
