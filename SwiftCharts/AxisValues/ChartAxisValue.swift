//
//  ChartAxisValue.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/**
    An axis value, which is represented internally by a double and provides the label which is displayed in the chart (or labels, in the case of working with multiple labels per axis value).
    This class is not meant to be instantiated directly. Use one of the existing subclasses or create a new one.
*/
public class ChartAxisValue: Equatable {

    public let scalar: Double
   
    public var text: String {
        fatalError("Override")
    }
    
    /**
        Labels that will be displayed on the chart. How this is done depends on the implementation of ChartAxisLayer.
        In the most common case this will be an array with only one element.
    */
    public var labels: [ChartAxisLabel] {
        fatalError("Override")
    }
    
    public var hidden: Bool = false {
        didSet {
            for label in self.labels {
                label.hidden = self.hidden
            }
        }
    }
  
    public init(scalar: Double) {
        self.scalar = scalar
    }
    
    public var copy: ChartAxisValue {
        return self.copy(self.scalar)
    }
    
    public func copy(scalar: Double) -> ChartAxisValue {
        return ChartAxisValue(scalar: self.scalar)
    }
}

public func ==(lhs: ChartAxisValue, rhs: ChartAxisValue) -> Bool {
    return lhs.scalar == rhs.scalar
}