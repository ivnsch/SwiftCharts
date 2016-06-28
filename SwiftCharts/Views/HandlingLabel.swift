//
//  HandlingLabel.swift
//  Examples
//
//  Created by ischuetz on 18/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Convenience view to handle events without subclassing
public class HandlingLabel: UILabel {
        
    public var movedToSuperViewHandler: (() -> ())?
    public var touchHandler: (() -> ())?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        userInteractionEnabled = true
    }
    
    override public func didMoveToSuperview() {
        self.movedToSuperViewHandler?()
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchHandler?()
    }
}