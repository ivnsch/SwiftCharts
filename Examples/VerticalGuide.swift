//
//  VerticalGuide.swift
//  SwiftCharts
//
//  Created by ischuetz on 14/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

/// Debug helper
class VerticalGuide: UIView {
    
    init(_ location: CGFloat, color: UIColor = UIColor.red) {
        super.init(frame: CGRect(x: location, y: -10000000, width: 1, height: 100000000))
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}