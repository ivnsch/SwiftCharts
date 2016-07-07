//
//  ChartAxisY.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisY: ChartAxis {
    
    public override var length: Double {
        return last - first
    }
    
    public override var screenLength: CGFloat {
        return firstScreen - lastScreen
    }
    
    public override var visibleLength: Double {
        return lastVisible - firstVisible
    }
    
    public override var visibleScreenLength: CGFloat {
        return firstVisibleScreen - lastVisibleScreen
    }
    
    public override func screenLocForScalar(scalar: Double) -> CGFloat {
        return firstScreen - internalScreenLocForScalar(scalar)
    }
    
    public override func innerScreenLocForScalar(scalar: Double) -> CGFloat {
        return screenLength - internalScreenLocForScalar(scalar)
    }
    
    public override func scalarForScreenLoc(screenLoc: CGFloat) -> Double {
        return (Double(-(screenLoc - firstScreen)) * length / Double(screenLength)) + first
    }
    
    public override func innerScalarForScreenLoc(screenLoc: CGFloat) -> Double {
        return length + (Double(-(screenLoc)) * length / Double(screenLength)) + first
    }
}