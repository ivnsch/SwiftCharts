//
//  ChartPointTextCircleView.swift
//  swift_charts
//
//  Created by ischuetz on 14/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointTextCircleView: UILabel {
   
    fileprivate let targetCenter: CGPoint
    open var viewTapped: ((ChartPointTextCircleView) -> ())?
    
    open var selected: Bool = false {
        didSet {
            if self.selected {
                self.textColor = UIColor.white
                self.layer.borderColor = UIColor.white.cgColor
                self.layer.backgroundColor = UIColor.black.cgColor
                
            } else {
                self.textColor = UIColor.black
                self.layer.borderColor = UIColor.black.cgColor
                self.layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
    
    public init(chartPoint: ChartPoint, center: CGPoint, diameter: CGFloat, cornerRadius: CGFloat, borderWidth: CGFloat, font: UIFont) {
        
        self.targetCenter = center
        
        super.init(frame: CGRect(x: 0, y: center.y - diameter / 2, width: diameter, height: diameter))

        self.textColor = UIColor.black
        self.text = chartPoint.description
        self.font = font
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.textAlignment = NSTextAlignment.center
        self.layer.borderColor = UIColor.gray.cgColor
        
        let c = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
        self.layer.backgroundColor = c.cgColor

        self.isUserInteractionEnabled = true
    }
   
    override open func didMoveToSuperview() {
        
        super.didMoveToSuperview()
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            let w: CGFloat = self.frame.size.width
            let h: CGFloat = self.frame.size.height
            let frame = CGRect(x: self.targetCenter.x - (w/2), y: self.targetCenter.y - (h/2), width: w, height: h)
            self.frame = frame
            
            }, completion: {finished in})
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewTapped?(self)
    }
}
