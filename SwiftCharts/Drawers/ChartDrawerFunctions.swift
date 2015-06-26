//
//  ChartDrawerFunctions.swift
//  Examples
//
//  Created by ischuetz on 21/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

func ChartDrawLine(context context: CGContextRef, p1: CGPoint, p2: CGPoint, width: CGFloat, color: UIColor) {
    CGContextSetStrokeColorWithColor(context, color.CGColor)
    CGContextSetLineWidth(context, width)
    CGContextMoveToPoint(context, p1.x, p1.y)
    CGContextAddLineToPoint(context, p2.x, p2.y)
    CGContextStrokePath(context)
}

func ChartDrawDottedLine(context context: CGContextRef, p1: CGPoint, p2: CGPoint, width: CGFloat, color: UIColor, dotWidth: CGFloat, dotSpacing: CGFloat) {
    CGContextSetStrokeColorWithColor(context, color.CGColor)
    CGContextSetLineWidth(context, width)
    CGContextSetLineDash(context, 0, [dotWidth, dotSpacing], 2)
    CGContextMoveToPoint(context, p1.x, p1.y)
    CGContextAddLineToPoint(context, p2.x, p2.y)
    CGContextStrokePath(context)
    CGContextSetLineDash(context, 0, nil, 0)
}