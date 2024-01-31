//
//  Config.swift
//  DMCRead
//
//  Created by Richard Street on 11/6/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation
// import StringKit


/// DMCplus configuration
public class Config {
    
    var contents = "" // Used to store the file contents
    public var url = URL(fileURLWithPath: "")
    public var directoryUrl = URL(fileURLWithPath: "")
    public var selectedSection: Section? // Used to communicate current selected var across view controllers
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
    public var subcontrollers = [SubController]()
    public var calcParams = [ConfigParam]()
    public var calcSection = Section()
    public var configSection = Section()
    public var generalSection = Section()
    public var etSection = Section()
    public var cssSection = Section()
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
        subcontrollers.removeAll()
        gMults.removeAll()
        cvIndex = 0
        mvIndex = 0
        ffIndex = 0
        indIndex = 0
        subIndex = 0
        calcIndex = 0
        
    }
    
    public func readCCF(url: URL) -> Bool {
        clear()
        directoryUrl = url.deletingLastPathComponent()
        do {
            // Read the file contents
            contents = try String(contentsOf: url, encoding: .ascii)
        } catch let error as NSError {
            print("Failed reading from URL: \(url.path), Error: " + error.localizedDescription)
            return false
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
        return true
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
                
                let prefix = line.left(4)
                // print("prefix \(prefix)")
                switch prefix {
                case "[IND":
                    // Ind
                    // isVar = true
                    section.index = indIndex
                    indIndex += 1
                    section.name = getVarName(sectionText: line)
                    inds.append(section)
                // print("Ind: \(section.name)")
                case "[DEP":
                    // Dep
                    section.name = getVarName(sectionText: line)
                    section.index = cvIndex
                    cvIndex += 1
                    cvs.append(section)
                    // print("Dep: \(section.name)")
                // isVar = true
                case "[SUB":
                    section.index = subIndex
                    subIndex += 1
                    section.name = getVarName(sectionText: line)
                    // print("sub in \(section.name)")
                    subs.append(section)
                case "[CON": // Config
                    section.name = getSectionName(sectionText: line)
                    configSection = section
                case "[GEN":
                    section.name = getSectionName(sectionText: line)
                    generalSection = section
                case "[ET]":
                    // print("ET section added")
                    section.name = "ET"
                    etSection = section
                case "[CSS]":
                    // CLP
                    print("CSS section added")
                    section.name = "CSS"
                    cssSection = section
                case "[CAL":
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
                
                // Check if global variable
                if !(name.hasPrefix("CALC") || name.hasPrefix("COMMENTC")) && section.name == "CALC" {
                    // Global Variable
                    // print()
                    // print("Global: \(configParam.name)")
                    // print()
                    calcParams.append(configParam)
                    // calcIndex += 1
                } else {
                    // Normal Section
                    configParam.calcIndex = calcIndex
                    section.append(configParam)
                    if section.name == "CALC" {
                        calcIndex += 1
                    }
                }
                // }
                
                
                
            }
            
        } // End for
        sectionCount = sectionID
        paramCount = paramID
        calcCount = calcIndex
        modelName = configSection.mdlnam.value
        print("config model name \(modelName)")
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
        print()
        print("Getting Gmults from Config parsing lines...")
        for ind in inds {
            let mults = ind.params.filter{$0.name.left(5) == "GMULT"}
            print("\(ind.name), gmults \(mults.count)")
            for mult in mults {
                if var depIndex = mult.name.substring(from: 5).integerValue {
                    if depIndex <= cvs.count {
                        depIndex -= 1  // Aspen indicies start with 1
                        // print(depIndex, mult.doubleValue)
                        let gmult = GMult(indIndex: ind.index, depIndex: depIndex, value: mult.doubleValue)
                        gMults.append(gmult)
                    } else {
                        print("Gmult dep index \(depIndex - 1) out of range.")
                    }
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
        
        

         print()
         print("GMults:")
        print("Gmult count \(gMults.count)")
         for gmult in gMults {
         print(gmult.indIndex, gmult.depIndex, gmult.value)
         }
         print()

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
        print("Finished parsing lines.")
    }
    
    public func generateCCFContent () -> String {
        var contents = "CCF_Version 1\r\n"
        contents += "[COMMENT]\r\n"
        
        // Config
        contents += "\(configSection.sectionName)\r\n"
        contents += getSectionCCFLines(configSection)
        
        // General
        contents += "\(generalSection.sectionName)\r\n"
        contents += getSectionCCFLines(generalSection)
        
        // ET
        contents += "\(etSection.sectionName)\r\n"
        contents += getSectionCCFLines(etSection)
        
        // CSS
        contents += "\(cssSection.sectionName)\r\n"
        contents += getSectionCCFLines(cssSection)

        // Inds
        for ind in inds {
            contents += "[IND:\(ind.name)]\r\n"
            contents += getSectionCCFLines(ind)
        }
        
        // Deps
        for cv in cvs {
            contents += "[DEP:\(cv.name)]\r\n"
            contents += getSectionCCFLines(cv)
        }
        
        // print("no subs \(subs.count)")
        for sub in subs {
            // print("sub out \(sub.name)")
            contents += "[SUB:\(sub.name)]\r\n"
            contents += getSectionCCFLines(sub)
        }
        
        // Calcs
        contents += "\(calcSection.sectionName)\r\n"
        // Global Params
        for param in calcParams {
            contents += param.line
        }
        contents += getSectionCCFLines(calcSection)
        
        return contents
        
    }
    
    func getSectionCCFLines(_ section: Section) -> String {
        // print("Generating lines for \(section.name)")
        var params = [ConfigParam]()
        if section.name == "CALC" {
            params = section.params.sorted{$0.calcIndex < $1.calcIndex}
        } else {
            params = section.params.sorted{$0.name < $1.name}
        }
        var contents = ""
        for param in params {
            contents += param.line
        }
        return contents
    }
    
    // get IO
    public func getIO() -> [(dcsTag: String, name: String, keyWord: String)] {
        var ioList = [(dcsTag: String, name: String, keyWord: String)]()
        for param in configSection.params {
            if param.io {
                ioList.append((param.dcsTag, param.name, param.keyWord))
            }
        }
        for param in generalSection.params {
            if param.io {
                ioList.append((param.dcsTag, param.name, param.keyWord))
            }
        }
        for mv in mvs {
            for param in mv.params {
                if param.io {
                    ioList.append((param.dcsTag, param.name, param.keyWord))
                }
            }
        }
        for ff in ffs {
            for param in ff.params {
                if param.io {
                    ioList.append((param.dcsTag, param.name, param.keyWord))
                }
            }
        }
        for cv in cvs {
            for param in cv.params {
                if param.io {
                    ioList.append((param.dcsTag, param.name, param.keyWord))
                }
            }
        }
        for param in calcParams {
            if param.io {
                ioList.append((param.dcsTag, param.name, param.keyWord))
            }
        }
        for param in etSection.params {
            if param.io {
                ioList.append((param.dcsTag, param.name, param.keyWord))
            }
        }
        ioList.sort{$0.dcsTag < $1.dcsTag}
        return ioList
    }
    
    
    
    public init() {}
    
}
