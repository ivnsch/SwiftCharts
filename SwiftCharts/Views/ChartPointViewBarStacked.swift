//
//  ChartPointViewBarStacked.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct TappedChartPointViewBarStacked {
    public let barView: ChartPointViewBarStacked
    public let stackFrame: (index: Int, view: UIView, viewFrameRelativeToBarSuperview: CGRect)
}


private class ChartBarStackFrameView: UIView {
    
    var isSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public typealias ChartPointViewBarStackedFrame = (rect: CGRect, color: UIColor)

public class ChartPointViewBarStacked: ChartPointViewBar {
    
    private var stackViews: [(index: Int, view: ChartBarStackFrameView, targetFrame: CGRect)] = []
    
    var stackFrameSelectionViewUpdater: ChartViewSelector?
    
    var stackedTapHandler: (TappedChartPointViewBarStacked -> Void)? {
        didSet {
            if stackedTapHandler != nil && gestureRecognizers?.isEmpty ?? true {
                enableTap()
            }
        }
    }
    
    public required init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, stackFrames: [ChartPointViewBarStackedFrame], settings: ChartBarViewSettings, stackFrameSelectionViewUpdater: ChartViewSelector? = nil) {
        self.stackFrameSelectionViewUpdater = stackFrameSelectionViewUpdater
        
        super.init(p1: p1, p2: p2, width: width, bgColor: bgColor, settings: settings)
        
        for (index, stackFrame) in stackFrames.enumerate() {
            let (targetFrame, firstFrame): (CGRect, CGRect) = {
                if p1.y - p2.y =~ 0 { // horizontal
                    let initFrame = CGRectMake(0, stackFrame.rect.origin.y, 0, stackFrame.rect.size.height)
                    return (stackFrame.rect, initFrame)
                    
                } else { // vertical
                    let initFrame = CGRectMake(stackFrame.rect.origin.x, self.frame.height, stackFrame.rect.size.width, 0)
                    return (stackFrame.rect, initFrame)
                }
            }()
            
            let v = ChartBarStackFrameView(frame: firstFrame)
            v.backgroundColor = stackFrame.color
            
            stackViews.append((index, v, targetFrame))
            
            addSubview(v)
        }
    }
    
    override func onTap(sender: UITapGestureRecognizer) {
        let loc = sender.locationInView(self)
        guard let tappedStackFrame = (stackViews.filter{$0.view.frame.contains(loc)}.first) else {
            print("Warn: no stacked frame found in stacked bar")
            return
        }
        
        toggleSelection()
        tappedStackFrame.view.isSelected = !tappedStackFrame.view.isSelected
        
        let f = tappedStackFrame.view.frame.offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        
        stackFrameSelectionViewUpdater?.displaySelected(tappedStackFrame.view, selected: tappedStackFrame.view.isSelected)
        stackedTapHandler?(TappedChartPointViewBarStacked(barView: self, stackFrame: (tappedStackFrame.index, tappedStackFrame.view, f)))
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, settings: ChartBarViewSettings) {
        fatalError("init(p1:p2:width:settings:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        
        func targetState() {
            frame = targetFrame
            for stackFrame in stackViews {
                stackFrame.view.frame = stackFrame.targetFrame
            }
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
