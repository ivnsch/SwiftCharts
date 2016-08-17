//
//  ChartAxisX.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisX: ChartAxis {
    
    public override var length: Double {
        return last - first
    }
    
    public override var screenLength: CGFloat {
        return lastScreen - firstScreen
    }

    public override var screenLengthInit: CGFloat {
        return lastScreenInit - firstScreenInit
    }
    
    public override var visibleLength: Double {
        return lastVisible - firstVisible
    }
    
    public override var visibleScreenLength: CGFloat {
        return lastVisibleScreen - firstVisibleScreen
    }
    
    public override func screenLocForScalar(scalar: Double) -> CGFloat {
        return firstScreen + internalScreenLocForScalar(scalar)
    }
    
    public override func innerScreenLocForScalar(scalar: Double) -> CGFloat {
        return internalScreenLocForScalar(scalar)
    }
    
    public override func scalarForScreenLoc(screenLoc: CGFloat) -> Double {
        return Double((screenLoc - firstScreen) * modelToScreenRatio) + first
    }
    
    public override func innerScalarForScreenLoc(screenLoc: CGFloat) -> Double {
        return Double(screenLoc * modelToScreenRatio) + first
    }
    
    public override var firstModelValueInBounds: Double {
        return firstVisible + screenToModelLength(fixedPaddingFirstScreen ?? paddingFirstScreen)
    }
    
    public override var lastModelValueInBounds: Double {
        return lastVisible - screenToModelLength(fixedPaddingLastScreen ?? paddingLastScreen)
    }

    override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        
        // Zoom around center of gesture. Uses center as anchor point dividing the line in 2 segments which are scaled proportionally.
        let segment1 = centerX - firstScreen
        let segment2 = lastScreen - centerX
        let deltaSegment1 = (segment1 * x) - segment1
        let deltaSegment2 = (segment2 * x) - segment2
        var newOriginX = firstScreen - deltaSegment1
        var newEndX = lastScreen + deltaSegment2
        
        if newEndX < lastScreenInit {
            let delta = lastScreenInit - newEndX
            newEndX = lastScreenInit
            newOriginX = newOriginX + delta
        }
        
        if newOriginX > firstScreenInit {
            let delta = newOriginX - firstScreenInit
            newOriginX = firstScreenInit
            newEndX = newEndX - delta
        }
        
        if newEndX - newOriginX > lastScreenInit - firstScreenInit { // new length > original length
            firstScreen = newOriginX
            lastScreen = newEndX
            
            // if p1 is to the right of origin, move it back
            let offsetOriginX = firstScreen - firstScreenInit
            if offsetOriginX > 0 {
                firstScreen = firstScreen - offsetOriginX
                lastScreen = lastScreen - offsetOriginX
            }
            
        } else { // possible correction
            firstScreen = firstScreenInit
            lastScreen = lastScreenInit
        }
    }
    
    
    override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        
        let length = screenLength
        
        let (newOriginX, newEndX): (CGFloat, CGFloat) = {
            
            if deltaX < 0 { // scrolls left
                let endX = max(lastScreenInit, lastScreen + deltaX)
                let originX = endX - length
                return (originX, endX)
                
            } else if deltaX > 0 {  // scrolls right
                let originX = min(firstScreen + deltaX, firstScreenInit)
                let endX = originX + length
                return (originX, endX)
                
            } else {
                return (firstScreen, lastScreen)
            }
        }()
        
        firstScreen = newOriginX
        lastScreen = newEndX
    }
    
    override func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        zoom(scaleX / CGFloat(zoomFactor), y: scaleY, centerX: centerX, centerY: centerY)
    }
 
    override func toModelInner(screenLoc: CGFloat) -> Double {
        return Double(screenLoc - firstScreenInit - paddingFirstScreen) * innerRatio + firstInit
    }
    
    override func isInBoundaries(screenCenter: CGFloat, screenSize: CGSize) -> Bool {
        return screenCenter - screenSize.width / 2 >= firstVisibleScreen && screenCenter + screenSize.width / 2 <= lastVisibleScreen
    }
    
}
