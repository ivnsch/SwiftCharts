//
//  ChartTextUtils.swift
//  SwiftCharts
//
//  Created by ischuetz on 13/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

struct ChartTextUtils {
    
    static func maxTextWidth(minValue: Double, maxValue: Double, formatter: NSNumberFormatter, font: UIFont) -> CGFloat {
        
        let noDecimalsFormatter = NSNumberFormatter()
        noDecimalsFormatter.maximumFractionDigits = 0
        noDecimalsFormatter.roundingMode = .RoundDown
        
        let noDecimalsMin = noDecimalsFormatter.stringFromNumber(minValue)!
        let noDecimalsMax = noDecimalsFormatter.stringFromNumber(maxValue)!
        
        let minNumberNoDecimalsTextSize = noDecimalsMin.width(font)
        let maxNumberNoDecimalsTextSize = noDecimalsMax.width(font)
        
        let maxNoDecimalsLength = max(minNumberNoDecimalsTextSize, maxNumberNoDecimalsTextSize)
        
        let digitMaxWidth = "8".width(font)
        let maxDecimalsWidth = CGFloat(formatter.maximumFractionDigits) * digitMaxWidth
        
        let widthForDecimalSign = formatter.maximumFractionDigits > 0 ? formatter.decimalSeparator.width(font) : 0
        
        return maxNoDecimalsLength + maxDecimalsWidth + widthForDecimalSign
    }
    
    static func maxTextHeight(minValue: Double, maxValue: Double, formatter: NSNumberFormatter, font: UIFont) -> CGFloat {
        return "H".height(font)
    }
}