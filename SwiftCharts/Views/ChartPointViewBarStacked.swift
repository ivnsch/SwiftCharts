//
//  ChartPointViewBarStacked.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public typealias ChartPointViewBarStackedFrame = (rect: CGRect, color: UIColor)

public class ChartPointViewBarStacked: ChartPointViewBar {

    private let stackFrames: [ChartPointViewBarStackedFrame]
    
    init(p1: CGPoint, p2: CGPoint, width: CGFloat, stackFrames: [ChartPointViewBarStackedFrame], animDuration: Float = 0.5) {
        self.stackFrames = stackFrames
        super.init(p1: p1, p2: p2, width: width, bgColor: UIColor.clearColor(), animDuration: animDuration)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        for stackFrame in self.stackFrames {
            CGContextSetFillColorWithColor(context, stackFrame.color.CGColor)
            CGContextFillRect(context, stackFrame.rect)
        }
    }
}
