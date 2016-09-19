//
//  ChartPointViewBar.swift
//  Examples
//
//  Created by ischuetz on 14/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointViewBar: UIView {
    
    let targetFrame: CGRect
    let animDuration: Float
    let animDelay: Float
    
    var isSelected: Bool = false
    
    var selectionViewUpdater: ChartViewSelector?
    
    var tapHandler: (ChartPointViewBar -> Void)? {
        didSet {
            if tapHandler != nil && gestureRecognizers?.isEmpty ?? true {
                enableTap()
            }
        }
    }
    
    public let isHorizontal: Bool
    
    public required init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor? = nil, animDuration: Float = 0.5, animDelay: Float = 0, selectionViewUpdater: ChartViewSelector? = nil) {
        
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
        self.animDuration = animDuration
        self.animDelay = animDelay
        
        self.selectionViewUpdater = selectionViewUpdater
        
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
        selectionViewUpdater?.displaySelected(self, selected: isSelected)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        
        func targetState() {
            frame = targetFrame
            layoutIfNeeded()
        }
        
        if animDuration =~ 0 {
            targetState()
        } else {
            UIView.animateWithDuration(CFTimeInterval(animDuration), delay: CFTimeInterval(animDelay), options: .CurveEaseOut, animations: {
                targetState()
                }, completion: nil)
        }

    }
}