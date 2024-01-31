//
//  PwlVector.swift
//  Transform
//
//  Created by Rick Street on 6/11/21.
//  Copyright © 2021 Rick Street. All rights reserved.
//

import Foundation
// import FileKit
import NSStringKit

public class PwlTransform {
    public var tagName = ""
    public var tagExt = ""
    public var transformTagName = ""
    public var transformExt = "Transform"
    public var description = ""
    public var units = ""
    public var ext = "PWL"
    public var scaled = true
    
    var xLo = 0.0
    var xHi = 100.0
    var y0 = 0.0
    var factor = 1.0
    var bias = 0.0
    
    public var points = [(x: Double, y: Double)]()
    
    public var unscaledPoints: [(x: Double, y: Double)] {
        return points.sorted(){$0.0 < $1.0}
    }

    
    public var scaledPoints:  [(x: Double, y: Double)] {
        var sPoints = [(x: Double, y: Double)]()
        guard sPoints.count > 1 else {
            return sPoints
        }
        let points = unscaledPoints
        let n = points.count - 1
        
        // extrapulate to y0
        let slopeLow = (points[1].y - points[0].y) / (points[1].x - points[0].x)
        print("delta y low \(points[1].y - points[0].y)")
        print("slopeLow \(slopeLow)")
        // let ymin = points[0].y - slopeLow * (points[0].x - xLo)
        let startPoint = (x: xLo, y: points[0].y - slopeLow * (points[0].x - xLo))
        print("startPoint \(startPoint)")

        // extrapulate y to xHi
        let slopeHigh = (points[n].y - points[n - 1].y) / (points[n].x - points[n - 1].x)
        print("slopeHigh \(slopeHigh)")
        let endPoint = (x: xHi, y: points[n].y + slopeHigh * (xHi - points[n].x))
        print("endPoint \(endPoint)")
        print("delta y hi \(points[n].y - points[n - 1].y)")
        
        let deltaY = endPoint.y - startPoint.y
        factor = 100.0 / deltaY
        bias = startPoint.y - y0
        print("deltaY \(deltaY)  factor \(factor)")


        let scaledStartPoint = scalePoint(startPoint)
        let scaledEndPoint = scalePoint(endPoint)

        sPoints.append(scaledStartPoint)
        for i in 1 ..< points.count - 1 {
            sPoints.append(scalePoint(points[i]))
        }
        sPoints.append(scaledEndPoint)

        return sPoints
    }
    
    public var pwlConfigParam: ConfigParam {
        let configParam = ConfigParam()
        var pwlValue = "PWLN \(points.count)"
        if scaled {
            for point in scaledPoints {
                pwlValue += " \(point.x) \(point.y)"
            }
        } else {
            for point in unscaledPoints {
                pwlValue += " \(point.x) \(point.y)"
            }
        }
        configParam.name = "xform"
        configParam.keyWord = "XFORM"
        configParam.type = "CH(\(pwlValue.count))"
        configParam.value = pwlValue
        
        return configParam
    }
    
    
    public func scalePoint(_ point: (x: Double, y: Double)) -> (x: Double, y: Double) {
        let scaledPoint = (point.x, (point.y - bias) * factor)
        return scaledPoint
    }
        
    
    public func saveVector(url: URL) {
        var contents = "!#=====DMCplus===DMCplus===DMCplus===DMCplus===DMCplus===DMCplus===DMCplus=====#" + "\r\n"
        contents += "!# This file contains the information of DMCplus Model vector. Do not modify  #" + "\r\n"
        contents += "!#=====DMCplus===DMCplus===DMCplus===DMCplus===DMCplus===DMCplus===DMCplus=====#" + "\r\n"
        contents += ".VERsion   \"1\"" + "\r\n"
        contents += ".VECtor   \"" + transformTagName + "\"  \"\(transformExt)\"  \"" + units + "\"  \"" + description + "\"" + "\r\n"
        contents += ".REMark   \"Generated by Vector Tool - rhs\"" + "\r\n"
        contents += ".TRAnsform   " + "8" + "   ! Piece-Wise Linear Transform\r\n"
        
        var j = 0
        if scaled {
            for (i, point) in scaledPoints.enumerated() {
                j += 1
                contents += ".PARameter   \"X\(i+1):\"  " + String(format: "%.3f", point.x) + "\r\n"
                contents += ".PARameter   \"Y\(i+1):\"  " + String(format: "%.3f", point.y) + "\r\n"
            }
        } else {
            for (i, point) in unscaledPoints.enumerated() {
                j += 1
                contents += ".PARameter   \"X\(i+1):\"  " + String(format: "%.3f", point.x) + "\r\n"
                contents += ".PARameter   \"Y\(i+1):\"  " + String(format: "%.3f", point.y) + "\r\n"
            }
        }
        contents += ".FORmula    \"Equals\"  \"vector\"  \"\"\r\n"
        contents += ".VARiable    \"vector\"  \"" + tagName + " [\(tagExt)]\"\r\n"
        
        contents += ".END\n\r"
        do {
            try contents.write(to: url, atomically: false, encoding: String.Encoding.ascii)
        }
        catch {
            /* error handling here */
            print("error")
        }
    }
    
    /// Load dpv Vector
    /// - Parameter url: dpv vector url
    public func readVector(url: URL) {
        var fileContents = ""
        do {
            fileContents = try String(contentsOfFile: url.path , encoding: .ascii)
            // let lines = fileContents.components(separatedBy: .newlines)
        } catch {
            print(error)
            return
        }
        points.removeAll()
        var lines = [String]()
        lines = fileContents.components(separatedBy: "\n")
        var x = 0.0
        for line in lines {
            switch line.left(4) {
            case ".PAR":
                if let start = line.index(after: "\"  ") {
                    let param = line[start...]
                    // print("param \(param)")
                    if let value = String(param).doubleValue {
                        print("value \(value)")
                        if line.contains(target: "X") {
                            x = value
                        }
                        if line.contains(target: "Y") {
                            points.append((x: x, y: value))
                        }
                    }
                }
            case ".VEC":
                print()
                print("Vec:")
                let values = line.quotedWords()
                transformTagName = values[0]
                print("t tagName \(tagName)")
                transformExt = values[1]
                print("t tagExt \(tagExt) ")
                units = values[2]
                print("units \(units)")
                description = values[3]
                print("descrip \(description)")
                print()
            case ".VAR":
                print()
                print("Var:")
                let values = line.quotedWords()
                let value = values[1]
                print("value \(value)")
                if let tagEnd = value.index(before: " ") {
                    tagName = String(value[...tagEnd])
                    print("tagName \(tagName)")
                }
                if let extStart = value.index(after: "[") {
                    tagExt = String(value[extStart ..< value.endIndex.advance(by: -1, for: value)])
                    print("tagExt \(tagExt)")
                }
                print()
            default:
                break
            }
        }
        print()
        for point in points {
            print(point)
        }
    }
    
    public init(points: [(x: Double, y: Double)]) {
        self.points = points
    }

    
    public init(){}
}
