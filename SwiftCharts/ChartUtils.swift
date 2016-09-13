//
//  ChartUtils.swift
//  swift_charts
//
//  Created by ischuetz on 10/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A collection of useful utilities for chart calculations
open class ChartUtils {

    /**
     Calculates the size of a string if it were drawn with a given font

     - parameter text: The string to calculate size for
     - parameter font: The font used to calculate the drawn size

     - returns: The size of the string if it were drawn with a given font
     */
    open class func textSize(_ text: String, font: UIFont) -> CGSize {
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font]).size()
    }

    /**
     Calculates the bounding bounds of a string if drawn with a given font and rotated

     - parameter text:  The string to calculate the bounds for
     - parameter font:  The font used to calculate the drawn bounds
     - parameter angle: The angle in degrees that the bounds should be rotated by

     - returns: The bounding bounds for the string if drawn with a given font and rotated
     */
    open class func rotatedTextBounds(_ text: String, font: UIFont, angle: CGFloat) -> CGRect {
        let labelSize = ChartUtils.textSize(text, font: font)
        let radians = angle * CGFloat(M_PI) / CGFloat(180)
        return boundingRectAfterRotatingRect(CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height), radians: radians)
    }
    
    /**
     Calculates the bounding rectangle of a rectangle after it's rotated.

     Source: http://stackoverflow.com/a/9168238/930450

     - parameter rect:    The original rectangle to rotate
     - parameter radians: The angle in radians that it's to be rotated

     - returns: The bounding rectangle of the rotated rectangle
     */
    open class func boundingRectAfterRotatingRect(_ rect: CGRect, radians: CGFloat) -> CGRect {
        let xfrm = CGAffineTransform(rotationAngle: radians)
        return rect.applying(xfrm)
    }

    /**
     Converts seconds to the same amount as a dispatch_time_t

     - parameter secs: The number of seconds

     - returns: The number of seconds as a dispatch_time_t
     */
    open class func toDispatchTime(_ secs: Float) -> DispatchTime {
        return DispatchTime.now() + Double(Int64(Double(secs) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    }
}
