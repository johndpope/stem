//
//  extent.swift
//  stem
//
//  Created by Abe Schneider on 11/10/15.
//  Copyright © 2015 Abe Schneider. All rights reserved.
//

import Foundation

// TODO: look into adding this to Extent to allow
// broadcasting (currently directly supported in ops)
enum ExtentElement {
    case value(Int)
    case broadcast
}

public struct Extent: CollectionType {
    var values:[Int]
    public var elements:Int
    public var span:Int
    
    public var count:Int { return values.count }
    public var dims:[Int] { return values }
    
    public init(_ ex: Int...) {
        values = ex
        elements = values.reduce(1, combine: *)
        span = (values.map { Int($0 > 1) }).reduce(0, combine: +)
    }
    
    public init(_ dims:[Int]) {
        values = dims
        elements = values.reduce(1, combine: *)
        span = (values.map { Int($0 > 1) }).reduce(0, combine: +)
    }
    
    public init(_ extent:Extent) {
        values = extent.values
        elements = values.reduce(1, combine: *)
        span = (values.map { Int($0 > 1) }).reduce(0, combine: +)
    }
    
    // extend the extent over additional dimensions
    public init(_ extent:Extent, over:Int) {
        precondition(over >= extent.count)
        let diff = over - extent.count
        
        let ones = [Int](count: diff, repeatedValue: 1)
        values = extent.values + ones
        
        elements = values.reduce(1, combine: *)
        span = (values.map { Int($0 > 1) }).reduce(0, combine: +)
    }
    
    public var startIndex:Int { return 0 }
    public var endIndex:Int { return values.count }
    
    public subscript(index: Int) -> Int {
        get {
            // if we're beyond the bounds of the extent, always
            // return 1
            if index >= values.count {
                return 1
            }
            
            return values[index]
        }
        set {
            values[index] = newValue
            elements = values.reduce(1, combine: *)
        }
    }
    
    public func generate() -> AnyGenerator<Int> {
        var index:Int = 0
        return AnyGenerator {
            if index >= self.values.count { return nil }
            
            let currentIndex = index
            index += 1
            return self.values[currentIndex]
        }
    }
    
    public func max() -> Int {
        var bestValue = values[0]
        var bestIndex = 0
        
        for i in 1..<values.count {
            if values[i] > bestValue {
                bestIndex = i
                bestValue = values[i]
            }
        }
        
        return bestIndex
    }
}

extension Extent: Equatable {}

public func ==(left:Extent, right:Extent) -> Bool {
    if left.elements != right.elements { return false }
    
    for i in 0..<left.count {
        if left[i] != right[i] { return false }
    }
    
    return true
}

public func >(left:Extent, right:Extent) -> Bool {
    return left.elements > right.elements
}

// TODO: not sure this is the best way to implement this..
// probably should compare from right to left the number of
// elements per dimension
public func <(left:Extent, right:Extent) -> Bool {
    return left.elements < right.elements
}

public func max(left:Extent, _ right:Extent) -> Extent {
    return left > right ? left : right
}