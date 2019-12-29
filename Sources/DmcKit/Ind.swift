//
//  Ind.swift
//  DMCTuner
//
//  Created by Rick Street on 8/8/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Foundation

/**
 Ind class
 - Parameters:
 - no:   index of independent (Int)
 - name:   tag name (String)
 - units: tag engineering units (Double)
 
 data from mdl file
 */
public class Ind {
    public var index: Int
    public var name: String
    public var shortDescription: String
    public var longDescription = ""
    public var units: String
    public var selected = false
    public var typicalMove = 0.0
    
    public init(no: Int, name: String, shortDescription: String, units: String) {
        self.index = no
        self.name = name
        self.shortDescription = shortDescription
        self.units = units
    }
}

