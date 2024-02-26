//
//  Model.swift
//  DMCRead
//
//  Created by Richard Street on 11/7/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation
import NSStringKit
import DoubleKit
import DialogKit

/// DMCplus Model
public class Model {
    public var name = ""
    public var modelNotes = ""
    public var baseName = ""
    public var dpaName = ""
    public var noInds = 0
    public var noDeps = 0
    
    public var numberMvs = 0
    
    public var noCoefs = 0
    public var timeToSS = 0.0
    public var numberCoefLines = 0
    public var deps = [Dep]()
    public var inds = [Ind]()
    public var gains = [Gain]()
    public var curveSources = [CurveSource]()
    public var modelCurves = [ModelCurve]()
    
    var dpaContents = [String]()
    public var dpaLoaded = false
    
    public var mdlURL = URL.init(fileURLWithPath: "")
    public var dpaURL = URL.init(fileURLWithPath: "")
    
    // RGA Properties
    public var rgaAll = [Rga]()  // Calculated rga's
    public var rgas = [Rga]()   // Filtered rga's
    public var selected1Denominator = true
    public var selectedRgaIndex: Int?
    public var selected1Name = "" // used for gainRatio Calc
    public var selected2Name = "" // used for gainRatio Calc
    public var excludeByMV = true // used for exclude VC
    public var rgaLimit = 5.0
    public var sortRgaBy: SortRgaBy = .rga {
        didSet {
            sortRga()
        }
    }
    
    // Gain Ratio Properties
    public var ratioByMvPair = true
    public var selectedRatioIndex: Int?
    public var sortRatioBy: SortRatioBy = .ratio {
        didSet {
            sortRatios()
        }
    }
    
    public var gainRatios = [GainRatio]()
    
    
    func clear() {
        deps.removeAll()
        inds.removeAll()
        gains.removeAll()
        curveSources.removeAll()
        dpaContents.removeAll()
    }
    
    public func readMDL(url: URL) -> Bool {
        clear()
        print("model readMDL url \(url)")
        // check if mdl file exists
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            let result = dialogOK("Missing Model File (*.mdl).", info: "Please make sure it is in the same directory as the controller ccf file")
            print(result)
            return false
        }
        mdlURL = url
        
        
        var contents = ""
        do {
            // Read the file contents
            contents = try String(contentsOf: url, encoding: .ascii)
        } catch let error as NSError {
            print("Failed reading from URL: \(url.path), Error: " + error.localizedDescription)
            return false
        }
        // print(contents)
        
        let lines = contents.components(separatedBy: "\r\n")
        
        var lineNumber = 2
        if let no = lines[lineNumber].integerValue {
            noInds = no
        }
        
        lineNumber = 3
        if let no = lines[lineNumber].integerValue {
            noDeps = no
        }
        
        
        lineNumber = 4
        if let no = lines[lineNumber].integerValue {
            noCoefs = no
        }
        
        lineNumber = 6
        if let no = lines[lineNumber].doubleValue {
            timeToSS = no
        }
        // print("no min to SS from Model \(timeToSS)")
        
        let NumberCoefLines = noCoefs / 5 + noCoefs % 5 // Number of lines for dynamic curve
        // print("Coef lines   \(NumberCoefLines)")
        
        
        lineNumber = 8
        // Get Inds
        var indNo = 0
        // Inds start with -999
        while lines[lineNumber].substring(with: 5..<10) == "-999." {
            // print("Ind Tags")
            let tag = lines[lineNumber].substring(with: 36..<49).trim()
            let units = lines[lineNumber].substring(with: 49..<61).trim()
            inds.append(Ind(no: indNo, name: tag, shortDescription: "", units: units))
            // inds.append((indNo, tag, units))
            // print("\(indNo) Ind: \(tag)  \(units)")
            lineNumber += 1
            indNo += 1
        }
        print(inds)
        
        // Get Deps
        var depNo = 0
        while lines[lineNumber].substring(with: 8..<16) == "0.000000" {
            let tag = lines[lineNumber].substring(with: 36..<49).trim()
            let units = lines[lineNumber].substring(with: 49..<61).trim()
            let rampIndex =  lines[lineNumber].substring(with: 66..<67).integerValue ?? 0
            // print("ramp: \(ramp)")
            deps.append(Dep(no: depNo, name: tag, shortDescription: "", units: units, ramp: rampIndex))
            lineNumber += 1
            depNo += 1
            // print("Dep: \(tag) \(units)")
        }
        print(deps)
        
        // Get Gains
        // lineNo += 1 // Get to dep line for gains
        // print("getting gains")
        for dep in deps {
            // let tDep = lines[lineNo].substring(with: 0..<13)
            lineNumber += 11
            print("start inds\(lines[lineNumber])")
            for ind in inds {
                print("ind \(lines[lineNumber])")
                // let tInd = lines[lineNo].substring(with: 0..<13)
                let textGain = String(lines[lineNumber].substring(with: 46..<69)).trim()
                print("Dep: \(dep.index) Ind: \(ind.index) textGain: \(textGain)")
                let originalGain = textGain.doubleValue!
                var curveCoefs = [Double]()
                var dynamicCurve = false
                // scan coeficents
                for _ in 1 ... NumberCoefLines {
                    lineNumber += 1
                    let numbers = getNumberArray(lines[lineNumber])
                    print("numbers \(numbers)")
                    if (numbers.min() != 0.0 || numbers.max() != 0.0) && !dynamicCurve {
                        print("dynamic numbers \(numbers)")
                        dynamicCurve = true
                    }
                    curveCoefs += numbers
                    print("\(numbers)")
                }
                if dynamicCurve {
                    gains.append(Gain(indIndex: ind.index, depIndex: dep.index, gain: originalGain))
                    // Append curve coefs to modelCurve
                    print()
                    print("appending curve \(curveCoefs.count)")
                    let modelCurve = ModelCurve()
                    modelCurve.indName = ind.name
                    modelCurve.indIndex = ind.index
                    modelCurve.depName = dep.name
                    modelCurve.depIndex = dep.index
                    modelCurve.gain = originalGain
                    modelCurve.coefficients = curveCoefs
                    // print(curveCoefs)
                    if dep.ramp > 0 {
                        modelCurve.isRamp = true
                    } else {
                        modelCurve.isRamp = false
                    }
                    let absMax = modelCurve.maxAbsCoefficient
                    if absMax > dep.maxAbsGain {
                        dep.maxAbsGain = absMax
                    }
                    print("abs Max", dep.maxAbsGain)
                    modelCurves.append(modelCurve)
                }
                lineNumber += 1
            }  // End inds
        } // End deps
        print("noInds \(noInds)")
        print("noDeps \(noDeps)")
        print("noCoefs \(noCoefs)")
        print("timeToSS \(timeToSS)")
        print("numberCoefLines \(numberCoefLines)")
        print("noCurves \(gains.count)")
        print()
        
        print("reading dpa file")
        _ = readDPA()
        print("Completely done with mdl!")
        print("model read complete.")
        return true
    }
    
    func getNumberArray(_ aString: String) -> [Double] {
        let texts = aString.components(separatedBy: " ")
        var numbers: [Double] = []
        for text in texts {
            if let number = text.doubleValue {
                numbers.append(number)
            }
        }
        return numbers
    }
    // From DMCTuner
    /*
     func readDPA() {
     print("in readDPA()")
     let modelFile = mdlURL.lastPathComponent
     name = modelFile
     print("model name \(name)")
     if var dpaFile = modelFile.fileBase() {
     baseName = dpaFile
     dpaFile += ".dpa"
     dpaName = dpaFile
     dpaURL = mdlURL.deletingLastPathComponent().appendingPathComponent(dpaFile)
     print("dpaURL \(dpaURL.path)")
     } else {
     print("No model file")
     }
     
     let fm = FileManager.default
     
     if !fm.fileExists(atPath: dpaURL.path) {
     let answer = dialogOK("Missing dpa file (*.dpa).", info: "Please make sure it is in the same directory as the controller ccf file")
     print(answer)
     dpaLoaded = false
     return
     }
     var contents = ""
     do {
     // Read the file contents
     contents = try String(contentsOf: dpaURL)
     } catch let error as NSError {
     print("Failed reading from URL: \(dpaURL), Error: " + error.localizedDescription)
     }
     
     
     contents = contents.replace("\r\n", with: "\n")
     var lineNo = 0
     
     
     // let lines: [String]
     dpaContents = contents.components(separatedBy: "\n")
     print("parsing dpa file lines...")
     print(dpaContents)
     // get long descriptions and step size for Ind
     lineNo = 7
     print("updating inds")
     for ind in inds {
     let texts = dpaContents[lineNo].components(separatedBy: "  ")
     let longDescrip = texts[texts.count - 2].replace("\"", with: "")
     var typicalMove = 0.0
     if let step = texts.last!.doubleValue {
     typicalMove = step
     }
     // let typicalMove = doubleValue(texts.lastt!)
     ind.longDescription = longDescrip
     ind.typicalMove = typicalMove
     
     // print("\(ind.name), typMove: \(ind.typicalMove)")
     // indInfo.append(IndInfo(no: ind.no, name: ind.name, description: longDescrip, typicalMove: typicalMove))
     // print("lDescrip \(indInfo.last?.description)")
     
     
     // print("\((ind.no, ind.tag, longDescrip, typicalMove))")
     lineNo += 1
     }
     // get longDescrips for Dep
     print("updating deps")
     for dep in deps {
     let texts = dpaContents[lineNo].components(separatedBy: "  ")
     let longDescrip = texts[texts.count - 2].replace("\"", with: "")
     // depInfo.append(DepInfo(no: dep.no, name: dep.name, description: longDescrip, ramp: dep.ramp))
     dep.longDescription = longDescrip
     // print("\((dep.no, dep.name, longDescrip, dep.ramp))")
     // print("lDescrip \(depInfo.last?.description)")
     
     lineNo += 1
     }
     
     
     lineNo += 1
     // Get Curve Sources
     curveSources.removeAll()
     print("getting curve sources:")
     print("line count", dpaContents.count)
     print("line", lineNo)
     print(dpaContents[lineNo])
     while lineNo < dpaContents.count {
     print()
     print("line \(lineNo)")
     if dpaContents[lineNo].hasPrefix(".CUR") {
     curveSources.append(CurveSource())
     let curveSource = curveSources.last!
     let tags = dpaContents[lineNo].substring(from: 14).quotedWords()
     curveSource.indName = tags[0]
     curveSource.depName = tags[1]
     curveSource.indIndex = indNo(name: tags[0])
     curveSource.depIndex = depNo(name: tags[1])
     print("Curve", tags[0], tags[1])
     if lineNo < dpaContents.count - 1 {
     lineNo += 1
     }
     print("line after CUR", lineNo)
     print(dpaContents[lineNo])
     
     while !dpaContents[lineNo].hasPrefix(".CUR") && lineNo < dpaContents.count{
     print()
     print("line \(lineNo)")
     let curveType = getCurveType(dpaContents[lineNo])
     // print("get curve type", curveType.trim())
     switch curveType {
     case ".UNIty  ":
     curveSource.type = "UNI"
     curveSource.sourceCase = "Unity Curve"
     curveSource.sources.append(.unity)
     // print(".UNI")
     case ".ZERo   ":
     curveSource.type = "ZER"
     curveSource.sourceCase = "Zero Curve"
     curveSource.sources.append(.zero)
     // print(".ZER")
     
     case "    .REP":
     let values = dpaContents[lineNo].substring(from: 10).quotedWords()
     curveSource.type = "REP"
     curveSource.sourceCase = values[0]
     curveSource.sourceCurve = values[1]
     curveSource.sourceInd = values[2]
     curveSource.sourceDep = values[3]
     curveSource.sources.append(.replace(ind: values[2], dep: values[3], sourceCase: values[0], sourceCurve: values[1]))
     // print(".REP")
     
     case "    .FIR":
     curveSource.type = "FIR"
     let curve = dpaContents[lineNo].substring(from: 16).components(separatedBy: " ")
     // print(curve)
     if let deadtime = curve[1].doubleValue, let tau = curve[1].doubleValue, let gain =  curve[2].doubleValue{
     curveSource.deadtime = deadtime / 60.0
     curveSource.tau = tau / 60.0
     curveSource.gain = gain
     curveSource.sources.append(.first(deadtime: deadtime / 60.0, tau: tau / 60.0, gain: gain))
     }
     // print(".FIR")
     
     case "    .SEC":
     curveSource.type = "SEC"
     // print(dpaContents[lineNo].substring(from: 17))
     let curve = dpaContents[lineNo].substring(from: 17).components(separatedBy: " ")
     // print(curve)
     if let deadtime = curve[1].doubleValue, let tau = curve[1].doubleValue, let damp = curve[2].doubleValue, let gain = curve[3].doubleValue {
     curveSource.deadtime = deadtime / 60.0
     curveSource.tau = tau / 60.0
     curveSource.damp = damp
     curveSource.gain = gain
     curveSource.sources.append(.second(deadtime: deadtime / 60.0, tau: tau / 60.0, damp: damp, gain: gain))
     // print(".SEC")
     }
     
     case "    .CON":
     let curve = dpaContents[lineNo].substring(from: 15).quotedWords()
     curveSource.type = "CON"
     curveSource.sourceCase = curve[0]
     curveSource.sourceCurve = curve[1]
     curveSource.convoluteCase = curve[2]
     curveSource.convoluteCurve = curve[3]
     curveSource.sourceInd = curve[4]
     curveSource.sourceDep = curve[5]
     curveSource.convoluteIndName = curve[6]
     curveSource.sources.append(.convolute(model: curve[0] + "   " + curve[1], ind: curve[4], interModel: curve[2] + "   " + curve[3], dep: curve[5], interInd: curve[6]))
     // print(".CON")
     
     default:
     break
     }
     lineNo += 1
     if lineNo == dpaContents.count {
     break
     }
     // print("line end curve while", lineNo)
     if lineNo < dpaContents.count {
     // print(dpaContents[lineNo])
     }
     print()
     print("Exit inner while")
     }
     }
     // lineNo += 1
     // print("line end file while", lineNo)
     // print(dpaContents[lineNo])
     }
     print("done getting curvesources")
     print()
     dpaLoaded = true
     getGainWindows()
     }
     */
    
    // From DMCTuner Modified
    
    func readDPA() -> Bool {
        print("in readDPA()")
        let modelFile = mdlURL.lastPathComponent
        name = modelFile
        print("model name \(name)")
        if var dpaFile = modelFile.fileBase() {
            baseName = dpaFile
            dpaFile += ".dpa"
            dpaName = dpaFile
            dpaURL = mdlURL.deletingLastPathComponent().appendingPathComponent(dpaFile)
            print("dpaURL \(dpaURL.path)")
        } else {
            print("No model file")
        }
        
        let fm = FileManager.default
        
        if !fm.fileExists(atPath: dpaURL.path) {
            let answer = dialogOK("Missing dpa file (*.dpa).", info: "Please make sure it is in the same directory as the controller ccf file")
            print(answer)
            dpaLoaded = false
            return false
        }
        var contents = ""
        do {
            // Read the file contents
            contents = try String(contentsOf: dpaURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(dpaURL), Error: " + error.localizedDescription)
        }
        
        
        
        
        // contents = contents.replace("\r\n", with: "\n")
        contents.stripCarriageReturns()
        
        
        
        
        // let lines: [String]
        dpaContents = contents.components(separatedBy: "\n")
        
        
        // New Parse
        var indIndex = 0
        var depIndex = 0
        var curveSource = CurveSource()
        curveSources.removeAll()
        
        for line in dpaContents {
            if line.hasPrefix("!") {
                print("comment: \(line)")
                continue
            }
            let curveType = getCurveType(line)
            
            var texts = [String]()
            if let firstQuoteIndex = line.index(of: "\"") {
                texts = String(line[firstQuoteIndex...]).quotedWords()
            }
            print("texts: \(texts)")
            
            switch curveType {
            case ".MODel  ":
                if texts.count > 2 {
                    // Has Model notes
                    modelNotes = texts[2]
                    print("notes: \(modelNotes)")
                    modelNotes = modelNotes.replace("!~", with: "\n")
                }
            case ".NCOeff ":
                // Number coeficents
                break
            case ".TTSs   ":
                // Time to steady-state seconds
                break
            case ".INDepen":
                let values = line.components(separatedBy: "  ")
                
                let longDescrip = values[3]
                let units = values[2]
                var typicalMove = 0.0
                if let step = values.last!.doubleValue {
                    typicalMove = step
                    print("Typ Move \(step)")
                } else {
                    print("Cannot find typ move")
                }
                inds[indIndex].longDescription = longDescrip.trimQuotes()
                inds[indIndex].typicalMove = typicalMove
                inds[indIndex].units = units.trimQuotes()
                indIndex += 1
            case ".DEPende":
                let longDescrip = texts[2]
                let units = texts[1]
                deps[depIndex].longDescription = longDescrip
                deps[depIndex].units = units
                depIndex += 1
            case ".CURve  ":
                curveSources.append(CurveSource())
                curveSource = curveSources.last!
                let gain = Gain()
                let tags = line.substring(from: 14).quotedWords()
                let indName = tags[0]
                let depName = tags[1]
                let comment = tags[2]
                curveSource.indName = indName
                curveSource.depName = depName
                curveSource.note = comment
                curveSource.indIndex = indNo(name: indName)
                curveSource.depIndex = depNo(name: depName)
                
                if comment.uppercased().contains("RGA ORIGINAL GAIN WAS") {
                    print("Modified Gain")
                    if let i1 = comment.index(after: "was "), let i2 = comment.index(before: " and"), let i3 = comment.index(after: " to") {
                        let gainOriginal = String(comment[i1...i2]).doubleValue
                        let gainAdjusted = String(comment[i3...]).doubleValue
                        let updateInd = inds.filter{$0.name.uppercased() == indName.uppercased()}
                        let indNo = updateInd[0].index
                        let updateDep = deps.filter{$0.name.uppercased() == depName.uppercased()}
                        let depNo = updateDep[0].index
                        let gain = gains.filter{$0.indIndex == indNo && $0.depIndex == depNo}
                        if gain.count > 0 {
                            if let gOriginal = gainOriginal {
                                gain[0].originalGain = gOriginal
                            }
                            if let gAdjusted = gainAdjusted {
                                gain[0].adjustedGain = gAdjusted
                            }
                            if comment.contains("set") {
                                gain[0].adjustType = .set
                            } else {
                                gain[0].adjustType = .calculated
                            }
                        }
                    }
                    let components = comment.components(separatedBy: " ")
                    print()
                    print()
                    print("componets \(components.count)")
                    if components.count == 14 {
                        // print("masterGain and gainRatio for \(gain.depIndex)")
                        var masterGainIndIndex = 0
                        var masterGainDepIndex = 0
                        var gainRatio = 0.0
                        var isNumerator = false
                        var masterGain = Gain()
                        var indString = components[10]
                        indString = indString.replace("(", with: "")
                        indString = indString.replace(",", with: "")
                        if let value = Int(indString) {
                            masterGainIndIndex = value
                        }
                        var depString = components[11]
                        depString = depString.replace(")", with: "")
                        if let value = Int(depString) {
                            masterGainDepIndex = value
                        }
                        if let value = Double(components[13]) {
                            gainRatio = value
                            print("got gainRatio \(value)")
                        }
                        if components[13] == "/" {
                            isNumerator = true
                        } else {
                            isNumerator = false
                        }
                        let masterGains = gains.filter{$0.indIndex == masterGainIndIndex && $0.depIndex == masterGainDepIndex}
                        if masterGains.count > 0 {
                            masterGain = masterGains[0]
                            print("got masterGain \(masterGain.gain)")
                        }
                        gain.masterGain = masterGain
                        gain.gainRatio = gainRatio
                        gain.masterIsNumerator = isNumerator
                    }
                }
                case ".UNIty  ":
                    curveSource.type = "UNI"
                    curveSource.sourceCase = "Unity Curve"
                    curveSource.sources.append(.unity)
                case ".ZERo   ":
                    curveSource.type = "ZER"
                    curveSource.sourceCase = "Zero Curve"
                    curveSource.sources.append(.zero)
                    
                case "    .REP":
                    let values = line.substring(from: 10).quotedWords()
                    curveSource.type = "REP"
                    curveSource.sourceCase = values[0]
                    curveSource.sourceCurve = values[1]
                    curveSource.sourceInd = values[2]
                    curveSource.sourceDep = values[3]
                    curveSource.sources.append(.replace(ind: values[2], dep: values[3], sourceCase: values[0], sourceCurve: values[1]))
                    // print(".REP")
                    
                case "    .FIR":
                    curveSource.type = "FIR"
                    let curve = line.substring(from: 16).components(separatedBy: " ")
                    // print(curve)
                    if let deadtime = curve[1].doubleValue, let tau = curve[1].doubleValue, let gain =  curve[2].doubleValue{
                        curveSource.deadtime = deadtime / 60.0
                        curveSource.tau = tau / 60.0
                        curveSource.gain = gain
                        curveSource.sources.append(.first(deadtime: deadtime / 60.0, tau: tau / 60.0, gain: gain))
                    }
                    // print(".FIR")
                    
                case "    .SEC":
                    curveSource.type = "SEC"
                    // print(dpaContents[lineNo].substring(from: 17))
                    let curve = line.substring(from: 17).components(separatedBy: " ")
                    // print(curve)
                    if let deadtime = curve[1].doubleValue, let tau = curve[1].doubleValue, let damp = curve[2].doubleValue, let gain = curve[3].doubleValue {
                        curveSource.deadtime = deadtime / 60.0
                        curveSource.tau = tau / 60.0
                        curveSource.damp = damp
                        curveSource.gain = gain
                        curveSource.sources.append(.second(deadtime: deadtime / 60.0, tau: tau / 60.0, damp: damp, gain: gain))
                        // print(".SEC")
                    }
                    
                case "    .CON":
                    let curve = line.substring(from: 15).quotedWords()
                    curveSource.type = "CON"
                    curveSource.sourceCase = curve[0]
                    curveSource.sourceCurve = curve[1]
                    curveSource.convoluteCase = curve[2]
                    curveSource.convoluteCurve = curve[3]
                    curveSource.sourceInd = curve[4]
                    curveSource.sourceDep = curve[5]
                    curveSource.convoluteIndName = curve[6]
                    curveSource.sources.append(.convolute(model: curve[0] + "   " + curve[1], ind: curve[4], interModel: curve[2] + "   " + curve[3], dep: curve[5], interInd: curve[6]))
                    // print(".CON")
                    
                    
                default:
                    break
                    
                }
            }
            
            dpaLoaded = true
            getGainWindows()
            return true
        }
        
        
        
        /*
         // From DMCRga
         func readDPA() {
         var contents = ""
         let fm = FileManager.default
         if fm.fileExists(atPath: dpaURL.path) {
         // print("File exists")
         do {
         contents = try String(contentsOfFile: dpaURL.path, encoding: String.Encoding.ascii)
         // print("\(fileContents)").path
         // the above prints "some text"
         } catch let error as NSError {
         print("Error: \(error)")
         }
         } else {
         print("File does not exist")
         let answer =  dialogOK("DPA File Missing.", info: dpaURL.path)
         print("\(answer)")
         }
         
         contents = contents.replace("\r\n", with: "\n")
         
         
         // if let contents = fileContents {
         contents.removeAll()
         dpaContents = contents.components(separatedBy: "\n")
         // print(lines)
         
         // get long descriptions and step size for Ind
         var lineNo = 7
         for var ind in inds {
         let texts = dpaContents[lineNo].components(separatedBy: "  ")
         let longDescrip = texts[texts.count - 2].replace("\"", with: "")
         var typicalMove = 0.0
         if let step = texts.last!.doubleValue {
         typicalMove = step
         }
         // let typicalMove = doubleValue(texts.lastt!)
         ind.description = longDescrip
         ind.typicalMove = typicalMove
         indInfo.append(IndInfo(no: ind.no, name: ind.name, description: longDescrip, typicalMove: typicalMove))
         // print("lDescrip \(indInfo.last?.description)")
         
         
         // print("\((ind.no, ind.tag, longDescrip, typicalMove))")
         lineNo += 1
         }
         // get longDescrips for Dep
         for var dep in deps {
         let texts = dpaContents[lineNo].components(separatedBy: "  ")
         let longDescrip = texts[texts.count - 2].replace("\"", with: "")
         dep.description = longDescrip
         depInfo.append(DepInfo(no: dep.no, name: dep.name, description: longDescrip, ramp: dep.ramp))
         // print("\((dep.no, dep.name, longDescrip, dep.ramp))")
         // print("lDescrip \(depInfo.last?.description)")
         
         lineNo += 1
         }
         
         // get curves
         for i in lineNo ..< dpaContents.count {
         let operation = dpaContents[i].left(4)
         if operation == ".CUR" {
         let params = dpaContents[i].substring(from: 14).quotedWords()
         print(params)
         let indName = params[0]
         let depName = params[1]
         let comment = params[2]
         if comment.uppercased().contains("RGA ORIGINAL GAIN WAS") {
         // print("Modified Gain")
         if let i1 = comment.indexAfter("was "), let i2 = comment.indexBefore(" and"), let i3 = comment.indexAfter(" to") {
         let gainOriginal = String(comment[i1...i2]).doubleValue
         let gainAdjusted = String(comment[i3...]).doubleValue
         let updateInd = inds.filter{$0.name == indName}
         let indNo = updateInd[0].no
         let updateDep = deps.filter{$0.name == depName}
         let depNo = updateDep[0].no
         let gain = gains.filter{$0.indNo == indNo && $0.depNo == depNo}
         if gain.count > 0 {
         if let gOriginal = gainOriginal {
         gain[0].originalGain = gOriginal
         }
         if let gAdjusted = gainAdjusted {
         gain[0].adjustedGain = gAdjusted
         }
         if comment.contains("set") {
         gain[0].adjustType = .set
         } else {
         gain[0].adjustType = .adjusted
         }
         }
         }
         /*
          let index1 = comment.lastIndexOf("was")
          let index2 = comment.indexOf("and")
          let index3 = comment.lastIndexOf("to")
          if let i1 = index1, let i2 = index2, let i3 = index3 {
          // let gainOriginal = comment.substring(with: i1 ..< i2).doubleValue
          let gainOriginal = String(comment[i1 ..< i2]).doubleValue
          // print("oGain: \(gainOriginal)")
          // let gainAdjusted = comment.substring(from: i3).doubleValue
          let gainAdjusted = String(comment[i3...]).doubleValue
          // print("aGain: \(gainAdjusted)")
          let updateInd = inds.filter{$0.name == indName}
          let indNo = updateInd[0].no
          let updateDep = deps.filter{$0.name == depName}
          let depNo = updateDep[0].no
          var gain = gains.filter{$0.indNo == indNo && $0.depNo == depNo}
          if gain.count > 0 {
          if let gOriginal = gainOriginal {
          gain[0].originalGain = gOriginal
          }
          if let gAdjusted = gainAdjusted {
          gain[0].adjustedGain = gAdjusted
          }
          if comment.contains("set") {
          gain[0].adjustType = .set
          } else {
          gain[0].adjustType = .adjusted
          }
          }
          }
          */
         }
         }
         }
         
         
         /*
          for (index, value) in deps.enumerated() {
          depDict[value.no] = index
          }
          
          
          for (index, value) in inds.enumerated() {
          indDict[value.no] = index
          }
          */
         
         dpaLoaded = true
         getGainWindows()
         
         
         
         }
         */
        
        
        public func getGain(ind: Int, dep: Int) -> Gain {
            let gain = gains.filter{$0.indIndex == ind && $0.depIndex == dep}
            return gain[0]
        }
        
        
        func getGainWindows() {
            // print("getting GainWindows...")
            for dep in deps {
                let depGains = gains.filter{$0.depIndex == dep.index}
                var gainWindow = 0.0
                for gain in depGains {
                    let window = abs(gain.gain * inds[gain.indIndex].typicalMove)
                    if window > gainWindow {
                        gainWindow = window
                    }
                }
                dep.gainWindow = gainWindow
            }
            // print("done getting GainWindows.")
        }
        
        func getCurveType(_ line: String) -> String {
            if line.count < 8 || line.hasPrefix("!") {
                return "none"
            } else {
                return line.left(8)
            }
        }
        public func depNo(name: String) -> Int {
            let dep = deps.filter{$0.name.uppercased() == name.uppercased()}
            if dep.count > 0 {
                return dep[0].index
            } else {
                return 0
            }
        }
        
        public func indNo(name: String) -> Int {
            let ind = inds.filter{$0.name.uppercased() == name.uppercased()}
            if ind.count > 0 {
                return ind[0].index
            } else {
                return 0
            }
        }
        
        public func calcRgas() {
            print("model calculating rgas")
            rgaAll.removeAll()
            let nonZeroGains = gains.filter{$0.gain != 0.0}
            
            if numberMvs < 2 {
                return
            }
            
            var denseCRow = [Gain]() // gains for ind 1 where cv in both ind 1 and ind 2
            var denseDRow = [Gain]() // gains for ind 2 where cv in both ind 1 and ind 2
            
            var mvIndices = [Int]()
            // print("number Mvs \(numberMvs)")
            for i in 0 ..< numberMvs {
                if !inds[i].excluded {
                    mvIndices.append(inds[i].index)
                    // print("appended mv \(inds[i].index) to rga mvIndices.")
                }
            }
            /*
             for mv in mvs {
             if !mv.exclude {
             mvIndices.append(mv.index)
             } else {
             print("mv \(mv.index) excluded")
             }
             }
             */
            // for a in 0 ..< numberMvs-1 {
            //for b in a+1 ..< numberMvs {
            // print(a, b)
            for ia in 0 ..< mvIndices.count - 1 {
                let a = mvIndices[ia]
                for ib in (ia + 1) ..< mvIndices.count {
                    let b = mvIndices[ib]
                    denseCRow.removeAll()
                    denseDRow.removeAll()
                    let cRow = nonZeroGains.filter{$0.indIndex == a && !deps[$0.depIndex].excluded} // gains for ind 1
                    let dRow = nonZeroGains.filter{$0.indIndex == b && !deps[$0.depIndex].excluded} // gains for ind 2
                    
                    for i in 0 ..< cRow.count {
                        let dRowFiltered = dRow.filter{$0.depIndex == cRow[i].depIndex} // See if depNo is in dRow
                        let count = dRowFiltered.count
                        if count > 0 {
                            denseCRow.append(cRow[i])
                            denseDRow.append(dRowFiltered[0])
                        }
                    }
                    /*
                     print("")
                     print("a: \(a)  b: \(b)")
                     for i in 0 ..< denseCRow.count {
                     print(denseCRow[i].depNo, denseCRow[i].gain, denseDRow[i].depNo, denseDRow[i].gain)
                     }
                     print("rgas")
                     */
                    
                    if denseCRow.count > 1 {
                        for c in 0 ..< denseCRow.count - 1 {
                            for d in c + 1 ..< denseCRow.count {
                                // print(c, d)
                                // print(denseCRow[c].gain, denseCRow[d].gain)
                                // print(denseDRow[c].gain, denseDRow[d].gain)
                                
                                // print(denseCRow[c].indNo, denseCRow[c].depNo, denseCRow[c].gain)
                                // print(denseCRow[d].indNo, denseCRow[d].depNo, denseCRow[d].gain)
                                // print(denseDRow[c].indNo, denseDRow[c].depNo, denseDRow[c].gain)
                                // print(denseDRow[d].indNo, denseDRow[d].depNo, denseDRow[d].gain)
                                
                                let rga = Rga(gain11: denseCRow[c], gain12: denseCRow[d], gain21: denseDRow[c], gain22: denseDRow[d])
                                /*
                                 let rga = Rga(ind1: denseCRow[c].indIndex,
                                 ind2: denseDRow[d].indIndex,
                                 dep1: denseCRow[c].depIndex,
                                 dep2: denseCRow[d].depIndex,
                                 gain11: denseCRow[c],
                                 gain12: denseCRow[d],
                                 gain21: denseDRow[c],
                                 gain22: denseDRow[d])
                                 // print(rga.ind1, rga.ind2, rga.dep1, rga.dep2, rga.rga)
                                 */
                                rgaAll.append(rga)
                            }
                        }
                    }
                }
            } // End for
            filterRgas(rgaLimit: rgaLimit)
            sortRga()
        }
        
        func sortRga() {
            print("model sorting rgas")
            switch sortRgaBy {
            case .rga:
                print("by rga")
                rgas.sort{
                    if $0.rga == $1.rga {
                        if $0.ind1Index == $1.ind1Index{
                            return $0.dep1Index < $1.dep1Index
                        }
                        return $0.ind1Index < $1.ind1Index
                    }
                    return $0.rga > $1.rga
                }
                // rgas.sort{$0.rga > $1.rga}
            case .mv:
                print("by ind")
                rgas.sort{
                    if $0.ind1Index == $1.ind1Index {
                        if $0.dep1Index == $1.dep1Index {
                            return $0.rga < $1.rga
                        }
                        return $0.dep1Index < $1.dep1Index
                    }
                    return $0.ind1Index < $1.ind1Index
                }
                /*
                 rgas.sort {
                 if $0.ind1Index != $1.ind1Index {
                 return $0.ind1Index < $1.ind1Index
                 } else {
                 return $0.ind2Index < $1.ind2Index
                 }
                 }
                 */
            case .cv:
                print("by dep")
                rgas.sort{
                    if $0.dep1Index == $1.dep1Index {
                        if $0.ind1Index == $1.ind1Index {
                            return $0.rga < $1.rga
                        }
                        return $0.ind1Index < $1.ind1Index
                    }
                    return $0.dep1Index < $1.dep1Index
                }
                
                /*
                 rgas.sort {
                 if $0.dep1Index != $1.dep1Index {
                 return $0.dep1Index < $1.dep1Index
                 } else {
                 return $0.dep2Index < $1.dep2Index
                 }
                 }
                 */
            }
            selectedRgaIndex = nil
            // filterRgas(rgaLimit: rgaLimit)
        }
        
        public func filterRgas(rgaLimit: Double) {
            print("model: filtering with rga limit \(rgaLimit)")
            rgas = rgaAll.filter{$0.rga >= rgaLimit}
            
        }
        
        
        public func indName(index: Int) -> String {
            var name = ""
            if index < inds.count {
                name = inds.filter{$0.index == index}[0].name
            }
            return name
        }
        
        public func indDescription(index: Int) -> String {
            var value = ""
            // print("ind:  \(index)")
            if index < inds.count {
                value = inds.filter{$0.index == index}[0].shortDescription
            }
            return value
        }
        
        public func depName(index: Int) -> String {
            var name = ""
            if index < deps.count {
                name = deps.filter{$0.index == index}[0].name
            }
            return name
        }
        
        public func depDescription(index: Int) -> String {
            var value = ""
            if index < deps.count {
                value = deps.filter{$0.index == index}[0].shortDescription
            }
            return value
        }
        
        
        
        public func calcRatios() {
            gainRatios.removeAll()
            if ratioByMvPair {
                let selectedMvs = inds.filter{$0.selected == true}
                if selectedMvs.count != 2 {
                    // Need 2 selected
                    print("Model: Need 2 MV's to calc ratio")
                    return
                } else {
                    let index1 = selectedMvs[0].index
                    let index2 = selectedMvs[1].index
                    selected1Name = indName(index: index1)
                    selected2Name = indName(index: index2)
                    let selectedGains1 = gains.filter{$0.indIndex == index1 && $0.gain != 0.0}
                    for gain in selectedGains1 {
                        let depIndex = gain.depIndex
                        let selectedGains2 = gains.filter{$0.depIndex == depIndex && $0.indIndex == index2 && $0.gain != 0.0}
                        if selectedGains2.count > 0 {
                            let depName =  self.depName(index: depIndex)
                            let ratio = GainRatio(selected1Index: index1, selected2Index: index2, varIndex: depIndex, varName: depName, selected1Gain: gain, selected2Gain: selectedGains2[0], selected1Denominator: true)
                            gainRatios.append(ratio)
                        }
                    }
                    /*
                     for ratio in gainRatios {
                     print("\(ratio.varIndex)  \(ratio.selected1Index)  \(ratio.selected2Index)  \(ratio.selected1Gain.gain)  \(ratio.selected2Gain.gain)  \(ratio.value)")
                     }
                     */
                    // print(ratios)
                }
                
            } else {
                // ratio by cv pairs
                let selectedDeps = deps.filter{$0.selected == true}
                if selectedDeps.count != 2 {
                    // Need 2 selected
                    return
                } else {
                    gainRatios.removeAll()
                    let index1 = selectedDeps[0].index
                    let index2 = selectedDeps[1].index
                    selected1Name = depName(index: index1)
                    selected2Name = depName(index: index2)
                    let selectedGains1 = gains.filter{$0.depIndex == index1 && $0.gain != 0.0}
                    for gain in selectedGains1 {
                        let indIndex = gain.indIndex
                        let selectedGains2 = gains.filter{$0.indIndex == indIndex && $0.depIndex == index2 && $0.gain != 0.0}
                        if selectedGains2.count > 0 {
                            
                            let indName = self.indName(index: indIndex)
                            
                            let ratio = GainRatio(selected1Index: index1, selected2Index: index2, varIndex: indIndex, varName: indName, selected1Gain: gain, selected2Gain: selectedGains2[0], selected1Denominator: true)
                            gainRatios.append(ratio)
                        }
                    }
                    /*
                     for ratio in gainRatios {
                     print("\(ratio.varIndex)  \(ratio.selected1Index)  \(ratio.selected2Index)  \(ratio.selected1Gain.gain)  \(ratio.selected2Gain.gain)  \(ratio.value)")
                     }
                     */
                    // print(ratios)
                }
            }
        }
        
        func sortRatios() {
            switch sortRatioBy {
            case .ratio:
                print("Model: sort ratios by ratio")
                gainRatios.sort{$0.value < $1.value}
            case .variable:
                print("Model: sort ratios by var")
                gainRatios.sort{$0.varIndex < $1.varIndex}
            }
            selectedRatioIndex = nil
        }
        
        public func writeDpaFile(url: URL) {
            var newDpaContents = ""
            
            var indIndex = 0
            var depIndex = 0
            var newLine = ""
            
            for (index, line) in dpaContents.enumerated()  {
                // if line.left(1) != "!" {
                // Not a comment
                let operation = line.trim().left(4).uppercased()
                switch operation {
                case ".IND":
                    print("indIndex \(indIndex) of \(inds.count)")
                    newLine = ".INDependent  \"\(inds[indIndex].name)\"  \"\(inds[indIndex].units)\"  \"\(inds[indIndex].shortDescription)\"  \(inds[indIndex].typicalMove)"
                    indIndex += 1
                case ".DEP":
                    print("depIndex \(depIndex) of \(deps.count)")
                    var rampText = ""
                    switch deps[depIndex].ramp {
                    case 1:
                        rampText = "RAMP"
                    case 2:
                        rampText = "PSE"
                    default:
                        break
                    }
                    newLine = ".DEPendent    \"\(deps[depIndex].name)\"  \"\(deps[depIndex].units)\"  \"\(deps[depIndex].shortDescription)\"  \"\(rampText)\""
                    depIndex += 1
                default:
                    newLine = line
                }
                if index < dpaContents.count - 1 {
                    newDpaContents.append("\(newLine)\r\n")
                } else {
                    newDpaContents.append("\(newLine)")
                }
                // }
            }
            do {
                try newDpaContents.write(to: url, atomically: false, encoding: String.Encoding.ascii)
            }
            catch {
                /* error handling here */
                print("error")
            }
            let _ = dialogOK("Dpa file saved.", info: url.path)
        }
        
        public func writeDpaFileRGA(url: URL) {
            // let newUniqueFileName = GetUniqueFileName()
            // let uniqueURL = UniqueFileURL()
            // let newDpaURL = uniqueURL.newURL(fileURL: dirURL.appendingPathComponent(dpaName))
            // let newDpaName = newUniqueFileName.getUniqueFileName(fullFileName: configPath + "/" + dpaName)
            let modelURL = url.deletingPathExtension()
            let newModelName = modelURL.lastPathComponent
            
            
            
            // print("configPath: " + configPath)
            // print("dpaName: " + dpaName)
            // print("newDpaName: " + newDpaURL.path)
            // print("newModelName: " + newModelName)
            
            var gain = Gain(indNo: 0, depNo: 0, originalGain: 0, adjustedGain: 0, adjustType: .none)
            var lastGain: Gain?
            var newDpaContents = ""
            var indName = ""
            var depName = ""
            var comment = ""
            
            // let saveURL = SaveURL()
            // saveURL.title = "dpa  File"
            // saveURL.message = "Enter or select dpa file."
            // saveURL.nameFieldStringValue = newDpaName
            // let dpaURL = dirURL.appendingPathComponent(newDpaName)
            // aveURL.fileTypes = ["dpa"]
            
            // print("path: \(configPath)")
            // print("name: \(controllerName)")
            // print("save: \(saveURL.nameFieldStringValue)")
            
            // if let url = saveURL.open(url: dpaURL) {
            
            
            for (i, line) in dpaContents.enumerated() {
                let operation = line.trim().left(4)
                if i > 5 && (operation == ".CUR" || operation == "!#==" ) {
                    // Line after header and is type.CURve
                    if let newGain = lastGain?.gain, let oldGain = lastGain?.originalGain {
                        if newGain != oldGain {
                            if deps[gain.depIndex].ramp > 0 {
                                newDpaContents.append("    .RSCale   \(newGain.precisionString)\r\n")
                                // print("appending GSCale for \(newGain)")
                            } else {
                                newDpaContents.append("    .GSCale   \(newGain.precisionString)\r\n")
                            }
                        }
                    }
                    let params = line.substring(from: 14).quotedWords()
                    // print(params)
                    if params.count > 2 {
                        indName = params[0]
                        depName = params[1]
                        comment = params[2]
                        let ind = inds.filter{$0.name.uppercased() == indName.uppercased()}
                        let indNo = ind[0].index
                        let dep = deps.filter{$0.name.uppercased() == depName.uppercased()}
                        let depNo = dep[0].index
                        let fGains = gains.filter{$0.indIndex == indNo && $0.depIndex == depNo}
                        gain = fGains[0]  // Gain for Curve in gains
                        // print(gain.originalGain, gain.adjustedGain, gain.gain, gain.adjustType)
                        if gain.adjustType == .set {
                            if comment.count > 2 {
                                comment += "\r"
                            }
                            // print("")
                            comment = "RGA Original Gain was \(gain.originalGain) and set to \(gain.gain)"
                            // print(comment)
                        }
                        if gain.adjustType == .calculated {
                            if comment.count > 2 {
                                comment += "\r"
                            }
                            // print("")
                            comment = "RGA Original Gain was \(gain.originalGain) and adjusted to \(gain.gain.precisionString)"
                            if let ratio = gain.gainRatio, let masterGain = gain.masterGain {
                                comment += " using (\(masterGain.indIndex), \(masterGain.depIndex))"
                                if gain.masterIsNumerator {
                                    comment += " / "
                                } else {
                                    comment += " * "

                                }
                                comment += "\(ratio)"
                            }
                            
                            print(comment)
                        }
                        newDpaContents.append(".CURve        \"\(indName)\"  \"\(depName)\"  \"\(comment)\"\r\n")
                    }
                    lastGain = gain
                    
                } else {
                    if operation == ".MOD" {
                        // print("found the model!")
                        let params = line.substring(from: 13).quotedWords()
                        // print(params.count)
                        if params.count > 2 {
                            // var newModelName = ""
                            comment = params[2]
                            
                            /*
                             if let i = newDpaName.indexBefore(".") {
                             newModelName = String(newDpaName[i...])
                             } else {
                             newModelName = params[0]
                             }
                             */
                            
                            newDpaContents.append(".MODel       \"" + newModelName + "-RGA\"  \"" + params[1] + "\"  \"" + comment + "\"\r\n")
                        } else {
                            newDpaContents.append("\(line)\r\n")
                        }
                        
                    } else {
                        // don't append GSCale if adjusted
                        if !(gain.adjustType != .none && operation == ".GSC") {
                            // print("operation: " + operation)
                            // print(gain.adjustType)
                            // print("go ahead and append")
                            newDpaContents.append("\(line)\r\n")
                        }
                        // print("operation: " + operation)
                        // print(gain.adjustType)
                    }
                }
            }
            
            do {
                try newDpaContents.write(to: url, atomically: false, encoding: String.Encoding.ascii)
            }
            catch {
                /* error handling here */
                print("error")
            }
            let _ = dialogOK("Dpa file saved.", info: url.path)
            //}
        }
        
        
        
        public init() {}
        
        
        
    }
