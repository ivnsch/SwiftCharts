//
//  ChartAxisLabel.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A model of an axis label
open class ChartAxisLabel {

    open let text: String
    let settings: ChartLabelSettings

    var hidden: Bool = false

    /// The size of the bounding rectangle for the axis label, taking into account the font and rotation it will be drawn with
    lazy var textSize: CGSize = {
        let size = ChartUtils.textSize(self.text, font: self.settings.font)
        if self.settings.rotation == 0 {
            return size
        } else {
            return ChartUtils.boundingRectAfterRotatingRect(CGRect(x: 0, y: 0, width: size.width, height: size.height), radians: self.settings.rotation * CGFloat(M_PI) / 180.0).size
        }
    }()
    
    public init(text: String, settings: ChartLabelSettings) {
        self.text = text
        self.settings = settings
    }
}
