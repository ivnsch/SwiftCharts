//
//  ChartAxisValuesGeneratorDate.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValuesGeneratorDate: ChartAxisGeneratorMultiplier {
    
    let unit: NSCalendarUnit

    private let minSpace: CGFloat
    private let preferredDividers: Int
    private let maxTextSize: CGFloat
    
    public init(unit: NSCalendarUnit, preferredDividers: Int, minSpace: CGFloat, maxTextSize: CGFloat) {
        self.unit = unit
        self.preferredDividers = preferredDividers
        self.minSpace = minSpace
        self.maxTextSize = maxTextSize
        super.init(0)
    }
    
    override func calculateModelStart(axis: ChartAxis, multiplier: Double) -> Double {
        guard !multiplier.isNaN && !multiplier.isZero else {return Double.NaN}
        
        let firstVisibleDate = NSDate(timeIntervalSince1970: axis.firstVisible)
        let firstInitDate = NSDate(timeIntervalSince1970: axis.firstInit)
        
        return firstInitDate.addComponent(Int((Double(firstVisibleDate.timeInterval(firstInitDate, unit: unit)) / multiplier)) * Int(multiplier), unit: unit).timeIntervalSince1970
    }
    
    override func incrementScalar(scalar: Double, multiplier: Double) -> Double {
        let scalarDate = NSDate(timeIntervalSince1970: scalar)
        return scalarDate.addComponent(Int(multiplier), unit: unit).timeIntervalSince1970
    }
    
    public override func axisInitialized(axis: ChartAxis) {
        
        var dividers = preferredDividers
        var cont = true
        
        while dividers > 1 && cont {
            if requiredLengthForDividers(dividers) < axis.screenLength {
                
                let firstDate = NSDate(timeIntervalSince1970: axis.first)
                let lastDate = NSDate(timeIntervalSince1970: axis.last)
                let lengthInUnits = lastDate.timeInterval(firstDate, unit: unit)
                
                self.multiplier = Double(lengthInUnits) / Double(dividers)
                cont = false
                
            } else {
                dividers -= 1
            }
        }
    }
    
    private func requiredLengthForDividers(dividers: Int) -> CGFloat {
        return minSpace + ((maxTextSize + minSpace) * CGFloat(dividers))
    }
}