//
//  File.swift
//  
//
//  Created by Rick Street on 2/10/20.
//

import Foundation

public class Rga {
    public var ind1 = 0
    public var ind2 = 0
    public var dep1 = 0
    public var dep2 = 0
    public var gain11 = 0.0
    public var gain12 = 0.0
    public var gain21 = 0.0
    public var gain22 = 0.0
    
    let zeroTolerence = 3.0e-13
    
    public var rga11: Double {
        let denominator = gain11 * gain22 - gain12 * gain21
        if abs(denominator) < zeroTolerence {
            return 0.0
        }
        return gain11 * gain22 / denominator
    }
    
    public var rga: Double {
        if rga11 == 0 {
            return 0.0
        }
        if rga11 > 1.0 {
            return rga11
        } else {
            return 1.0 - rga11
        }
    }
        
    public init(ind1: Int, ind2: Int, dep1: Int, dep2: Int, gain11: Double, gain12: Double, gain21: Double, gain22: Double) {
        self.ind1 = ind1
        self.ind2 = ind2
        self.dep1 = dep1
        self.dep2 = dep2
        self.gain11 = gain11
        self.gain12 = gain12
        self.gain21 = gain21
        self.gain22 = gain22
    }
    
    public init() {
        
    }
    
}
