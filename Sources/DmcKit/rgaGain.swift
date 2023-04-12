//
//  File.swift
//  
//
//  Created by Rick Street on 4/12/23.
//

import Foundation

class RGAGain {
    public var depIndex: Int = 0
    public var indIndex: Int = 0
    public var originalGain: Double = 0
    
    public var adjustType: GainAdjustType = .none
    public var factor: Double? {
        didSet {
            adjustType = .adjusted
        }
    }
    public var masterGain: RGAGain? {
        didSet {
            masterGain?.adjustType = .set
        }
    }

    public var gain: Double {
        if let gain = masterGain, let factor = factor {
            return gain.originalGain * factor
        } else {
            return originalGain
        }
    }


}
