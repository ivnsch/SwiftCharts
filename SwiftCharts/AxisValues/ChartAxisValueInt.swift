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

    public init(_ int: Int, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.int = int
        super.init(scalar: Double(int), labelSettings: labelSettings)
    }
    
    override public func copy(scalar: Double) -> ChartAxisValueInt {
        return ChartAxisValueInt(self.int, labelSettings: self.labelSettings)
    }

    // MARK: CustomStringConvertible
    
    override public var description: String {
        return String(self.int)
    }
}
