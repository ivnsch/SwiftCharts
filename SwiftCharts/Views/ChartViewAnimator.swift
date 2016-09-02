//
//  ChartViewAnimator.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

/// Animates a view from init state to target state and back. General animation settings like duration, delay, etc. are defined in the containing ChartViewAnimators instance.
public protocol ChartViewAnimator {
    
    func initState(view: UIView)
    
    func targetState(view: UIView)
    
    
    func prepare(view: UIView)
    
    func animate(view: UIView)
    
    func invert(view: UIView)
}

extension ChartViewAnimator {
    
    public func prepare(view: UIView) {
        initState(view)
    }
    
    public func animate(view: UIView) {
        targetState(view)
    }
    
    public func invert(view: UIView) {
        initState(view)
    }
}