//
//  Ranking.swift
//  DMCTuner
//
//  Created by Rick Street on 12/23/19.
//  Copyright © 2019 Rick Street. All rights reserved.
//

import Foundation

struct Ranking {
    var index = 0
    var name = ""
    var description = ""
    var rankType = ""
    var rank = 0
    
    var sortVar: Int {
        return rank * 1000000 + index
    }
}
