//
//  DottedLinePathGenerator.swift
//  SwiftCharts
//
//  Created by MAX on 6/17/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation
public class DottedLinePathGenerator :ChartLinesViewPathGenerator{
    public init() {
       
    }

   public func generatePath(points points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {
        let progressline = UIBezierPath()
        
        if points.count >= 2 {
            
            progressline.lineWidth = lineWidth
            progressline.lineCapStyle = .Round
            progressline.lineJoinStyle = .Round
            
            for i in 0..<(points.count - 1) {
                let p1 = points[i]
                let p2 = points[i + 1]
                
                progressline.moveToPoint(p1)
                progressline.addLineToPoint(p2)
                let dashes:[CGFloat] = [10, 5]
                progressline.setLineDash(dashes, count: dashes.count, phase: 0)
            }
            
            progressline.closePath()
        }
        
        return progressline
    }

}

