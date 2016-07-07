//
//  Pannable.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

protocol Pannable {
    
    var contentView: UIView {get}
    
    func pan(deltaX: CGFloat, deltaY: CGFloat)
    
    func onPan(deltaX: CGFloat, deltaY: CGFloat)
}

extension Pannable {

    func pan(deltaX: CGFloat, deltaY: CGFloat) {
        
        onPan(deltaX, deltaY: deltaY)
        
        guard let superframe = contentView.superview?.frame else {return}
        
        func maxTX(minXLimit: CGFloat) -> CGFloat {
            return minXLimit - (contentView.frame.minX - contentView.transform.tx)
        }

        func maxTY(minYLimit: CGFloat) -> CGFloat {
            return minYLimit - (contentView.frame.minY - contentView.transform.ty)
        }

        let tx = max(maxTX(superframe.width - contentView.frame.width), min(maxTX(0), contentView.transform.tx + deltaX))
        contentView.transform.tx = tx
        
        let ty = max(maxTY(superframe.height - contentView.frame.height), min(maxTY(0), contentView.transform.ty + deltaY))
        contentView.transform.ty = ty
    }
}
