//
//  ChartAxisValueInt.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValueInt: ChartAxisValue {

    public let int: Int
    private let labelSettings: ChartLabelSettings
    
    override public var text: String {
        return "\(self.int)"
    }
    
    public init(_ int: Int, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.int = int
        self.labelSettings = labelSettings
        super.init(scalar: Double(int))
    }
    
    override public var labels:[ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    override public func copy(scalar: Double) -> ChartAxisValueInt {
        return ChartAxisValueInt(self.int, labelSettings: self.labelSettings)
    }
}
