//
//  InfoBubble.swift
//  SwiftCharts
//
//  Created by ischuetz on 11/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class InfoBubble: UIView {

    public let arrowWidth: CGFloat
    public let arrowHeight: CGFloat
    public let bgColor: UIColor
    public let arrowX: CGFloat
    public let arrowY: CGFloat
    
    private let contentView: UIView?
    
    public let minSuperviewPadding: CGFloat
    public let space: CGFloat
    
    public let point: CGPoint
    
    public var closeHandler: (() -> Void)?

    private var inverted: Bool {
        guard let superview = superview else {return false}
        return horizontal ? point.x > superview.frame.width - frame.width - space : point.y < bounds.size.height
    }

    public let horizontal: Bool
    
    public convenience init(point: CGPoint, size: CGSize, superview: UIView, arrowHeight: CGFloat = 15, contentView: UIView, bgColor: UIColor = UIColor.grayColor(), minSuperviewPadding: CGFloat = 2, space: CGFloat = 12, horizontal: Bool = false) {
        
        let w: CGFloat = size.width + (horizontal ? arrowHeight : 0)
        let h: CGFloat = size.height + (!horizontal ? arrowHeight : 0)
        
        let x = horizontal ? point.x : min(max(superview.bounds.minX + minSuperviewPadding, point.x - w / 2), superview.bounds.maxX - w - minSuperviewPadding) // align with center and move rect to fit in available horizontal space
        let y = horizontal ? min(max(0 + minSuperviewPadding, point.y - h / 2), superview.bounds.maxY - h - minSuperviewPadding) : point.y // align with center and move rect to fit in available vertical space
        
        let frame: CGRect = {
            if !horizontal {
                return point.y < h ? CGRectMake(x, point.y + space, w, h) : CGRectMake(x, point.y - (h + space), w, h)
            } else {
                return point.x < superview.frame.width - w - space ? CGRectMake(x + space, y, w, h) : CGRectMake(x - (w + space), y, w, h)
            }
        }()
   
        self.init(point: point, frame: frame, arrowWidth: 15, arrowHeight: arrowHeight, contentView: contentView, bgColor: bgColor, arrowX: point.x - x, arrowY: point.y - y, horizontal: horizontal)
    }
    
    public init(point: CGPoint, frame: CGRect, arrowWidth: CGFloat, arrowHeight: CGFloat, contentView: UIView? = nil, bgColor: UIColor = UIColor.whiteColor(), space: CGFloat = 12, minSuperviewPadding: CGFloat = 2, arrowX: CGFloat, arrowY: CGFloat, horizontal: Bool = false) {
        self.point = point
        self.arrowWidth = arrowWidth
        self.arrowHeight = arrowHeight
        self.bgColor = bgColor
        self.space = space
        self.minSuperviewPadding = minSuperviewPadding
        self.horizontal = horizontal
        
        let arrowHalf = arrowWidth / 2
        self.arrowX = max(arrowHalf, min(frame.size.width - arrowHalf, arrowX))
        self.arrowY = max(arrowHalf, min(frame.size.height - arrowHalf, arrowY))
        
        self.contentView = contentView
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    func onTap(sender: UITapGestureRecognizer) {
        close()
    }
    
    public func close() {
        closeHandler?()
        removeFromSuperview()
    }
    
    public override func didMoveToSuperview() {
        if let contentView = contentView {
            contentView.center = horizontal ? bounds.center.offset(x: inverted ? -arrowHeight / 2 : arrowHeight / 2) : bounds.center.offset(y: inverted ? arrowHeight / 2 : -arrowHeight / 2)
            addSubview(contentView)
        }
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, bgColor.CGColor)
        CGContextSetStrokeColorWithColor(context, bgColor.CGColor)
        
        let rrect = horizontal ? rect.insetBy(dx: inverted ? 0 : arrowHeight, dw: inverted ? arrowHeight : 0) : rect.insetBy(dy: inverted ? arrowHeight : 0, dh: inverted ? 0 : arrowHeight)
        
        let minx = CGRectGetMinX(rrect), maxx = CGRectGetMaxX(rrect)
        let miny = CGRectGetMinY(rrect), maxy = CGRectGetMaxY(rrect)
        
        let outlinePath = CGPathCreateMutable()
        
        CGPathMoveToPoint(outlinePath, nil, minx, miny)
        CGPathAddLineToPoint(outlinePath, nil, maxx, miny)
        CGPathAddLineToPoint(outlinePath, nil, maxx, maxy)
        CGPathAddLineToPoint(outlinePath, nil, minx, maxy)
        CGPathCloseSubpath(outlinePath)
        CGContextAddPath(context, outlinePath)

        let arrowPath = CGPathCreateMutable()
        
        if inverted {
            
            if horizontal {
                CGPathMoveToPoint(arrowPath, nil, maxx, arrowY - arrowWidth / 2)
                CGPathAddLineToPoint(arrowPath, nil, maxx + arrowHeight, arrowY)
                CGPathAddLineToPoint(arrowPath, nil, maxx, arrowY + arrowWidth / 2)
                
            } else {
                CGPathMoveToPoint(arrowPath, nil, arrowX - arrowWidth / 2, miny)
                CGPathAddLineToPoint(arrowPath, nil, arrowX, miny - arrowHeight)
                CGPathAddLineToPoint(arrowPath, nil, arrowX + arrowWidth / 2, miny)
            }

        } else {
            
            if horizontal {
                CGPathMoveToPoint(arrowPath, nil, minx, arrowY - arrowWidth / 2)
                CGPathAddLineToPoint(arrowPath, nil, minx - arrowHeight, arrowY)
                CGPathAddLineToPoint(arrowPath, nil, minx, arrowY + arrowWidth / 2)

            } else {
                CGPathMoveToPoint(arrowPath, nil, arrowX + arrowWidth / 2, maxy)
                CGPathAddLineToPoint(arrowPath, nil, arrowX, maxy + arrowHeight)
                CGPathAddLineToPoint(arrowPath, nil, arrowX - arrowWidth / 2, maxy)
            }
        }
        
        CGPathCloseSubpath(arrowPath)
        CGContextAddPath(context, arrowPath)
        
        CGContextFillPath(context)
    }
}


extension InfoBubble {
    
    public convenience init(point: CGPoint, preferredSize: CGSize, superview: UIView, arrowHeight: CGFloat = 15, text: String, font: UIFont, textColor: UIColor, bgColor: UIColor = UIColor.grayColor(), minSuperviewPadding: CGFloat = 2, innerPadding: CGFloat = 4, horizontal: Bool = false) {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.sizeToFit()
        
        let size = CGSizeMake(max(preferredSize.width, label.frame.width + innerPadding * 2), max(preferredSize.height, label.frame.height + innerPadding * 2))
        
        self.init(point: point, size: size, superview: superview, arrowHeight: arrowHeight, contentView: label, bgColor: bgColor, horizontal: horizontal)
    }
}