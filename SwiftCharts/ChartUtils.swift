//
//  ChartUtils.swift
//  swift_charts
//
//  Created by ischuetz on 10/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartUtils {

    public class func textSize(text: String, font: UIFont) -> CGSize {
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font]).size()
    }
    
    public class func rotatedTextBounds(text: String, font: UIFont, angle: CGFloat) -> CGRect {
        let labelSize = ChartUtils.textSize(text, font: font)
        let radians = angle * CGFloat(M_PI) / CGFloat(180)
        return boundingRectAfterRotatingRect(CGRectMake(0, 0, labelSize.width, labelSize.height), radians: radians)
    }
    
    // src: http://stackoverflow.com/a/9168238/930450
    public class func boundingRectAfterRotatingRect(rect: CGRect, radians: CGFloat) -> CGRect {
        let xfrm = CGAffineTransformMakeRotation(radians)
        return CGRectApplyAffineTransform(rect, xfrm)
    }
    
    public class func toDispatchTime(secs: Float) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(Double(secs) * Double(NSEC_PER_SEC)))
    }
}
