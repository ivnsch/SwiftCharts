//
//  ChartAxisLabel.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A model of an axis label
public class ChartAxisLabel {

    /// Displayed text. Can be truncated.
    public let text: String
    
    public let settings: ChartLabelSettings

    public private(set) var originalText: String
    
    var hidden: Bool = false

    /// The size of the bounding rectangle for the axis label, taking into account the font and rotation it will be drawn with
    public lazy var textSize: CGSize = {
        let size = self.text.size(self.settings.font)
        if self.settings.rotation =~ 0 {
            return size
        } else {
            return CGRectMake(0, 0, size.width, size.height).boundingRectAfterRotating(radians: self.settings.rotation * CGFloat(M_PI) / 180.0).size
        }
    }()
    
    public init(text: String, settings: ChartLabelSettings) {
        self.text = text
        self.settings = settings
        self.originalText = text
    }
    
    func copy(text text: String? = nil, settings: ChartLabelSettings? = nil, originalText: String? = nil, hidden: Bool? = nil) -> ChartAxisLabel {
        let label = ChartAxisLabel(
            text: text ?? self.text,
            settings: settings ?? self.settings
        )
        self.originalText = originalText ?? self.originalText
        self.hidden = hidden ?? self.hidden
        return label
    }
}
