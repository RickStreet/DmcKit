//
//  File.swift
//  
//
//  Created by Rick Street on 2/10/20.
//

import Foundation

extension Double {
    var precisionString: String {
        if self == 0 {
            return "0"
        } else {
            var decimals = 0
            let size = Int(log10(abs(self)))
            if size > 0 {
                decimals = 15 - size
            } else {
                decimals = 16 - size
            }
            return  String(format: "%.\(decimals)f", self)
        }
    }
}



extension Double {
    // Rounds the double to 'places' significant digits
    func roundTo(places:Int) -> Double {
        guard self != 0.0 else {
            return 0
        }
        let divisor = pow(10.0, Double(places) - ceil(log10(fabs(self))))
        return (self * divisor).rounded() / divisor
    }
}
