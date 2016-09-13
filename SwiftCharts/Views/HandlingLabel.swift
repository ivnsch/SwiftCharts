//
//  HandlingLabel.swift
//  Examples
//
//  Created by ischuetz on 18/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Convenience view to handle events without subclassing
open class HandlingLabel: UILabel {
        
    open var movedToSuperViewHandler: (() -> ())?
    open var touchHandler: (() -> ())?
    
    override open func didMoveToSuperview() {
        self.movedToSuperViewHandler?()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchHandler?()
    }
}
