//
//  String.swift
//  SwiftCharts
//
//  Created by ischuetz on 13/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension String {
    
    func size(_ font: UIFont) -> CGSize {
        return NSAttributedString(string: self, attributes: [.font: font]).size()
    }
    
    func width(_ font: UIFont) -> CGFloat {
        return size(font).width
    }
    
    func height(_ font: UIFont) -> CGFloat {
        return size(font).height
    }
}
