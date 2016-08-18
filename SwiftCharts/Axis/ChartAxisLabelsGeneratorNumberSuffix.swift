//
//  ChartAxisLabelsGeneratorNumberSuffix.swift
//  SwiftCharts
//
//  Created by ischuetz on 21/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

public enum ChartAxisLabelNumberSuffixUnit {
    case K, M, G, T, P, E

    static var seq: [ChartAxisLabelNumberSuffixUnit] {
        return [K, M, G, T, P, E]
    }
    
    var values: (factor: Double, text: String) {
        switch self {
        case .K: return (pow(10, 3), "K")
        case .M: return (pow(10, 6), "M")
        case .G: return (pow(10, 9), "G")
        case .T: return (pow(10, 12), "T")
        case .P: return (pow(10, 15), "P")
        case .E: return (pow(10, 18), "E")
        }
    }
    
    public var factor: Double {
        return values.factor
    }
    
    public var text: String {
        return values.text
    }
}

public class ChartAxisLabelsGeneratorNumberSuffix: ChartAxisLabelsGeneratorBase {
    
    public let labelSettings: ChartLabelSettings
    
    public let startUnit: ChartAxisLabelNumberSuffixUnit
    
    public let formatter: NSNumberFormatter
    
    public init(labelSettings: ChartLabelSettings, startUnit: ChartAxisLabelNumberSuffixUnit = .M, formatter: NSNumberFormatter = ChartAxisLabelsGeneratorNumberSuffix.defaultFormatter) {
        self.labelSettings = labelSettings
        self.startUnit = startUnit
        self.formatter = formatter
    }

    // src: http://stackoverflow.com/a/23290016/930450
    public override func generate(scalar: Double) -> [ChartAxisLabel] {
        let sign = scalar < 0 ? "-" : ""
        
        let absScalar = fabs(scalar)
        
        let (number, suffix): (Double, String) = {
            if (absScalar < startUnit.factor) {
                return (absScalar, "")
                
            } else {
                let exp = Int(log10(absScalar) / 3)
                let roundedScalar = round(10 * absScalar / pow(1000, Double(exp))) / 10
                return (roundedScalar, ChartAxisLabelNumberSuffixUnit.seq[exp - 1].text)
            }
        }()

        let text = "\(sign)\(formatter.stringFromNumber(number)!)\(suffix)"
        return [ChartAxisLabel(text: text, settings: labelSettings)]
    }
    
    static var defaultFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    public override func fonts(scalar: Double) -> [UIFont] {
        return [labelSettings.font]
    }
}