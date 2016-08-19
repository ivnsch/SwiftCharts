//
//  PointGuide.swift
//  SwiftCharts
//
//  Created by ischuetz on 19/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

/// Debug helper
class PointGuide: UIView {
    
    let size: CGFloat = 5
    
    init(_ location: CGPoint, color: UIColor = UIColor.redColor()) {
        super.init(frame: CGRectMake(location.x - size / 2, location.y - size / 2, size, size))
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
