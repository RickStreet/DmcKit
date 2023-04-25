//
//  File.swift
//  
//
//  Created by Rick Street on 2/10/20.
//

import Foundation

public class Rga {
    private var _gain11 = Gain()
    private var _gain12 = Gain()
    private var _gain21 = Gain()
    private var _gain22 = Gain()
    
    public var gain11: Gain {
        set {
            _gain11 = newValue
            _gain11.isMasterNumerator = true
        }
        get {
            return _gain11
        }
    }
    public var gain12: Gain {
        set {
            _gain12 = newValue
            _gain12.isMasterNumerator = false
        }
        get {
            return _gain12
        }
    }
    
    public var gain21: Gain {
        set {
            _gain21 = newValue
            _gain21.isMasterNumerator = true
        }
        get {
            return _gain21
        }
    }
    public var gain22: Gain {
        set {
            _gain22 = newValue
            _gain22.isMasterNumerator = false
        }
        get {
            return _gain22
        }
    }

    
    public var ind1 = 0
    public var ind2 = 0
    public var dep1 = 0
    public var dep2 = 0
    // public var gain11 = 0.0
    // public var gain12 = 0.0
    // public var gain21 = 0.0
    // public var gain22 = 0.0
    
    let zeroTolerence = 9.999999999999999e-13
    
    public var rowGainRatio: Double?
    public var columnGainRatio: Double?
    
    public var rga11: Double {
        let denominator = gain11.gain * gain22.gain - gain12.gain * gain21.gain
        if abs(denominator) < zeroTolerence {
            return 0.0
        }
        return gain11.gain * gain22.gain / denominator
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
    
    var originalRga11: Double {
        let denominator = gain11.originalGain * gain22.originalGain - gain12.originalGain * gain21.originalGain
        if abs(denominator) < zeroTolerence {
            return 0.0
        }
        return gain11.originalGain * gain22.originalGain / denominator
    }
    
    public var originalRga: Double {
        if originalRga11 == 0 {
            return 0.0
        }
        if originalRga11 > 1.0 {
            return originalRga11
        } else {
            return 1.0 - originalRga11
        }
    }

    
    public init(ind1: Int, ind2: Int, dep1: Int, dep2: Int, gain11: Gain, gain12: Gain, gain21: Gain, gain22: Gain) {
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
