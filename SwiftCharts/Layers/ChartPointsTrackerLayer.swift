//
//  ChartPointsTrackerLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 29/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointsTrackerLayer<T: ChartPoint>: ChartPointsLayer<T> {
   
    private var view: TrackerView?
    private let locChangedFunc: ((CGPoint) -> ())

    private let lineColor: UIColor
    private let lineWidth: CGFloat
    
    private lazy var currentPositionLineOverlay: UIView = {
        let currentPositionLineOverlay = UIView()
        currentPositionLineOverlay.backgroundColor = self.lineColor
        return currentPositionLineOverlay
    }()
    
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], locChangedFunc: (CGPoint) -> (), lineColor: UIColor = UIColor.blackColor(), lineWidth: CGFloat = 1) {
        self.locChangedFunc = locChangedFunc
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    override func display(chart chart: Chart) {
        let view = TrackerView(frame: chart.bounds, updateFunc: {[weak self] location in
            self?.locChangedFunc(location)
            self?.currentPositionLineOverlay.center.x = location.x
        })
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
        
        view.addSubview(self.currentPositionLineOverlay)
        self.currentPositionLineOverlay.frame = CGRectMake(self.innerFrame.origin.x + 200 - self.lineWidth / 2, self.innerFrame.origin.y, self.lineWidth, self.innerFrame.height)
    }
}


private class TrackerView: UIView {
    
    let updateFunc: ((CGPoint) -> ())?
    
    init(frame: CGRect, updateFunc: (CGPoint) -> ()) {
        self.updateFunc = updateFunc
        
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
    }
}
