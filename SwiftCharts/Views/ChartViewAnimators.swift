//
//  ChartViewAnimators.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartViewAnimatorsSettings {
    public let animDelay: Float
    public let animDuration: Float
    public let animDamping: CGFloat
    public let animInitSpringVelocity: CGFloat

    public init(animDelay: Float = 0, animDuration: Float = 0.3, animDamping: CGFloat = 0.7, animInitSpringVelocity: CGFloat = 1) {
        self.animDelay = animDelay
        self.animDuration = animDuration
        self.animDamping = animDamping
        self.animInitSpringVelocity = animInitSpringVelocity
    }
    
    public func copy(animDelay: Float? = nil, animDuration: Float? = nil, animDamping: CGFloat? = nil, animInitSpringVelocity: CGFloat? = nil) -> ChartViewAnimatorsSettings {
        return ChartViewAnimatorsSettings(
            animDelay: animDelay ?? self.animDelay,
            animDuration: animDuration ?? self.animDuration,
            animDamping: animDamping ?? self.animDamping,
            animInitSpringVelocity: animInitSpringVelocity ?? self.animInitSpringVelocity
        )
    }
    
    public func withoutDamping() -> ChartViewAnimatorsSettings {
        return copy(animDelay, animDuration: animDuration, animDamping: 1, animInitSpringVelocity: animInitSpringVelocity)
    }
}


/// Runs a series of animations on a view
public class ChartViewAnimators {
    
    public var animDelay: Float = 0
    public var animDuration: Float = 10.3
    public var animDamping: CGFloat = 0.4
    public var animInitSpringVelocity: CGFloat = 0.5
    
    private let animators: [ChartViewAnimator]
    
    private let onFinishAnimations: (() -> Void)?
    private let onFinishInverts: (() -> Void)?
    
    private let view: UIView
    
    private let settings: ChartViewAnimatorsSettings
    private let invertSettings: ChartViewAnimatorsSettings
    
    public init(view: UIView, animators: ChartViewAnimator..., settings: ChartViewAnimatorsSettings = ChartViewAnimatorsSettings(), invertSettings: ChartViewAnimatorsSettings? = nil, onFinishAnimations: (() -> Void)? = nil, onFinishInverts: (() -> Void)? = nil) {
        self.view = view
        self.animators = animators
        self.onFinishAnimations = onFinishAnimations
        self.onFinishInverts = onFinishInverts
        self.settings = settings
        self.invertSettings = invertSettings ?? settings
    }
    
    public func animate() {
        for animator in animators {
            animator.prepare(view)
        }
        
        animate(settings, animations: {
            for animator in self.animators {
                animator.animate(self.view)
            }
        }, onFinish: {
            self.onFinishAnimations?()
        })
    }
    
    public func invert() {
        animate(invertSettings, animations: {
            for animator in self.animators {
                animator.invert(self.view)
            }
            }, onFinish: {
                self.onFinishInverts?()
        })
    }
    
    private func animate(settings: ChartViewAnimatorsSettings, animations: () -> Void, onFinish: () -> Void) {
        UIView.animateWithDuration(NSTimeInterval(settings.animDuration), delay: NSTimeInterval(settings.animDelay), usingSpringWithDamping: settings.animDamping, initialSpringVelocity: settings.animInitSpringVelocity, options: UIViewAnimationOptions(), animations: {
            animations()
            }, completion: {finished in
                if finished {
                    onFinish()
                }
        })
    }
}

