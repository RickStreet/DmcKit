//
//  Vector.swift
//  Transform
//
//  Created by Rick Street on 12/23/16.
//  Copyright © 2016 Rick Street. All rights reserved.
//

import Foundation
import NSStringKit

public class Vector {
    public var vectorName = ""
    var fileName = ""
    public var ext = ""
    public var units = ""
    public var descrip = ""
    public var version = ""
    public var remark = ""
    public var length = 0 // Total Samples
    public var frequency = 0 // Seconds
    public var startDate = ""
    // var fileName: String?
    var filePath: String?
    var fileURL: URL?
    var fileContents: String?
    var dmcVariable: String = ""
    public var values = [Double]()

    
    public func readVector(url: URL) {
        do {
            fileContents = try String(contentsOfFile: url.path , encoding: .ascii)
            // let lines = fileContents.components(separatedBy: .newlines)
        } catch {
            print(error)
            return
        }
        
        ext = url.pathExtension
        

        
        fileName = url.lastPathComponent
        
        if var contents = fileContents {
            // Windows uses \r\n for each line
            // Mac uses \n
            contents = contents.replace("\r", with: "")
            
            // print("processing lines")
            values.removeAll()
            let lines: [String]
           
            lines = contents.components(separatedBy: "\n")
            
            switch ext.uppercased() {
            case "DPV":
                readDpv(lines: lines)
            case "VEC":
                readVec(lines: lines)
            default:
                // print("Needs to be dpv or vec")
                return
            }
        }
            
    }
    
    func readDpv(lines: [String]) {
        var line: String = ""
        var i: Int = 0
        while  i < lines.count {
            line = lines[i]
            
            // print(line)
            switch line.left(1) {
            case ".":
                // Line contrains variable
                // print(line)
                switch line.substring(with: 1..<4) {
                case "VER":
                    let list = line.quotedWords()
                    // print("ver:" + line)
                    version = list[0]
                    // print(version)
                case "VEC":
                    // print("vec:" + line)
                    let list = line.quotedWords()
                    if list.count >= 4 {
                        vectorName = list[0]
                        ext = list[1]
                        units = list[2]
                        descrip = list[3]
                    }
                    
                case "LEN":
                    // print("len:" + line)
                    let sValue = line.substring(from: 7).trim()
                    // print("len:  \(sValue)")
                    if let n = sValue.integerValue {
                        length = n
                    } else {
                        length = 0
                    }
                    
                case "STA":
                    let list = line.quotedWords()
                    startDate = list[0]
                    // print("start date: \(startDate)")
                    
                    
                case "FRE":
                    // print("fre:" + line)
                    if let  pos = line.index(of: "!")?.predecessor(in: line) {
                        // there is a comment remove it
                        // line = line.substring(to: pos)
                        line = String(line[...pos])
                    }
                    if let start = line.index(of: " ") {
                        // line = line.substring(from: start).trim()
                        line = String(line[start...])
                    }
                    if let n = line.integerValue {
                        frequency = n
                    } else {
                        frequency = 0
                    }
                default:
                    break
                }
            case " ":
                // Line Contains a value
                let sValue = line.trim()
                if let n = sValue.doubleValue {
                    //  if n != -9999.0 {
                        // print(n)
                        values.append(n)
                    // }
                }
                
            default:
                // Lines we dont care about
                break
            }
            i += 1
        }

    }

    func readVec(lines: [String]) {
        // print("Reading vec lines...")
        var line: String = ""
        var i: Int = 0
        while  i < lines.count {
            line = lines[i]
            // print(line)
            
            switch i {
            case 0:
                // print("\(i) \(line)")
                length = line.integerValue ?? 0
                // print("Length: \(length)")
            case 1:
                // print("\(i) \(line)")
                vectorName = line.trim()
                // print("Vector: \(vectorName)")
            case 2:
                // print("\(i)  \(line)")
                descrip = line.substring(with: 0..<42).trim()
                startDate = line.substring(from: 42).trim()
                // print("d:\(descrip):")
                // print("Descrip:  \(descrip)")
                // print("Start Date:  \(startDate.description)")
            case 3:
                // print("\(i)  \(line)")
                units = line.left(25)
                units = units.trim()
                // print("units:  \(units)")
                var freqIn = line.right(20)
                print("freqIn \(freqIn)")
                freqIn = freqIn.left(freqIn.count - 8)
                print("freqIn \(freqIn)")
                let freq = freqIn.doubleValue ?? 0.0
                frequency = Int(freq)
                print("Frequency:  \(frequency)")
                // print()
            case 4 ..< lines.count:
                // Line Contains a value
                let sValue = line.trim()
                if let n = sValue.doubleValue {
                    // if n != -9999.0 {
                        // print(n)
                        values.append(n)
                    // }
                }
            default:
                break
            }
            
            i += 1
        }
    }

    
    public func printData() {
        for number in values {
            print("\(number)")
        }
    }
    
    public init() {
        // Empty
        
    }

    
}

