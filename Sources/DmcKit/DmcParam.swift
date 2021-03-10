//
//  param.swift
//  DMCDictRead
//
//  Created by Rick Street on 10/29/18.
//  Copyright © 2018 Rick Street. All rights reserved.
//
// Used for Dictionary to hold param info

import Foundation

public class DmcParam: Codable, Equatable {
    public static func == (lhs: DmcParam, rhs: DmcParam) -> Bool {
        return lhs.name == rhs.name
    }
    
    
    public var name = ""
    public var description = ""
    public var type = ""
    public var cat = ""
    public var tune = false
    public var limit = false
    public var hide = false
    public var notes = ""
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case description = "description"
        case type = "type"
        case cat = "cat"
        case tune = "tune"
        case limit = "limit"
        case hide = "hide"
        case notes = "notes"
    }
    
    public init() {}
}
