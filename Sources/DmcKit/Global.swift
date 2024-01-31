//
//  File.swift
//  
//
//  Created by Rick Street on 9/7/23.
//

import Foundation

enum ConfigSection: String, Codable {
    case gen = "Gen"
    case config = "Config"
    case sub = "Sub"
    case ind = "Ind"
    case dep = "Dep"
    case clp = "CLP"
    case none = "None"
}
