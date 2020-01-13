//
//  Config.swift
//  DMCRead
//
//  Created by Richard Street on 11/6/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation
import StringKit


public class Config {
    
    var contents = "" // Used to store the file contents
    var url = URL(fileURLWithPath: "")
    public var controllerName = ""
    public var baseName = ""
    var lines = [String]()
    var linesIn = [String]()
    var sections = [Section]()
    public var inds = [Section]()
    public var mvs = [Section]()
    public var ffs = [Section]()
    public var cvs = [Section]()
    public var subs = [Section]()
    public var calcParams = [ConfigParam]()
    public var calcSection = Section()
    public var configSection = Section()
    public var generalSection = Section()
    public var gMults = [GMult]()
    public var modelName = ""
    public var configURL = URL.init(fileURLWithPath: "")
    var cvIndex = 0
    var mvIndex = 0
    var ffIndex = 0
    var indIndex = 0
    var subIndex = 0
    var calcIndex = 0
    
    public var paramCount = 0
    public var sectionCount = 0
    public var calcCount = 0
    
    func clear() {
        lines.removeAll()
        sections.removeAll()
        inds.removeAll()
        mvs.removeAll()
        ffs.removeAll()
        cvs.removeAll()
        subs.removeAll()
        gMults.removeAll()
        cvIndex = 0
        mvIndex = 0
        ffIndex = 0
        indIndex = 0
        subIndex = 0
        calcIndex = 0
        
    }
    
    public func readCCF(url: URL) {
        clear()
        do {
            // Read the file contents
            contents = try String(contentsOf: url, encoding: .ascii)
        } catch let error as NSError {
            print("Failed reading from URL: \(url.path), Error: " + error.localizedDescription)
            return
        }
        // print(url.path)
        configURL = url
        var temp = url
        temp.deletePathExtension()
        baseName = temp.lastPathComponent
        // print("baseName: \(baseName)")
        controllerName = url.lastPathComponent
        // print(contents)
        assembleLines()
        parseLines()
    }
    
    func assembleLines() {
        let linesIn = contents.components(separatedBy: "\r\n")
        if !linesIn[0].hasPrefix("CCF") {
            return
        }
        // var lines = [String]()
        // print("assembling lines...")
        // print("**************************************************************")
        // var continuation = false
        // var j = 0
        
        var text = ""
        // var newLine = ""
        
        for line in linesIn {
            // print(line)
            if !(line.right(4) == "\"---" || line.hasPrefix("\"")) {
                // normal line
                // print(line)
                lines.append(line)
                // continuation = false
            }
            
            if !line.hasPrefix("\"") && line.right(4) == "\"---" {
                // first line in continuation
                // print("**********************")
                // print("first")
                text = line.substring(to: line.count - 5)
                // print()
                // print(line)
                // print(text)
                // print()
                // continuation = true
            }
            
            if line.hasPrefix("\"") && line.right(4) == "\"---" {
                // middle line in continuation
                // print("middle")
                text += line.substring(with: 1..<(line.count - 4))
                // print(line)
                // print(text)
            }
            
            if  line.hasPrefix("\"") && !(line.right(4) == "\"---") {
                // last continuation line
                // print("last")
                text += line.substring(from: 1)
                // print(line)
                // print(text)
                // print()
                
                lines.append(text)
                // continuation = false
            }
        }
    }
    
    func getVarName(sectionText: String) -> String {
        return sectionText.substring(with: 5..<(sectionText.count - 1))
    }
    
    func getSectionName(sectionText: String) -> String {
        return sectionText.substring(with: 1..<(sectionText.count - 1))
    }
    
    func parseLines() {
        // var isVar = false
        var section = Section()
        var sectionID = 0
        var paramID = 0
        for line in lines {
            // isVar = false
            if line.hasPrefix("[") {
                // section
                section = Section()
                section.id = sectionID
                sectionID += 1
                section.sectionName = line
                // if line.hasPrefix("[") {
                
                let prefix = line.left(5)
                switch prefix {
                case "[IND:":
                    // Ind
                    // isVar = true
                    section.index = indIndex
                    indIndex += 1
                    section.name = getVarName(sectionText: line)
                    inds.append(section)
                // print("Ind: \(section.name)")
                case "[DEP:":
                    // Dep
                    section.name = getVarName(sectionText: line)
                    section.index = cvIndex
                    cvIndex += 1
                    cvs.append(section)
                    // print("Dep: \(section.name)")
                // isVar = true
                case "[SUB:]":
                    section.index = subIndex
                    subIndex += 1
                    section.name = getVarName(sectionText: line)
                    subs.append(section)
                case "[CONF":
                    section.name = getSectionName(sectionText: line)
                    configSection = section
                case "[GENE]":
                    section.name = getSectionName(sectionText: line)
                    generalSection = section
                case "[CALC":
                    section.name = getSectionName(sectionText: line)
                    calcSection = section
                default:
                    if !line.hasPrefix(".") {
                        sections.append(section)
                    }
                }
            }
            if line.hasPrefix(".") {
                // parameter
                let params = line.substring(from: 1).components(separatedBy: "~~~")
                //let configParam = ConfigParam()
                //configParam.id = paramID
                //aramID += 1
                let name = params[0]
                
                // configParam.name = name
                // configParam.keyWord = params[1]
                // configParam.type = params[2]
                // configParam.value = params[3]
                let configParam = ConfigParam(id: paramID, name: name, keyWord: params[1], type: params[2], value: params[3])
                paramID += 1
                
                if params.count > 4 {
                    configParam.entity = params[4]
                } else {
                    configParam.entity = ""
                }
                
                /*
                 // ***********************************
                 if section.name == "66AI1043PVF" {
                 print(params)
                 if params[2] == "R4" {
                 print(Double(params[3]) ?? "nil")
                 print()
                 }
                 }
                 */
                
                
                //if section.name == "CALC" {
                if !(name.hasPrefix("CALC") || name.hasPrefix("COMMENT")) && section.name == "CALC" {
                    calcParams.append(configParam)
                } else {
                    if section.name == "CALC" {
                        configParam.index = calcIndex
                        calcIndex += 1
                    }
                    section.append(configParam)
                }
                // }
                
                
                
            }
            
        } // End for
        sectionCount = sectionID
        paramCount = paramID
        calcCount = calcIndex
        modelName = configSection.mdlnam.value
        
        /*
         print()
         print("Subs:")
         for sub in subs {
         print(sub)
         }
         print()
         print("Cvs:")
         */
        
        for cv in cvs {
            cv.shortDescription = cv.descdep.value
            // print(cv.name, cv.shortDescription)
        }
        for ind in inds {
            let mults = ind.params.filter{$0.name.left(5) == "GMULT"}
            for mult in mults {
                if var depIndex = mult.name.substring(from: 5).integerValue {
                    depIndex -= 1  // Aspen indicies start with 1
                    // print(depIndex, mult.doubleValue)
                    let gmult = GMult(indIndex: ind.index, depIndex: depIndex, value: mult.doubleValue)
                    gMults.append(gmult)
                }
                // print(mult.name.substring(from: 5), mult.doubleValue)
            }
            ind.shortDescription = ind.descind.value
            if ind.isff.intValue == 0 {
                
                mvs.append(ind)
                
            } else {
                ffs.append(ind)
            }
        }
        /*
         print()
         print("GMults:")
         for gmult in gMults {
         print(gmult.indIndex, gmult.depIndex, gmult.value)
         }
         print()
         */
        
        /*
         print()
         print("Mvs:")
         for mv in mvs {
         print(mv.name, mv.shortDescription)
         }
         print()
         print("Ffs:")
         for ff in ffs {
         print(ff.name, ff.shortDescription)
         }
         */
    }
    
    public func generateCCFContent () -> String {
        var contents = "CCF_Version 1\r\n"
        contents += "[COMMENT]\r\n"
        contents += getSectionCCFLines(generalSection)
        contents += getSectionCCFLines(configSection)
        contents += "[ET]\r\n"
        contents += "[CSS]\r\n"
        for ind in inds {
            contents += getSectionCCFLines(ind)
        }
        for cv in cvs {
            contents += getSectionCCFLines(cv)
        }
        for sub in subs {
            contents += getSectionCCFLines(sub)
        }
        for param in calcParams {
            contents += param.line
        }
        contents += getSectionCCFLines(calcSection)
        
        return contents

    }
    
    func getSectionCCFLines(_ section: Section) -> String {
        let params = section.params.sorted{$0.name < $1.name}
        var contents = "\(section.sectionName)\r\n"
        for param in params {
            contents += param.line
        }
        return contents
    }
    
    
    
    public init() {}
    
}
