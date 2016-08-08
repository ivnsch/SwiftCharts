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
    
    public init(minValue: Double, maxValue: Double, preferredDividers: Int, minSpace: CGFloat, maxTextSize: CGFloat, multiplierUpdateMode: ChartAxisGeneratorMultiplierUpdateMode = .Halve) {
        
        self.minValue = minValue
        self.maxValue = maxValue
        
        self.preferredDividers = preferredDividers
        self.minSpace = minSpace
        
        self.maxTextSize = maxTextSize
        
        super.init(DBL_MAX, multiplierUpdateMode: multiplierUpdateMode)
    }
    
    func niceRangeAndMultiplier(dividers: Int) -> (minValue: Double, maxValue: Double, multiplier: Double) {
        let niceLength = ChartNiceNumberCalculator.niceNumber(maxValue - minValue, round: true)
        let niceMultiplier = ChartNiceNumberCalculator.niceNumber(niceLength / (Double(dividers) - 1), round: true)
        let niceMinValue = floor(minValue / niceMultiplier) * niceMultiplier
        let niceMaxValue = ceil(maxValue / niceMultiplier) * niceMultiplier
        return (niceMinValue, niceMaxValue, niceMultiplier)
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