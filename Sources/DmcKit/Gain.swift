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
public class Gain {
    public var depIndex: Int = 0
    public var indIndex: Int = 0
    public var originalGain: Double = 0
    public var adjustedGain: Double?
    public var adjustType: GainAdjustType = .none
    public var isMasterNumerator = false
    public var masterGain: Gain?

    public var gain: Double  {
        set {
            adjustedGain = newValue
        }
        get {
            if let gain = masterGain, let factor = gainRatio {
                if isMasterNumerator {
                    return gain.gain * factor
                } else {
                    return gain.gain / factor
                }
            }
            if let adjustedGain = adjustedGain {
                return adjustedGain
            }
            return originalGain
        }
    }
    
    public var gainRatio: Double? {
        didSet {
            adjustType = .calculated
        }
    }
    public var percentChange: Double {
        if let aValue = adjustedGain {
            return abs((aValue - originalGain) * 100 / originalGain)
        }
        return 0.0
    }
    
    public func revert() {
        adjustType = .none
        adjustedGain = nil
    }
    
    public var index: Int {
        return depIndex * 1000000 + indIndex
    }
    
    public init(indNo: Int, depNo: Int, originalGain: Double) {
        self.indIndex = indNo
        self.depIndex = depNo
        self.originalGain = originalGain
    }
    
    public init(indNo: Int, depNo: Int, originalGain: Double, adjustedGain: Double?, adjustType: GainAdjustType) {
        self.indIndex = indNo
        self.depIndex = depNo
        self.originalGain = originalGain
        self.adjustedGain = adjustedGain
        self.adjustType = adjustType
    }
    
    public init() {
        self.indIndex = 0
        self.depIndex = 0
        self.originalGain = 1.0
    
    }

}
