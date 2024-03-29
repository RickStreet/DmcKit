//
//  GMult.swift
//  DMCRead
//
//  Created by Richard Street on 11/11/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation

public struct GMult: Equatable {
    public var indIndex = 0
    public var depIndex = 0
    public var value = 0.0
    
    public static func ==(lhs: GMult, rhs: GMult) -> Bool {
        return lhs.indIndex == rhs.indIndex && lhs.depIndex == rhs.depIndex && lhs.value == rhs.value
    }
    
    public init(indIndex: Int, depIndex: Int, value: Double) {
        self.indIndex = indIndex
        self.depIndex = depIndex
        self.value = value
    }

}
