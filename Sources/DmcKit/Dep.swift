//
//  Dep.swift
//  DMCTuner
//
//  Created by Rick Street on 8/8/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Foundation

/**
 Dep class
 - Parameters:
 - no:   index of independent (Int)
 - name:   tag name (String)
 - units: tag engineering units (Double)
 - ramp:        0=not ramp, 1=ramp, 2=pramp (Int)
 
 data from mdl file
 */
public class Dep {
    public var index: Int
    public var name: String
    public var shortDescription: String
    public var units: String
    public var ramp = 0
    public var selected = false // used for ratios
    public var excluded = false // used to exclude from rga
    public var longDescription = ""
    public var gainWindow = 0.0
    public var maxAbsGain = 0.0

    
    public init(no: Int, name: String, shortDescription: String, units: String, ramp: Int) {
        self.index = no
        self.name = name
        self.shortDescription = shortDescription
        self.units = units
        self.ramp = ramp
    }

}

