//
//  ChartAxisValuesGeneratorXDividers.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

public class ChartAxisValuesGeneratorXDividers: ChartAxisGeneratorMultiplier {
    
    public override var first: Double? {
        return Double(minValue)
    }
    
    public override var last: Double?  {
        return Double(maxValue)
    }
    
    private var minValue: Double
    private var maxValue: Double
    private let minSpace: CGFloat
    private let nice: Bool
    private let preferredDividers: Int
    
    private let maxTextSize: CGFloat
    
    public init(minValue: Double, maxValue: Double, preferredDividers: Int, nice: Bool, formatter: NSNumberFormatter, font: UIFont, minSpace: CGFloat = 10, multiplierUpdateMode: ChartAxisGeneratorMultiplierUpdateMode = .Halve) {
        
        self.minValue = minValue
        self.maxValue = maxValue
        
        self.nice = nice
        self.preferredDividers = preferredDividers
        self.minSpace = minSpace
        
        self.maxTextSize = ChartAxisValuesGeneratorXDividers.largestSize(minValue, maxValue: maxValue, formatter: formatter, font: font)
        
        super.init(DBL_MAX, multiplierUpdateMode: multiplierUpdateMode)
    }
    
    private static func largestSize(minValue: Double, maxValue: Double, formatter: NSNumberFormatter, font: UIFont) -> CGFloat {
        
        let minNumberTextSize = ChartUtils.textSize(formatter.stringFromNumber(minValue)!, font: font).width
        let maxNumberTextSize = ChartUtils.textSize(formatter.stringFromNumber(maxValue)!, font: font).width
        
        let minDigits = formatter.minimumFractionDigits
        let maxDigits = formatter.maximumFractionDigits
        
        let remainingWidth: CGFloat = {
            if minDigits < maxDigits {
                return (minDigits..<maxDigits).reduce(0) {total, _ in total + ChartUtils.textSize("0", font: font).width}
            } else {
                return 0
            }
        }()

        return max(minNumberTextSize, maxNumberTextSize) + remainingWidth
    }
    
    public func calculateFittingRangeAndFactor(axis: ChartAxis) -> (min: Double, max: Double, factor: Double)? {
        
        if nice {
            let niceMinMax = self.nice(minValue: Double(minValue), maxValue: Double(maxValue))
            self.minValue = niceMinMax.minValue
            self.maxValue = niceMinMax.maxValue
        }
        
        let growDelta = floor(pow(10, round(log10(Double(min(abs(minValue), abs(maxValue)))))))
        
        let length = maxValue - minValue
        let maxDelta = length / 6 // try to expand range to the left/right of initial range
        
        var fittingFactorsPerDelta = [(min: Double, max: Double, factor: Double)]()
        var currentDelta: Double = 0
        var counter = 0 // just in case
        while(currentDelta < maxDelta && counter < 100) {
            let min = minValue - currentDelta
            let max = maxValue + currentDelta
            if let fittingFactor = findFittingFactor(axis, modelLength: Int(max - min)) {
                fittingFactorsPerDelta.append((min, max, Double(fittingFactor)))
            }

            currentDelta += growDelta // grow left and right
            counter += 1
        }
        
        var maxFittingFactorOpt: (min: Double, max: Double, factor: Double)?
        for f in fittingFactorsPerDelta {
            
            if let maxFittingFactor = maxFittingFactorOpt {
                if f.factor > maxFittingFactor.factor {
                    maxFittingFactorOpt = f
                }
            } else {
                maxFittingFactorOpt = f
            }
        }
        
        return maxFittingFactorOpt
    }
    
    // inspired by d3 nice
    private func nice(minValue minValue: Double, maxValue: Double) -> (minValue: Double, maxValue: Double) {
        let span = pow(10, round(log(maxValue - minValue)/log(10)) - 1)
        return(minValue: (floor(minValue / span) * span), maxValue: (ceil(maxValue / span) * span))
    }
    
    private func findFittingFactor(axis: ChartAxis, modelLength: Int) -> Int? {
        
        let factors = modelLength.primeFactors
        
        var lastFitting: Int?
        
        // look for max factor which fits
        for factor in factors {
            if minSpace + ((maxTextSize + minSpace) * CGFloat(factor)) < axis.screenLength {
                lastFitting = factor
            } else { // when labels don't fit, return the previous fitting
                return lastFitting
            }
        }
        return lastFitting
    }
    
    public override func axisInitialized(axis: ChartAxis) {
        
        func defaultInit() {
            let maxDividers = Int((axis.screenLength + minSpace) / (maxTextSize + minSpace))
            let dividers = min(preferredDividers, maxDividers)
            self.multiplier = axis.length / Double(dividers)
        }
        
        if nice {
            if let rangeAndMultiplier = calculateFittingRangeAndFactor(axis) {
                self.minValue = rangeAndMultiplier.min
                self.maxValue = rangeAndMultiplier.max
                self.multiplier = Double(maxValue - minValue) / Double(rangeAndMultiplier.factor)
                
            } else {
                defaultInit()
            }
        } else {
            defaultInit()
        }
    }
}