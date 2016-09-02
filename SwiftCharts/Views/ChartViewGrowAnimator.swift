//
//  ChartViewGrowAnimator.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartViewGrowAnimator: ChartViewAnimator {

    public let anchor: CGPoint
    
    public init(anchor: CGPoint) {
        self.anchor = anchor
    }
    
    public func prepare(view: UIView) {
        view.layer.anchorPoint = anchor
        let offsetX = view.frame.width * (0.5 - anchor.x)
        let offsetY = view.frame.height * (0.5 - anchor.y)
        view.frame = view.frame.offsetBy(dx: -offsetX, dy: -offsetY)
        
        initState(view)
    }
 
    public func initState(view: UIView) {
        view.transform = CGAffineTransformMakeScale(0.001, 0.001)
    }
    
    public func targetState(view: UIView) {
        view.transform = CGAffineTransformMakeScale(1, 1)
    }
}