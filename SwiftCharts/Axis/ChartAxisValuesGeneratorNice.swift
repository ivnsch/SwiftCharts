//
//  ChartAxisValuesGeneratorNice.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValuesGeneratorNice: ChartAxisGeneratorMultiplier {
    
    public override var first: Double? {
        return Double(minValue)
    }
    
    public override var last: Double?  {
        return Double(maxValue)
    }
    
    private var minValue: Double
    private var maxValue: Double
    private let minSpace: CGFloat
    private let preferredDividers: Int
    
    private let maxTextSize: CGFloat
    
    public init(minValue: Double, maxValue: Double, preferredDividers: Int, minSpace: CGFloat, maxTextSize: CGFloat) {
        
        self.minValue = minValue
        self.maxValue = maxValue
        
        self.preferredDividers = preferredDividers
        self.minSpace = minSpace
        
        self.maxTextSize = maxTextSize
        
        super.init(DBL_MAX)
    }
    
    func niceRangeAndMultiplier(dividers: Int) -> (minValue: Double, maxValue: Double, multiplier: Double) {
        let niceLength = niceNumber(maxValue - minValue, round: true)
        let niceMultiplier = niceNumber(niceLength / (Double(dividers) - 1), round: true)
        let niceMinValue = floor(minValue / niceMultiplier) * niceMultiplier
        let niceMaxValue = ceil(maxValue / niceMultiplier) * niceMultiplier
        return (niceMinValue, niceMaxValue, niceMultiplier)
    }
    
    // src: http://stackoverflow.com/a/4948320/930450
    private func niceNumber(value: Double, round: Bool) -> Double {
        
        let exponent = floor(log10(value))
        
        let fraction = value / pow(10, exponent)
        
        var niceFraction = 1.0
        
        if round {
            if fraction < 1.5 {
                niceFraction = 1
            } else if fraction < 3 {
                niceFraction = 2
            } else if fraction < 7 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
            
        } else {
            if fraction <= 1 {
                niceFraction = 1
            } else if fraction <= 2 {
                niceFraction = 2
            } else if niceFraction <= 5 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        }
        
        return niceFraction * pow(10, exponent)
    }
    
    public override func axisInitialized(axis: ChartAxis) {
        
        var dividers = preferredDividers
        var cont = true
        
        while dividers > 1 && cont {
            
            let nice = niceRangeAndMultiplier(dividers)
            
            if requiredLengthForDividers(dividers) < axis.screenLength {
                
                self.minValue = nice.minValue
                self.maxValue = nice.maxValue
                self.multiplier = nice.multiplier
                
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