//
//  BorderedCircleView.swift
//  swift_charts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartPointCircleViewSettings {
    let animDelay: Float
    let animDuration: Float
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let borderColor: UIColor
    let fillColor: UIColor
    
    public init(animDelay: Float = 0, animDuration: Float = 0, borderWidth: CGFloat = 3, cornerRadius: CGFloat = 11, borderColor: UIColor = UIColor.blueColor(), fillColor: UIColor = UIColor.whiteColor()) {
        self.animDelay = animDelay
        self.animDuration = animDuration
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.fillColor = fillColor
    }
}


public class ChartPointCircleView: UIView {
    
    private let settings: ChartPointCircleViewSettings
    
    public init(center: CGPoint, size: CGSize, settings: ChartPointCircleViewSettings = ChartPointCircleViewSettings()) {
        self.settings = settings
        
        let w = size.width
        let h = size.height
        
        super.init(frame: CGRectMake(center.x - w / 2, center.y - h / 2, w, h))
        
        let circle = UIView(frame: self.bounds)
        circle.layer.cornerRadius = settings.cornerRadius
        circle.layer.borderWidth = settings.borderWidth
        circle.layer.borderColor = settings.borderColor.CGColor
        circle.layer.backgroundColor = settings.fillColor.CGColor
        self.addSubview(circle)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override public func didMoveToSuperview() {
        if self.settings.animDuration != 0 {
            self.transform = CGAffineTransformMakeScale(0.1, 0.1)
            UIView.animateWithDuration(NSTimeInterval(self.settings.animDuration), delay: NSTimeInterval(self.settings.animDelay), options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: nil)
        }
    }
}
