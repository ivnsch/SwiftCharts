//
//  ChartPointViewBar.swift
//  Examples
//
//  Created by ischuetz on 14/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartBarViewSettings {
    
    let animDuration: Float
    let animDelay: Float
    
    let selectionViewUpdater: ChartViewSelector?
    
    let delayInit: Bool
    
    public init(animDuration: Float = 0.5, animDelay: Float = 0, selectionViewUpdater: ChartViewSelector? = nil, delayInit: Bool = false) {
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.selectionViewUpdater = selectionViewUpdater
        self.delayInit = delayInit
    }
    
    public func copy(animDuration animDuration: Float? = nil, animDelay: Float? = nil, selectionViewUpdater: ChartViewSelector? = nil) -> ChartBarViewSettings {
        return ChartBarViewSettings(
            animDuration: animDuration ?? self.animDuration,
            animDelay: animDelay ?? self.animDelay,
            selectionViewUpdater: selectionViewUpdater ?? self.selectionViewUpdater
        )
    }
}

public class ChartPointViewBar: UIView {
    
    let targetFrame: CGRect

    var isSelected: Bool = false
    
    var tapHandler: (ChartPointViewBar -> Void)? {
        didSet {
            if tapHandler != nil && gestureRecognizers?.isEmpty ?? true {
                enableTap()
            }
        }
    }
    
    public let isHorizontal: Bool
    
    public let settings: ChartBarViewSettings
    
    public required init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, settings: ChartBarViewSettings) {
        
        let (targetFrame, firstFrame): (CGRect, CGRect) = {
            if p1.y - p2.y =~ 0 { // horizontal
                let targetFrame = CGRectMake(p1.x, p1.y - width / 2, p2.x - p1.x, width)
                let initFrame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y, 0, targetFrame.size.height)
                return (targetFrame, initFrame)
                
            } else { // vertical
                let targetFrame = CGRectMake(p1.x - width / 2, p1.y, width, p2.y - p1.y)
                let initFrame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y, targetFrame.size.width, 0)
                return (targetFrame, initFrame)
            }
        }()
        
        self.targetFrame =  targetFrame
        self.settings = settings
        
        isHorizontal = p1.y == p2.y
        
        super.init(frame: firstFrame)
        
        self.backgroundColor = bgColor
    }

    func enableTap() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    func onTap(sender: UITapGestureRecognizer) {
        toggleSelection()
        tapHandler?(self)
    }
    
    func toggleSelection() {
        isSelected = !isSelected
        settings.selectionViewUpdater?.displaySelected(self, selected: isSelected)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        
        func targetState() {
            frame = targetFrame
            layoutIfNeeded()
        }
        
        if settings.animDuration =~ 0 {
            targetState()
        } else {
            UIView.animateWithDuration(CFTimeInterval(settings.animDuration), delay: CFTimeInterval(settings.animDelay), options: .CurveEaseOut, animations: {
                targetState()
            }, completion: nil)
        }
    }
}