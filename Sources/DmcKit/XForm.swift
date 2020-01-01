//
//  XForm.swift
//  DMCTuner
//
//  Created by Rick Street on 12/2/19.
//  Copyright © 2019 Rick Street. All rights reserved.
//

import Foundation
import StringKit

public class XForm {
    public var type = TransformType.none
    public var params = [String]()
    public var eqText = ""
    public var xFormPoints = [(x: Double, y: Double)]()
    
    public func parse(_ string: String) {
        params = string.components(separatedBy: " ")
        if params.count > 0 {
            switch params[0] {
            case "LINEAR":
                type = .linear
                
                eqText = "Linear(shift: \(params[1])   alpha: \(params[2])"
                if params.count > 3 {
                    eqText += "   low: \(params[3])"
                }
                if params.count > 4 {
                    eqText += "   high: \(params[4])"
                }
                eqText += ")"

            case "LOG":
                type =  .ln
                eqText = "ln()"
            case "LOG10":
                type =  .log
                eqText = "log()"
            case "MLOG":
                type =  .mLn
                if params.count > 1 {
                    eqText = "mLn(shift: \(params[1])"
                }
                if params.count > 2 {
                    eqText += "   low clamp: \(params[2])"
                }
                if params.count > 3 {
                    eqText += "   trans: \(params[3])"
                }
                eqText += ")"
            case "MLOG10":
                type =  .mLog
                if params.count > 1 {
                    eqText = "mLog(shift: \(params[1])"
                }
                if params.count > 2 {
                    eqText += "   low clamp: \(params[2])"
                }
                if params.count > 3 {
                    eqText += "   trans: \(params[3])"
                }
                eqText += ")"
            case "PARABOLIC":
                type =  .parabolic
                eqText = "Parabolic(shift: \(params[1])   alpha: \(params[2])"
                if params.count > 3 {
                    eqText += "   lo: \(params[3])"
                }
                if params.count > 4 {
                    eqText += "   hi: \(params[4])"
                }
                eqText += ")"

            case "PWLN":
                type =  .pwl
                getXFormPoints()
                eqText = ""
            case "SHIFTERATEPOWER":
                type =  .shiftRatePower
                eqText = "ShiftRatePower(shift: \(params[1])   rate: \(params[2])   power: \(params[3]))"

            default:
                type =  .none
                eqText = ""
            }
        } else {
            type =  .none
            eqText = ""
        }
    }
    
    func getXFormPoints() {
        print()
        print("Getting Transform points..........")
        // print(param)
        // if param.hasPrefix("PWLN") {
        var i = 2
        while i < params.count {
            print(params[i], params[i+1])
            if let x = params[i].doubleValue, let y = params[i+1].doubleValue {
                // print(comps[i], comps[i+1])
                print(x, y)
                xFormPoints.append((x: x, y: y))
            }
            i += 2
        }
        print()
        print("Points:")
        for point in xFormPoints {
            print("(\(point.x), \(point.y)")
        }
        print()
        // } else {
        print("Not PWL")
        // }
        return
    }
    
    
}
