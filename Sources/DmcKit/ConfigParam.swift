//
//  ConfigParam.swift
//  DMCTuner
//
//  Created by Rick Street on 8/7/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Foundation

/**
 ConfigParam
 - Parameters:
 - id:      Order in Config File (Int)
 - section  Section containing param
 - name:   Param name (String)
 - keyWord: Build, Constant, Write... (String)
 - type:    Type: String, Double... (String)
 - value:   Parm value  (String)
 - entity:  Connection to DCS (String)
 
 params from IQ file
 */
class ConfigParam {
    var id = 0       // Order in file
    var index = 0    // Calc Index
    // var section = Section() // Section
    var name = ""   // Param name
    var keyWord = "" // Build, Constant, Write...
    var type = ""   // Type: String, Double...
    // var value: String = ""  // Parm value
    // var pValue = ""
    // var firstTime = true
    var originalValue = ""
    var updatedValue: String?
    
    var value = "" {
        didSet {
            if type == "R4" || type == "I4" {
                value = value.replace(",", with: "")
            }
        }
    }
    
    var doubleValue: Double {
        if let doubleValue = Double(value) {
            return doubleValue
        } else {
            return 0.0
        }
    }
    
    var intValue: Int {
        let newValue = value.replace(".", with: "")
        if let intValue = Int(newValue) {
            return intValue
        } else {
            return 0
        }
    }


    var entityDevice = ""
    var entityUnit = ""
    var dcsTag = ""
    var entitySource = ""
    var entityFormatCode = ""
    
    // ""::"DC6_OH_90.APC_CALC.PV":DBVL:
    var entity: String = "" {  // Connection to DCS
        didSet {
            if entity == "" {
                return
            }
            // print("entity set!!!!!!!!!!!!!!!!!!!!!")
            var tLine = entity.substring(from: 1)
            if !tLine.hasPrefix("\"") {
                // Has Device
                if let at = tLine.indexBefore("\"") {
                    entityDevice = String(tLine[...at])
                }
            }
            if let at = tLine.indexAfter(":") {
                tLine = String(tLine[at...])
                if !tLine.hasPrefix(":") {
                    // Has unit
                    if let at = tLine.indexBefore(":") {
                        entityUnit = String(tLine[...at])
                    }
                }
            }
            
            if let at = tLine.indexAfter("\"") {
                tLine = String(tLine[at...])
                if !tLine.hasPrefix("\"") {
                    // Have DSC Tag
                    if let at = tLine.indexBefore("\"") {
                        dcsTag =  String(tLine[...at])
                    }
                }
            }
            
            if let at = tLine.indexAfter(":") {
                tLine = String(tLine[at...])
                if !tLine.hasPrefix(":") {
                    // Has source
                    if let at = tLine.indexBefore(":") {
                        entitySource = String(tLine[...at])
                    }
                }
            }
            
            /*
            if let at = tLine.indexAfter(":") {
                tLine = String(tLine[at...])
                if tLine.count > 0 {
                    // Have format code
                    entityFormatCode = String(tLine[at...])
                }
            }
            */
        }
    }
    
    var commentType = ""  // C = Comment  G = Get   P = Put
    
    /*
    var line: String {
        return cutLine("." + name + "~~~" + keyWord + "~~~" + type + "~~~" + value + "~~~" + entity)
    }
    */
    
    init(id: Int, name: String, keyWord: String, type: String, value: String, entity: String) {
        // self.section = section
        self.id = id
        self.name = name
        self.keyWord = keyWord
        self.type = type
        self.value = value
        self.entity = entity
    }

    init(id: Int, name: String, keyWord: String, type: String, value: String) {
        // self.section = section
        self.id = id
        self.name = name
        self.keyWord = keyWord
        self.type = type
        self.value = value
        self.entity = ""
    }

    
    init() {
        // Empty ConfigParam
        
    }
}

