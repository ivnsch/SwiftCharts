//
//  String.swift
//  SwiftCharts
//
//  Created by ischuetz on 13/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start..<end)]
    }

    func size(font: UIFont) -> CGSize {
        return NSAttributedString(string: self, attributes: [NSFontAttributeName: font]).size()
    }
    
    func width(font: UIFont) -> CGFloat {
        return size(font).width
    }
    
    func height(font: UIFont) -> CGFloat {
        return size(font).height
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func fittingSubstring(width: CGFloat, font: UIFont) -> String {
        for i in characters.count.stride(to: 0, by: -1) {
            let substr = self[0..<i]
            if substr.width(font) <= width {
                return substr
            }
        }
        return ""
    }

    func truncate(width: CGFloat, font: UIFont) -> String {
        let ellipsis = "..."
        let substr = fittingSubstring(width - ellipsis.width(font), font: font)
        if substr.characters.count != self.characters.count {
            return "\(substr.trim())\(ellipsis)"
        } else {
            return self
        }
    }
    
    // TODO Doesn't work - why?
//    func fittingSubstring(width: CGFloat, font: UIFont) -> String {
//        let fontRef = CTFontCreateWithName(font.fontName, font.pointSize, nil)
//        
//        let attributes: [String: AnyObject] = [String(kCTFontAttributeName): fontRef]
////        let attributes: [String: AnyObject] = [NSFontAttributeName : fontRef]
//        
//        let attributedString = NSAttributedString(string: self, attributes: attributes)
//        
//        let frameSetterRef = CTFramesetterCreateWithAttributedString(attributedString)
//        
//        var characterFitRange = CFRangeMake(0, 0)
//        CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), nil, CGSizeMake(width, font.lineHeight), &characterFitRange)
//        
//        let characterCount = characterFitRange.length
//        
//        return substringToIndex(startIndex.advancedBy(characterCount))
//    }
}
