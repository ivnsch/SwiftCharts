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
    
    private var stackViews: [(view: UIView, targetFrame: CGRect)] = []
    
    init(p1: CGPoint, p2: CGPoint, width: CGFloat, stackFrames: [ChartPointViewBarStackedFrame], animDuration: Float = 0.5) {
        super.init(p1: p1, p2: p2, width: width, bgColor: UIColor.clearColor(), animDuration: animDuration)
        
        for stackFrame in stackFrames {
            let (targetFrame, firstFrame): (CGRect, CGRect) = {
                if p1.y - p2.y =~ 0 { // horizontal
                    let initFrame = CGRectMake(0, stackFrame.rect.origin.y, 0, stackFrame.rect.size.height)
                    return (stackFrame.rect, initFrame)
                    
                } else { // vertical
                    let initFrame = CGRectMake(stackFrame.rect.origin.x, self.frame.height, stackFrame.rect.size.width, 0)
                    return (stackFrame.rect, initFrame)
                }
            }()
            
            let v = UIView(frame: firstFrame)
            v.backgroundColor = stackFrame.color
            
            stackViews.append((v, targetFrame))
            
            addSubview(v)
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        
        func targetState() {
            frame = targetFrame
            for stackFrame in stackViews {
                stackFrame.view.frame = stackFrame.targetFrame
            }
            layoutIfNeeded()
        }
        
        if animDuration =~ 0 {
            targetState()
        } else {
            UIView.animateWithDuration(CFTimeInterval(animDuration), delay: 0, options: .CurveEaseOut, animations: {
                targetState()
            }, completion: nil)
        }

    }
}
