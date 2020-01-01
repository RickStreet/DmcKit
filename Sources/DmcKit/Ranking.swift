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
    public init(index: Int, name: String, description: String, rankType: String, rank: Int) {
        self.index =  index
        self.name = name
        self.description = description
        self.rankType = rankType
        self.rank = rank
    }

}
