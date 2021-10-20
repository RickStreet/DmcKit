//
//  IQSection.swift
//  IQReporter
//
//  Created by Rick Street on 7/17/19.
//  Copyright © 2019 Rick Street. All rights reserved.
//

import Foundation
import StringKit
import FileKit

// IQ General Section Type
@dynamicMemberLookup
public class Section: Equatable {
    public static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.name == rhs.name
    }
    
    
    public var id = 0
    public var index = 0
    public var name = ""
    var sectionName = ""  // section header in ccf [xxx]
    public var longDescription = ""
    public var shortDescription = ""
    public var selected = false
    public var targetGainWindow = 0.0 // used for display
    public var select = true // used to select sections
    public var type = "" // used to build interface points
    
    public var note = ""
    
    public var heading: String {
        return "\(index + 1).  \(name),  \(shortDescription)"
    }
    
    // used to get mult params for section
    public var params = [ConfigParam]() /* {
     didSet {
     if let param = params.last {
     properties.updateValue(param, forKey: param.name.lowercased())
     // print("added \(param.name.lowercased()) to properties")
     }
     }
     } */
    // dictionary used to add and update parameters/params
    public var properties = [String : ConfigParam]()
    
    public subscript(dynamicMember member: String) -> ConfigParam {
        let properties = self.properties
        return properties[member, default: ConfigParam(id: -1, name: "nil", keyWord: "nil", type: "nil", value: "nil")]
    }
    
    public func append(_ param: ConfigParam) {
        let newParam = properties.updateValue(param, forKey: param.name.lowercased())
        if newParam == nil {
            params.append(param)
        }
    }
    
    public func addOrChange(param: ConfigParam) {
        let currentParams = params.filter{$0.name == param.name}
        if currentParams.count > 0 {
            // Param already exists
            
            if let currentParam = currentParams.first {
                // Keep current value if template value is ?
                currentParam.dcsTag = param.dcsTag
                currentParam.entity = param.entity
                currentParam.keyWord = param.keyWord
                currentParam.type = param.type
                if !param.value.contains(target: "?") { // If value contains ?, don't replace
                    currentParam.value = param.value
                }
            }
            
        } else {
            // Param doees not exist, append
            var value = ""
            if param.value.contains(target: "?") {
                value = ""
            } else {
                value = param.value
            }
            let newParam = ConfigParam(id: params.count,
                                       name: param.name,
                                       keyWord: param.keyWord,
                                       type: param.type,
                                       value: value,
                                       entity: param.entity)
            append(newParam)
        }
    }
    
    
    public init() {}
    
}

