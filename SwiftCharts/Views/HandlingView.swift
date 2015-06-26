//
//  ChartItemView.swift
//  swift_charts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Convenience view to handle events without subclassing
public class HandlingView: UIView {
    
    public var movedToSuperViewHandler: (() -> ())?
    public var touchHandler: (() -> ())?

    override public func didMoveToSuperview() {
        self.movedToSuperViewHandler?()
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchHandler?()
    }
}