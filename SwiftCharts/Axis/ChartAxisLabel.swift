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
   
    var textSize: CGSize {
        return ChartUtils.textSize(self.text, font: self.settings.font)
    }
    
    public init(text: String, settings: ChartLabelSettings) {
        self.text = text
        self.settings = settings
    }
}
