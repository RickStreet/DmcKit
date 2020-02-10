//
//  File.swift
//  
//
//  Created by Rick Street on 2/10/20.
//

import Foundation

public struct Rga {
    var ind1 = 0
    var ind2 = 0
    var dep1 = 0
    var dep2 = 0
    var gain11 = 0.0
    var gain12 = 0.0
    var gain21 = 0.0
    var gain22 = 0.0
    
    let zeroTolerence = 6.0e-13
    
    var rga11: Double {
        let denominator = gain11 * gain22 - gain12 * gain21
        if abs(denominator) < zeroTolerence {
            return 0.0
        }
        return gain11 * gain22 / denominator
    }
    
    var rga: Double {
        if rga11 == 0 {
            return 0.0
        }
        if rga11 > 1.0 {
            return rga11
        } else {
            return 1.0 - rga11
        }
    }
}
