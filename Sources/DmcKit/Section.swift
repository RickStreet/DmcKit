//
//  IQSection.swift
//  IQReporter
//
//  Created by Rick Street on 7/17/19.
//  Copyright © 2019 Rick Street. All rights reserved.
//

import Foundation
import StringKit

// IQ General Section Type
@dynamicMemberLookup
public class Section {
    public var id = 0
    public var index = 0
    public var name = ""
    var sectionName = ""  // section header in ccf [xxx]
    public var longDescription = ""
    public var shortDescription = ""
    public var selected = false
    public var targetGainWindow = 0.0 // used for display
    public var select = true // used to select sections
    
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
    
    /*
    func changeValue(paramName: String, newValue: String) {
        if let param = properties[paramName] {
            switch param.type {
            case "R4", "I4":
                let cValue = newValue
                param.value = cValue.replace(",", with: "")
            default:
                param.value = newValue
            }
            print("changed \(param.name) to \(param.value)")
        }
    }
    */
    
    
    public init() {}

}

