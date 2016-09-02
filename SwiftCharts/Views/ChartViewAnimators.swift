//
//  ChartViewAnimators.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

/// Runs a series of animations on a view
public class ChartViewAnimators {
    
    public var animDelay: Float = 0
    public var animDuration: Float = 0.3
    public var animDamping: CGFloat = 0.4
    public var animInitSpringVelocity: CGFloat = 0.5
    
    private let animators: [ChartViewAnimator]
    
    private let onFinishAnimations: (() -> Void)?
    private let onFinishInverts: (() -> Void)?
    
    private let view: UIView
    
    public init(view: UIView, animators: ChartViewAnimator..., onFinishAnimations: (() -> Void)? = nil, onFinishInverts: (() -> Void)? = nil) {
        self.view = view
        self.animators = animators
        self.onFinishAnimations = onFinishAnimations
        self.onFinishInverts = onFinishInverts
    }
    
    public func animate() {
        for animator in animators {
            animator.prepare(view)
        }
        
        animate({
            for animator in self.animators {
                animator.animate(self.view)
            }
        }, onFinish: {
            self.onFinishAnimations?()
        })
    }
    
    public func invert() {
        animate({
            for animator in self.animators {
                animator.invert(self.view)
            }
            }, onFinish: {
                self.onFinishInverts?()
        })
    }
    
    private func animate(animations: () -> Void, onFinish: () -> Void) {
        UIView.animateWithDuration(NSTimeInterval(animDuration), delay: NSTimeInterval(animDelay), usingSpringWithDamping: animDamping, initialSpringVelocity: animInitSpringVelocity, options: UIViewAnimationOptions(), animations: {
            animations()
            }, completion: {finished in
                if finished {
                    onFinish()
                }
        })
    }
}

