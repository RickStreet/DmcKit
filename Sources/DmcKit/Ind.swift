//
//  Ind.swift
//  DMCTuner
//
//  Created by Rick Street on 8/8/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Foundation

/**
 Ind structure
 - Parameters:
 - no:   index of independent (Int)
 - name:   tag name (String)
 - units: tag engineering units (Double)
 
 data from mdl file
 */
class Ind {
    var index: Int
    var name: String
    var shortDescription: String
    var longDescription = ""
    var units: String
    var selected = false
    var typicalMove = 0.0
    
    init(no: Int, name: String, shortDescription: String, units: String) {
        self.index = no
        self.name = name
        self.shortDescription = shortDescription
        self.units = units
    }
}

