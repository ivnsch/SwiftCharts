//
//  ChartPointCandleStick.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointCandleStick: ChartPoint {
    
    public let date: Date
    public let open: Double
    public let close: Double
    public let low: Double
    public let high: Double
    
    public init(date: Date, formatter: DateFormatter, high: Double, low: Double, open: Double, close: Double, labelHidden: Bool = false) {
        
        let x = ChartAxisValueDate(date: date, formatter: formatter)
        self.date = date
        x.hidden = labelHidden
        
        let highY = ChartAxisValueDouble(high)
        self.high = high
        self.low = low
        self.open = open
        self.close = close

        super.init(x: x, y: highY)
    }

    required public init(x: ChartAxisValue, y: ChartAxisValue) {
        fatalError("init(x:y:) has not been implemented")
    }
}
