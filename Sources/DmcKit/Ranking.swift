//
//  Ranking.swift
//  DMCTuner
//
//  Created by Rick Street on 12/23/19.
//  Copyright © 2019 Rick Street. All rights reserved.
//

import Foundation

public struct Ranking {
    public var index = 0
    public var name = ""
    public var description = ""
    public var rankType = ""
    public var rank = 0
    
    public var sortVar: Int {
        return rank * 1000000 + index
    }
}
