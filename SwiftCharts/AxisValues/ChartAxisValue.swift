//
//  ChartAxisValue.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValue: Equatable {

    public let scalar: CGFloat
   
    public var text: String {
        return "\(self.scalar)"
    }
    
    public var labels: [ChartAxisLabel] {
        return []
    }
    
    public var hidden: Bool = false {
        didSet {
            for label in self.labels {
                label.hidden = self.hidden
            }
        }
    }
  
    public init(scalar: CGFloat) {
        self.scalar = scalar
    }
    
    public var copy: ChartAxisValue {
        return self.copy(self.scalar)
    }
    
    public func copy(scalar: CGFloat) -> ChartAxisValue {
        return ChartAxisValue(scalar: self.scalar)
    }
}

public func ==(lhs: ChartAxisValue, rhs: ChartAxisValue) -> Bool {
    return lhs.scalar == rhs.scalar
}