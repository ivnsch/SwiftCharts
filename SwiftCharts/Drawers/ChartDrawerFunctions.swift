//
//  ChartDrawerFunctions.swift
//  Examples
//
//  Created by ischuetz on 21/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

func ChartDrawLine(#context: CGContextRef, #p1: CGPoint, #p2: CGPoint, #width: CGFloat, #color: UIColor) {
    CGContextSetStrokeColorWithColor(context, color.CGColor)
    CGContextSetLineWidth(context, width)
    CGContextMoveToPoint(context, p1.x, p1.y)
    CGContextAddLineToPoint(context, p2.x, p2.y)
    CGContextStrokePath(context)
}

func ChartDrawDottedLine(#context: CGContextRef, #p1: CGPoint, #p2: CGPoint, #width: CGFloat, #color: UIColor, #dotWidth: CGFloat, #dotSpacing: CGFloat) {
    CGContextSetStrokeColorWithColor(context, color.CGColor)
    CGContextSetLineWidth(context, width)
    
    let offset = dotWidth + dotSpacing
    
    let offsetY = (p2.y - p1.y)
    let yConstant = offsetY == 0
    var limit: CGFloat
    var start: CGFloat
    
    if yConstant { //horizontal line
        limit = p2.x - p1.x
        start = p1.x
        
    } else { //vertical line
        limit = p2.y - p1.y
        start = p1.y
    }
    
    limit += start
    
    for tmp in stride(from: start, to: limit, by: offset) {
        
        var x1: CGFloat
        var y1: CGFloat
        var x2: CGFloat
        var y2: CGFloat
        
        if yConstant { //horizontal line
            x1 = tmp
            y1 = p1.y
            x2 = x1 + dotWidth
            y2 = y1
            
        } else { //vertical line
            x1 = p1.x
            y1 = tmp
            x2 = x1
            y2 = y1 + dotWidth
        }
        
        CGContextMoveToPoint(context, x1, y1)
        CGContextAddLineToPoint(context, x2, y2)
        CGContextStrokePath(context)
    }
}

