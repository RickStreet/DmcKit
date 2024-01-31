//
//  File.swift
//  
//
//  Created by Rick Street on 2/10/20.
//

import Foundation

public class GainRatio {
    public let selected1Index: Int
    public let selected2Index: Int
    public let varIndex: Int
    public let varName: String
    public let selected1Gain: Gain
    public let selected2Gain: Gain
    public var selected1Denominator = true
    
    public var value: Double {
        if selected1Denominator {
            return selected1Gain.gain / selected2Gain.gain
        } else {
            return selected2Gain.gain / selected1Gain.gain
        }
    }
    
    public var originalValue: Double {
        if selected1Denominator {
            return selected1Gain.originalGain / selected2Gain.originalGain
        } else {
            return selected2Gain.originalGain / selected1Gain.originalGain
        }
    }
    
    public init() {
        selected1Index = 0
        selected2Index = 0
        selected1Gain = Gain(indNo: 0, depNo: 0, originalGain: 0)
        selected2Gain = Gain(indNo: 0, depNo: 0, originalGain: 0)
        varIndex = 0
        varName = ""
        
    }
    
    public init(selected1Index: Int, selected2Index: Int, varIndex: Int, varName: String, selected1Gain: Gain, selected2Gain: Gain, selected1Denominator: Bool) {
        self.selected1Index = selected1Index
        self.selected2Index = selected2Index
        self.varIndex = varIndex
        self.varName = varName
        self.selected1Gain = selected1Gain
        self.selected2Gain = selected2Gain
        self.selected1Denominator = selected1Denominator
    }
}
