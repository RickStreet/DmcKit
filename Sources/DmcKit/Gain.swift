//
//  Gain.swift
//  DmcRga
//
//  Created by Rick Street on 4/18/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Foundation

/**
 Gain class
 - Parameters:
 - depNo:   index of dependent (Int)
 - indNo:   index of independent (Int)
 - gain:    gain for curve (Double)
 
 data from mdl file
 */
class Gain {
    var depIndex: Int = 0
    var indIndex: Int = 0
    var originalGain: Double = 0
    var adjustedGain: Double?
    var adjustType: GainAdjustType = .none
    var gain: Double {
        if let g = adjustedGain {
            return g
        } else {
            return originalGain
        }
    }
    var percentChange: Double {
        if let aValue = adjustedGain {
            return abs((aValue - originalGain) * 100 / originalGain)
        }
        return 0.0
    }
    var index: Int {
        return depIndex * 1000000 + indIndex
    }
    
    init(indNo: Int, depNo: Int, originalGain: Double) {
        self.indIndex = indNo
        self.depIndex = depNo
        self.originalGain = originalGain
    }
    
    init(indNo: Int, depNo: Int, originalGain: Double, adjustedGain: Double?, adjustType: GainAdjustType) {
        self.indIndex = indNo
        self.depIndex = depNo
        self.originalGain = originalGain
        self.adjustedGain = adjustedGain
        self.adjustType = adjustType
    }
}
