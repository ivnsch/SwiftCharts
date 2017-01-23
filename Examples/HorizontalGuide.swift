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

    init(_ location: CGFloat, color: UIColor = UIColor.red) {
        super.init(frame: CGRect(x: -10000000, y: location, width: 100000000, height: 1))
        backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}