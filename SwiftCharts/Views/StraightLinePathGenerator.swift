//
//  StraigthLinePathGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class StraightLinePathGenerator: ChartLinesViewPathGenerator {
    func generatePath(points points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {

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
            }

            progressline.closePath()
        }

        return progressline
    }
}
