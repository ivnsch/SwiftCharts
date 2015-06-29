//
//  ChartAxisLabel.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisLabel {
    
    public let text: String
    let settings: ChartLabelSettings

    var hidden: Bool = false
   
    lazy var textSize: CGSize = {
        let size = ChartUtils.textSize(self.text, font: self.settings.font)
        if self.settings.rotation == 0 {
            return size
        } else {
            return ChartUtils.boundingRectAfterRotatingRect(CGRectMake(0, 0, size.width, size.height), radians: self.settings.rotation * CGFloat(M_PI) / 180.0).size
        }
    }()
    
    public init(text: String, settings: ChartLabelSettings) {
        self.text = text
        self.settings = settings
    }
}
