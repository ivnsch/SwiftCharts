//
//  ChartPointViewBar.swift
//  Examples
//
//  Created by ischuetz on 14/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointViewBar: UIView {
    
    fileprivate let targetFrame: CGRect
    fileprivate let animDuration: Float
    
    public init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor? = nil, animDuration: Float = 0.5) {
        
        let (targetFrame, firstFrame): (CGRect, CGRect) = {
            if p1.y - p2.y == 0 { // horizontal
                let targetFrame = CGRect(x: p1.x, y: p1.y - width / 2, width: p2.x - p1.x, height: width)
                let initFrame = CGRect(x: targetFrame.origin.x, y: targetFrame.origin.y, width: 0, height: targetFrame.size.height)
                return (targetFrame, initFrame)
                
            } else { // vertical
                let targetFrame = CGRect(x: p1.x - width / 2, y: p1.y, width: width, height: p2.y - p1.y)
                let initFrame = CGRect(x: targetFrame.origin.x, y: targetFrame.origin.y, width: targetFrame.size.width, height: 0)
                return (targetFrame, initFrame)
            }
        }()
        
        self.targetFrame =  targetFrame
        self.animDuration = animDuration
        
        super.init(frame: firstFrame)
        
        self.backgroundColor = bgColor
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didMoveToSuperview() {
        UIView.animate(withDuration: CFTimeInterval(self.animDuration), delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
            self.frame = self.targetFrame
        }, completion: nil)
    }
}
