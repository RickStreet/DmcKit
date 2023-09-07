//
//  param.swift
//  DMCDictRead
//
//  Created by Rick Street on 10/29/18.
//  Copyright © 2018 Rick Street. All rights reserved.
//
// Used for Dictionary to hold param info

import Foundation

class DmcParam: Codable, Equatable {
    static func == (lhs: DmcParam, rhs: DmcParam) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name = ""
    var description = ""
    var section = ConfigSection.none
    var dataType = ""
    var tune = false
    var limit = false
    var hide = false
    var notes = ""
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case description = "description"
        case dataType = "data_type"
        case section = "section"
        case tune = "tune"
        case limit = "limit"
        case hide = "hide"
        case notes = "notes"
    }



}
