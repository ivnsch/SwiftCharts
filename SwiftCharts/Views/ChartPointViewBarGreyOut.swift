//
//  ChartPointViewBarGreyOut.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartBarGreyOutSettings {
    let barSettings: ChartBarViewSettings = ChartBarViewSettings()
    let greyOutDelay: Float = 1
    let greyOutAnimDuration: Float = 0.5
}

public class ChartPointViewBarGreyOut: ChartPointViewBar {

    private let greyOutSettings: ChartBarGreyOutSettings
    
    init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, settings: ChartBarGreyOutSettings) {
        self.greyOutSettings = settings
        super.init(p1: p1, p2: p2, width: width, bgColor: bgColor, settings: settings.barSettings)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, settings: ChartBarViewSettings) {
        self.greyOutSettings = ChartBarGreyOutSettings()
        super.init(p1: p1, p2: p2, width: width, bgColor: bgColor, settings: settings)
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        UIView.animateWithDuration(CFTimeInterval(greyOutSettings.greyOutAnimDuration), delay: CFTimeInterval(greyOutSettings.greyOutDelay), options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.backgroundColor = UIColor.grayColor()
        }, completion: nil)
    }
}
