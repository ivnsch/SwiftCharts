//
//  Operators.swift
//  SwiftCharts
//
//  Created by ischuetz on 16/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

infix operator =~ { associativity left precedence 130 }

func =~ (a: Float, b: Float) -> Bool {
    return fabsf(a - b) < FLT_EPSILON
}

func =~ (a: CGFloat, b: CGFloat) -> Bool {
    return fabs(a - b) < CGFloat(FLT_EPSILON)
}

func =~ (a: Double, b: Double) -> Bool {
    return fabs(a - b) < Double(FLT_EPSILON)
}

infix operator !=~ { associativity left precedence 130 }

func !=~ (a: Float, b: Float) -> Bool {
    return !(a =~ b)
}

func !=~ (a: CGFloat, b: CGFloat) -> Bool {
    return !(a =~ b)
}

func !=~ (a: Double, b: Double) -> Bool {
    return !(a =~ b)
}

infix operator <=~ { associativity left precedence 130 }

func <=~ (a: Float, b: Float) -> Bool {
    return a =~ b || a < b
}

func <=~ (a: CGFloat, b: CGFloat) -> Bool {
    return a =~ b || a < b
}

func <=~ (a: Double, b: Double) -> Bool {
    return a =~ b || a < b
}

infix operator >=~ { associativity left precedence 130 }

func >=~ (a: Float, b: Float) -> Bool {
    return a =~ b || a > b
}

func >=~ (a: CGFloat, b: CGFloat) -> Bool {
    return a =~ b || a > b
}

func >=~ (a: Double, b: Double) -> Bool {
    return a =~ b || a > b
}