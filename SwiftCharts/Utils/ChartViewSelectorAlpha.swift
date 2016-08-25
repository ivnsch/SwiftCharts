//
//  ChartViewSelectorAlpha.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartViewSelectorAlpha: ChartViewSelector {
    
    private var selectedAlpha: CGFloat
    private var deselectedAlpha: CGFloat
    
    public init(selectedAlpha: CGFloat, deselectedAlpha: CGFloat) {
        self.selectedAlpha = selectedAlpha
        self.deselectedAlpha = deselectedAlpha
    }
    
    public func displaySelected(view: UIView, selected: Bool) {
        view.backgroundColor = view.backgroundColor.map{$0.copy(alpha: selected ? selectedAlpha : deselectedAlpha)}
    }
}