//
//  File.swift
//  
//
//  Created by Rick Street on 2/10/20.
//

import Foundation

public struct GainRatio {
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
        
    }
}
