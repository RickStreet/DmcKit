//
//  Dep.swift
//  DMCTuner
//
//  Created by Rick Street on 8/8/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Foundation

/**
 Dep structure
 - Parameters:
 - no:   index of independent (Int)
 - name:   tag name (String)
 - units: tag engineering units (Double)
 - ramp:        0=not ramp, 1=ramp, 2=pramp (Int)
 
 data from mdl file
 */
class Dep {
    var index: Int
    var name: String
    var shortDescription: String
    var units: String
    var ramp = 0
    var selected = false
    var longDescription = ""
    var gainWindow = 0.0
    
    init(no: Int, name: String, shortDescription: String, units: String, ramp: Int) {
        self.index = no
        self.name = name
        self.shortDescription = shortDescription
        self.units = units
        self.ramp = ramp
    }
}

