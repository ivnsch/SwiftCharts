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
    
    init(_ location: CGPoint, color: UIColor = UIColor.red) {
        super.init(frame: CGRect(x: location.x - size / 2, y: location.y - size / 2, width: size, height: size))
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
