//
//  String.swift
//  SwiftCharts
//
//  Created by ischuetz on 13/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension String {
    
    func size(font: UIFont) -> CGSize {
        return NSAttributedString(string: self, attributes: [NSFontAttributeName: font]).size()
    }
    
    func width(font: UIFont) -> CGFloat {
        return size(font).width
    }
    
    func height(font: UIFont) -> CGFloat {
        return size(font).height
    }
}
