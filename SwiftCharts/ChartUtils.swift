//
//  ChartUtils.swift
//  swift_charts
//
//  Created by ischuetz on 10/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A collection of useful utilities for chart calculations
public class ChartUtils {

    /**
     Calculates the size of a string if it were drawn with a given font

     - parameter text: The string to calculate size for
     - parameter font: The font used to calculate the drawn size

     - returns: The size of the string if it were drawn with a given font
     */
    public class func textSize(text: String, font: UIFont) -> CGSize {
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font]).size()
    }

    /**
     Calculates the bounding bounds of a string if drawn with a given font and rotated

     - parameter text:  The string to calculate the bounds for
     - parameter font:  The font used to calculate the drawn bounds
     - parameter angle: The angle in degrees that the bounds should be rotated by

     - returns: The bounding bounds for the string if drawn with a given font and rotated
     */
    public class func rotatedTextBounds(text: String, font: UIFont, angle: CGFloat) -> CGRect {
        let labelSize = ChartUtils.textSize(text, font: font)
        let radians = angle * CGFloat(M_PI) / CGFloat(180)
        return boundingRectAfterRotatingRect(CGRectMake(0, 0, labelSize.width, labelSize.height), radians: radians)
    }
    
    /**
     Calculates the bounding rectangle of a rectangle after it's rotated.

     Source: http://stackoverflow.com/a/9168238/930450

     - parameter rect:    The original rectangle to rotate
     - parameter radians: The angle in radians that it's to be rotated

     - returns: The bounding rectangle of the rotated rectangle
     */
    public class func boundingRectAfterRotatingRect(rect: CGRect, radians: CGFloat) -> CGRect {
        let xfrm = CGAffineTransformMakeRotation(radians)
        return CGRectApplyAffineTransform(rect, xfrm)
    }

    /**
     Converts seconds to the same amount as a dispatch_time_t

     - parameter secs: The number of seconds

     - returns: The number of seconds as a dispatch_time_t
     */
    public class func toDispatchTime(secs: Float) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(Double(secs) * Double(NSEC_PER_SEC)))
    }
    
    
    public class func insetBy(rect: CGRect, dx: CGFloat = 0, dy: CGFloat = 0, dw: CGFloat = 0, dh: CGFloat = 0) -> CGRect {
        return CGRectMake(
            rect.origin.x + dx,
            rect.origin.y + dy,
            rect.width - dw - dx,
            rect.height - dh - dy
        )
    }
    
    public static func maxTextWidth(minValue: Double, maxValue: Double, formatter: NSNumberFormatter, font: UIFont) -> CGFloat {
        
        let noDecimalsFormatter = NSNumberFormatter()
        noDecimalsFormatter.maximumFractionDigits = 0
        noDecimalsFormatter.roundingMode = .RoundDown
        
        let noDecimalsMin = noDecimalsFormatter.stringFromNumber(minValue)!
        let noDecimalsMax = noDecimalsFormatter.stringFromNumber(maxValue)!
        
        let minNumberNoDecimalsTextSize = textSize(noDecimalsMin, font: font).width
        let maxNumberNoDecimalsTextSize = textSize(noDecimalsMax, font: font).width
        
        let maxNoDecimalsLength = max(minNumberNoDecimalsTextSize, maxNumberNoDecimalsTextSize)
        
        let digitMaxWidth = textSize("8", font: font).width
        let maxDecimalsWidth = CGFloat(formatter.maximumFractionDigits) * digitMaxWidth
        
        let widthForDecimalSign = formatter.maximumFractionDigits > 0 ? textSize(formatter.decimalSeparator, font: font).width : 0
        
        return maxNoDecimalsLength + maxDecimalsWidth + widthForDecimalSign
    }

    public static func maxTextHeight(minValue: Double, maxValue: Double, formatter: NSNumberFormatter, font: UIFont) -> CGFloat {
        return ChartUtils.textSize("H", font: font).height
    }
}
