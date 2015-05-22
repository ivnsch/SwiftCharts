//
//  ChartPointBubble.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointBubble: ChartPoint {
    public let diameterScalar: CGFloat
    public let bgColor: UIColor
    public let borderColor: UIColor
    
    public init(x: ChartAxisValue, y: ChartAxisValue, diameterScalar: CGFloat, bgColor: UIColor, borderColor: UIColor = UIColor.blackColor()) {
        self.diameterScalar = diameterScalar
        self.bgColor = bgColor
        self.borderColor = borderColor
        super.init(x: x, y: y)
    }
}