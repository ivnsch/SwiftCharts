//
//  Zoomable.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

protocol Zoomable {
    
    var contentView: UIView {get}
    
    func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat)
    
    func onZoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat)
}

extension Zoomable {
    
    func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        
        onZoom(x, y: y, centerX: centerX, centerY: centerY)

        let view = contentView
        
        let superframe = view.superview!.frame
        let frame = view.frame
        
        let transCenterX = centerX - frame.minX - superframe.minX
        let transCenterY = centerY - frame.minY - superframe.minY
        
        let anchorX = transCenterX / frame.width
        let anchorY = transCenterY / frame.height
        
        let previousAnchor = view.layer.anchorPoint
        view.layer.anchorPoint = CGPointMake(anchorX, anchorY)
        
        let offsetX = frame.width * (previousAnchor.x - view.layer.anchorPoint.x)
        let offsetY = frame.height * (previousAnchor.y - view.layer.anchorPoint.y)
        
        view.transform.tx = view.transform.tx - offsetX
        view.transform.ty = view.transform.ty - offsetY

        // Min scale
        let scaleX = max(superframe.width / frame.width, x)
        let scaleY = max(superframe.height / frame.height, y)
        view.transform = CGAffineTransformScale(view.transform, scaleX, scaleY)
        
        if view.frame.origin.y > 0 {
            view.transform.ty = view.transform.ty - view.frame.origin.y
        }
        
        if view.frame.maxY < superframe.height {
            view.transform.ty = view.transform.ty + (superframe.height - view.frame.maxY)
        }
        
        if view.frame.origin.x > 0 {
            view.transform.tx = view.transform.tx - view.frame.origin.x
        }
        
        if view.frame.maxX < superframe.width {
            view.transform.tx = view.transform.tx + (superframe.width - view.frame.maxX)
        }
    }
}