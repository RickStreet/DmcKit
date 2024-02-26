//
//  File.swift
//  
//
//  Created by Rick Street on 2/10/20.
//

import Foundation
// import DmcKit

public class Rga {
    
    public var isNumeratorRow1 = true
    public var isNumeratorColumn1 = true


    // Allows modification with variables own setter
    private var _gain11 = Gain()
    private var _gain12 = Gain()
    private var _gain21 = Gain()
    private var _gain22 = Gain()
    private var _setRowGainRatio: Double?
    private var _setColumnGainRatio: Double?

    
    public var gain11: Gain {
        set {
            _gain11 = newValue
            // _gain11.masterIsNumerator = true
        }
        get {
            return _gain11
        }
    }
    public var gain12: Gain {
        set {
            _gain12 = newValue
            // _gain12.masterIsNumerator = false
        }
        get {
            return _gain12
        }
    }
    
    public var gain21: Gain {
        set {
            _gain21 = newValue
            // _gain21.masterIsNumerator = true
        }
        get {
            return _gain21
        }
    }
    public var gain22: Gain {
        set {
            _gain22 = newValue
            // _gain22.masterIsNumerator = false
        }
        get {
            return _gain22
        }
    }
    
    
    public var ind1Index: Int {
        gain11.indIndex
    }
    public var ind2Index: Int {
        gain21.indIndex
    }
    public var dep1Index: Int {
        gain11.depIndex
    }
    public var dep2Index: Int {
        gain12.depIndex
    }
    
    // public var gain11 = 0.0
    // public var gain12 = 0.0
    // public var gain21 = 0.0
    // public var gain22 = 0.0
    
    let zeroTolerence = 9.999999999999999e-13
    
    public var setRowGainRatio: Double? {
        set {
            // print("setRowGainRatio")
            if let value = newValue {
                if isNumeratorRow1 {
                    _setRowGainRatio = value
                    // print("storing value in _setRatio")
                } else {
                    _setRowGainRatio = 1/value
                    // print("storing 1/value in _setRatio")
                }
            } else {
                // print("storing nil to _setRatio")
                _setRowGainRatio = newValue
            }
        }
        get {
            // print("get setRowGainRatio")
            if let value = _setRowGainRatio {
                if isNumeratorRow1 {
                    // print("isNum return _setRatio")
                   return value
                } else {
                    // print("notNum return 1/_setRatio")
                    return 1/value
                }
            } else {
                // print("return nil")
                return _setRowGainRatio // will be nil
            }
        }
    }
    
    
    public var setColumnGainRatio: Double? {
        set {
            // print("set setColumnGainRatio")
            if let value = newValue {
                if isNumeratorColumn1 {
                    _setColumnGainRatio = value
                    // print("storing value in _setRatio")
                } else {
                    _setColumnGainRatio = 1/value
                    // print("storing 1/value in _setRatio")
                }
            } else {
                // print("storing nil to _setRatio")
                _setColumnGainRatio = newValue
            }
        }
        get {
            // print("get setColumnGainRatio")
            if let value = _setColumnGainRatio {
                if isNumeratorColumn1 {
                    // print("isNum return _setRatio")
                   return value
                } else {
                    // print("notNum return 1/_setRatio")
                    return 1/value
                }
            } else {
                // print("return nil")
                return _setColumnGainRatio // will be nil
            }
        }
    }

    public var row1Ratio: Double {
        set {
            setRowGainRatio = newValue
        }
        get {
            if let value = setRowGainRatio {
                return value
            } else {
                if isNumeratorRow1 {
                    return gain11.gain/gain12.gain
                } else {
                    return gain12.gain/gain11.gain
                }
            }
        }
    }
    
    public var row2Ratio: Double {
        set {
            setRowGainRatio = newValue
        }
        get {
            if let value = setRowGainRatio {
                return value
            } else {
                if isNumeratorRow1 {
                    return gain21.gain/gain22.gain
                } else {
                    return gain22.gain/gain12.gain
                }
            }
        }
    }
    
    public var column1Ratio: Double {
        set {
            setColumnGainRatio = newValue
        }
        get {
            if let value = setColumnGainRatio {
                return value
            } else {
                if isNumeratorColumn1 {
                    return gain11.gain/gain21.gain
                } else {
                    return gain21.gain/gain11.gain
                }
            }
        }
    }
    
    public var column2Ratio: Double {
        set {
            setColumnGainRatio = newValue
        }
        get {
            if let value = setColumnGainRatio {
                return value
            } else {
                if isNumeratorColumn1 {
                    return gain12.gain/gain22.gain
                } else {
                    return gain22.gain/gain12.gain
                }
            }
        }
    }
    
    public var oRow1Ratio: Double {
        if isNumeratorRow1 {
            return gain11.originalGain / gain12.originalGain
        } else {
            return gain12.originalGain / gain11.originalGain
        }
    }
    
    public var oRow2Ratio: Double {
        if isNumeratorRow1 {
            return gain21.originalGain / gain22.originalGain
        } else {
            return gain22.originalGain / gain21.originalGain
        }
    }
    
    public var oColumn1Ratio: Double {
        if isNumeratorColumn1 {
            return gain11.originalGain / gain21.originalGain
        } else {
            return gain21.originalGain / gain11.originalGain
        }
    }
    
    public var oColumn2Ratio: Double {
        if isNumeratorColumn1 {
            return gain12.originalGain / gain22.originalGain
        } else {
            return gain22.originalGain / gain12.originalGain
        }
    }
    
    

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
        
        public var originalRga11: Double {
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
    
        
        /*
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
         */
        
        public init(gain11: Gain, gain12: Gain, gain21: Gain, gain22: Gain) {
            self.gain11 = gain11
            self.gain12 = gain12
            self.gain21 = gain21
            self.gain22 = gain22
            // print()
            // print("gain11 \(gain11.gain)")
            // print("gain12 \(gain12.gain)")
            // print("gain21 \(gain21.gain)")
            // print("gain22 \(gain22.gain)")
        }
        
        public init() {
            
        }
        
    }
