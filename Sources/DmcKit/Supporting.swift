//
//  Supporting.swift
//  Transform
//
//  Created by Rick Street on 12/4/16.
//  Copyright © 2016 Rick Street. All rights reserved.
//

import Cocoa
import StringKit

let lightYellow = NSColor(red: 255.0/255.0, green: 255.0/255.0, blue: 198.0/255.0, alpha: 1.0)
let darkGrey = NSColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
let lightGrey = NSColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)

let pink = NSColor(red: 255.0/255.0, green: 231.0/255.0, blue: 235.0/255.0, alpha: 1.0)
let darkRed = NSColor(red: 137.0/255.0, green: 33.0/255.0, blue: 16.0/255.0, alpha: 1.0)
let navy = NSColor(red: 4.0/255.0, green: 30.0/255.0, blue: 141.0/255.0, alpha: 1.0)
let forestGreen = NSColor(red: 0.0/255.0, green: 153.0/255.0, blue: 76.0/255.0, alpha: 1.0)
let black = NSColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)

/*
public final class SingletonDMController {
    static let sharedInstance = DMController()
    private init() {} //This prevents others from using the default '()' initializer for this class.
}
*/

// var dmcController = TheOneAndOnlyDmcController.sharedInstance


public func roundTo(value: Double, digits: Int) -> Double {
    let sign: Double
    let order: Double
    let nDigits = Double(digits)
    if value < 0.0 {
        sign = -1.0
    } else {
        sign = 1.0
    }
    var number = abs(value)
    if number < 1.0 {
        order = floor(log10(number))
        let totalDigits = order - nDigits + 1.0
        var tempNumber = number / pow(10.0, totalDigits)
        tempNumber = round(tempNumber)
        number = tempNumber * pow(10.0, totalDigits)
    } else {
        order = ceil(log10(number))
        let totalDigits = order - nDigits
        var tempNumber = number / pow(10.0, totalDigits)
        tempNumber = round(tempNumber)
        number = tempNumber * pow(10.0, totalDigits)
    }
    return number * sign
}

func cutLine(_ line: String) -> String {
    var firstLine = true
    var cutLine = ""
    var longLine = line
    while longLine.count > 115 {
        if !firstLine {
            cutLine += "\""
        }
        firstLine = false
        cutLine += longLine.left(115) + "\"---\r\n"
        longLine = longLine.substring(from: 115)
    }
    if !firstLine {
        cutLine += "\""
    }
    cutLine += longLine
    return cutLine
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


