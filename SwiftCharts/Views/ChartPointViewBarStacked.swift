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

    private let stackFrames: [ChartPointViewBarStackedFrame]
    private let direction: ChartBarDirection
    private let cornerRadius: CGFloat
    
    init(p1: CGPoint, p2: CGPoint, width: CGFloat, stackFrames: [ChartPointViewBarStackedFrame], direction: ChartBarDirection, animDuration: Float = 0.5, cornerRadius: CGFloat = 0) {
        self.stackFrames = stackFrames
        self.direction = direction
        self.cornerRadius = cornerRadius
        
        super.init(p1: p1, p2: p2, width: width, bgColor: UIColor.clear, animDuration: animDuration)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        for (index, stackFrame) in self.stackFrames.enumerated() {
            let corners: UIRectCorner
            
            if (self.stackFrames.count == 1) {
                corners = UIRectCorner.allCorners
            } else {
                switch (index, self.direction) {
                case (0, .leftToRight):
                    corners = [.bottomLeft, .topLeft]
                case (0, .bottomToTop):
                    corners = [.bottomLeft, .bottomRight]
                case (stackFrames.count - 1, .leftToRight):
                    corners = [.topRight, .bottomRight]
                case (stackFrames.count - 1, .bottomToTop):
                    corners = [.topLeft, .topRight]
                default:
                    corners = []
                }
            }
            
            let path = UIBezierPath(
                roundedRect: stackFrame.rect.standardized,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: self.cornerRadius, height: self.cornerRadius)
            )
            
            context.setFillColor(stackFrame.color.cgColor)
            context.addPath(path.cgPath)
            context.fillPath()
        }
    }
}
