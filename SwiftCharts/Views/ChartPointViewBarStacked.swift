//
//  ChartPointViewBarStacked.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public typealias ChartPointViewBarStackedFrame = (rect: CGRect, color: UIColor)

open class ChartPointViewBarStacked: ChartPointViewBar {

    fileprivate let stackFrames: [ChartPointViewBarStackedFrame]
    
    init(p1: CGPoint, p2: CGPoint, width: CGFloat, stackFrames: [ChartPointViewBarStackedFrame], animDuration: Float = 0.5) {
        self.stackFrames = stackFrames
        super.init(p1: p1, p2: p2, width: width, bgColor: UIColor.clear, animDuration: animDuration)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        for stackFrame in self.stackFrames {
            context.setFillColor(stackFrame.color.cgColor)
            context.fill(stackFrame.rect)
        }
    }
}
