//
//  HorizontalGuide.swift
//  SwiftCharts
//
//  Created by ischuetz on 14/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

/// Debug helper
class HorizontalGuide: UIView {

    init(_ location: CGFloat, color: UIColor = UIColor.redColor()) {
        super.init(frame: CGRectMake(-10000000, location, 100000000, 1))
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}