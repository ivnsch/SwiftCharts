//
//  ChartPointCandleStick.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointCandleStick: ChartPoint {
    
    public let date: NSDate
    public let open: CGFloat
    public let close: CGFloat
    public let low: CGFloat
    public let high: CGFloat
    
    public init(date: NSDate, formatter: NSDateFormatter, high: CGFloat, low: CGFloat, open: CGFloat, close: CGFloat, labelHidden: Bool = false) {
        
        let x = ChartAxisValueDate(date: date, formatter: formatter)
        self.date = date
        x.hidden = labelHidden
        
        let highY = ChartAxisValueFloat(high)
        self.high = high
        self.low = low
        self.open = open
        self.close = close

        super.init(x: x, y: highY)
    }
}
