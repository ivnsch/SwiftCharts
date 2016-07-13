//
//  Zoomable.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public protocol Zoomable {
    
    var containerView: UIView {get}
    
    var contentView: UIView {get}
    
    var scaleX: CGFloat {get}
    var scaleY: CGFloat {get}
    
    func zoom(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat)
    
    func onZoom(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat)
}

public extension Zoomable {
    
    public func zoom(scaleX scaleX: CGFloat, scaleY: CGFloat, anchorX: CGFloat = 0.5, anchorY: CGFloat = 0.5) {
        let centerX = containerView.frame.width * anchorX
        let centerY = containerView.frame.height - (containerView.frame.height * anchorY)
        zoom(scaleX: scaleX, scaleY: scaleY, centerX: centerX, centerY: centerY)
    }
    
    public func zoom(scaleX scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        zoom(deltaX: scaleX, deltaY: scaleY, centerX: centerX + containerView.frame.minX, centerY: centerY + containerView.frame.minY)
    }
    
    func zoom(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        
        onZoom(deltaX: deltaX, deltaY: deltaY, centerX: centerX, centerY: centerY)
        
        let containerFrame = containerView.frame
        let contentFrame = contentView.frame

        // Set anchor and translate to scale around center
        let transCenterX = centerX - contentFrame.minX - containerFrame.minX
        let transCenterY = centerY - contentFrame.minY - containerFrame.minY
        let anchorX = transCenterX / contentFrame.width
        let anchorY = transCenterY / contentFrame.height
        let previousAnchor = contentView.layer.anchorPoint
        contentView.layer.anchorPoint = CGPointMake(anchorX, anchorY)
        let offsetX = contentFrame.width * (previousAnchor.x - contentView.layer.anchorPoint.x)
        let offsetY = contentFrame.height * (previousAnchor.y - contentView.layer.anchorPoint.y)
        contentView.transform.tx = contentView.transform.tx - offsetX
        contentView.transform.ty = contentView.transform.ty - offsetY

        // Scale, ensure min scale (container size)
        let scaleX = max(containerFrame.width / contentFrame.width, deltaX)
        let scaleY = max(containerFrame.height / contentFrame.height, deltaY)
        contentView.transform = CGAffineTransformScale(contentView.transform, scaleX, scaleY)
        
        // Keep in boundaries
        if contentView.frame.origin.y > 0 {
            contentView.transform.ty = contentView.transform.ty - contentView.frame.origin.y
        }
        if contentView.frame.maxY < containerFrame.height {
            contentView.transform.ty = contentView.transform.ty + (containerFrame.height - contentView.frame.maxY)
        }
        if contentView.frame.origin.x > 0 {
            contentView.transform.tx = contentView.transform.tx - contentView.frame.origin.x
        }
        if contentView.frame.maxX < containerFrame.width {
            contentView.transform.tx = contentView.transform.tx + (containerFrame.width - contentView.frame.maxX)
        }
    }
}