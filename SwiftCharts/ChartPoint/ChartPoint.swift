//
//  ChartPoint.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPoint: Hashable, Equatable, CustomStringConvertible {
    
    public let x: ChartAxisValue
    public let y: ChartAxisValue
    
    required public init(x: ChartAxisValue, y: ChartAxisValue) {
        self.x = x
        self.y = y
    }
    
    open var description: String {
        return "\(x), \(y)"
    }
    
    open func hash(into hasher: inout Hasher) {
        let hash = 31 &* x.hashValue &+ y.hashValue
        hasher.combine(hash)
    }
}

public func ==(lhs: ChartPoint, rhs: ChartPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
