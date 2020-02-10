//
//  File.swift
//  
//
//  Created by Rick Street on 2/10/20.
//

import Foundation

public struct GainRatio {
    let selected1Index: Int
    let selected2Index: Int
    let varIndex: Int
    let varName: String
    let selected1Gain: Gain
    let selected2Gain: Gain
    var selected1Denominator = true
    
    var value: Double {
        if selected1Denominator {
            return selected1Gain.gain / selected2Gain.gain
        } else {
            return selected2Gain.gain / selected1Gain.gain
        }
    }
    
    var originalValue: Double {
        if selected1Denominator {
            return selected1Gain.originalGain / selected2Gain.originalGain
        } else {
            return selected2Gain.originalGain / selected1Gain.originalGain
        }
    }
}
