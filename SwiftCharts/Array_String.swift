//
//  Array_String.swift
//  SwiftCharts
//
//  Created by ischuetz on 13/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

protocol StringType {
    func width(font: UIFont) -> CGFloat
    func height(font: UIFont) -> CGFloat
}

extension String: StringType {}

extension Array where Element: StringType {
    
    func maxWidth(font: UIFont) -> CGFloat {
        return reduce(0) {sum, str in
            sum + str.width(font)
        }
    }
    
    func maxHeight(font: UIFont) -> CGFloat {
        return reduce(0) {sum, str in
            sum + str.width(font)
        }
    }
}