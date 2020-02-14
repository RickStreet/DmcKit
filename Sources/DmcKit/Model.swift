//
//  Model.swift
//  DMCRead
//
//  Created by Richard Street on 11/7/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation
import StringKit
import DialogKit

public class Model {
    public var name = ""
    public var baseName = ""
    public var dpaName = ""
    public var noInds = 0
    public var noDeps = 0
    public var noCoefs = 0
    public var timeToSS = 0.0
    public var numberCoefLines = 0
    public var deps = [Dep]()
    public var inds = [Ind]()
    public var gains = [Gain]()
    public var curveSources = [CurveSource]()
    var dpaContents = [String]()
    public var dpaLoaded = false
    
    public var mdlURL = URL.init(fileURLWithPath: "")
    public var dpaURL = URL.init(fileURLWithPath: "")
    
    // RGA Properties
    public var cRgas = [Rga]()  // Calculated rga's
    public var rgas = [Rga]()   // Filtered rga's
    public var numberMvs = 0
    public var selected1Denominator = true
    public var selectedRgaIndex = 0
    public var selected1Name = "" // used for gainRatio Calc
    public var selected2Name = "" // used for gainRatio Calc
    public var selectedRatioIndex = 0
    public var excludeByMV = true // used for exclude VC

    public var ratioByMvPair = true
    // public var ratios = [GainRatio]()
    
    public var gainRatios = [GainRatio]()

    
    func clear() {
        deps.removeAll()
        inds.removeAll()
        gains.removeAll()
        curveSources.removeAll()
        dpaContents.removeAll()
    }
    
    public func readMDL(url: URL) {
        clear()
        // check if mdl file exists
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            let result = dialogOK("Missing Model File (*.mdl).", info: "Please make sure it is in the same directory as the controller ccf file")
            print(result)
            return
        }
        mdlURL = url
        
        
        var contents = ""
        do {
            // Read the file contents
            contents = try String(contentsOf: url, encoding: .ascii)
        } catch let error as NSError {
            print("Failed reading from URL: \(url.path), Error: " + error.localizedDescription)
            return
        }
        // print(contents)
        
        let lines = contents.components(separatedBy: "\r\n")
        
        var lineNo = 2
        if let no = lines[lineNo].integerValue {
            noInds = no
        }
        
        lineNo = 3
        if let no = lines[lineNo].integerValue {
            noDeps = no
        }
        
        
        lineNo = 4
        if let no = lines[lineNo].integerValue {
            noCoefs = no
        }
        
        lineNo = 6
        if let no = lines[lineNo].doubleValue {
            timeToSS = no
        }
        // print("no min to SS from Model \(timeToSS)")
        
        let NumberCoefLines = noCoefs / 5 + noCoefs % 5 // Number of lines for dynamic curve
        // print("Coef lines   \(NumberCoefLines)")
        
        
        lineNo = 8
        // Get Inds
        var indNo = 0
        while lines[lineNo].substring(with: 5..<10) == "-999." {
            // print("Ind Tags")
            let tag = lines[lineNo].substring(with: 36..<49).trim()
            let units = lines[lineNo].substring(with: 49..<61).trim()
            inds.append(Ind(no: indNo, name: tag, shortDescription: "", units: units))
            // inds.append((indNo, tag, units))
            // print("\(indNo) Ind: \(tag)  \(units)")
            lineNo += 1
            indNo += 1
        }
        // print(inds)
        
        // Get Deps
        var depNo = 0
        while lines[lineNo].substring(with: 8..<16) == "0.000000" {
            let tag = lines[lineNo].substring(with: 36..<49).trim()
            let units = lines[lineNo].substring(with: 49..<61).trim()
            let ramp =  lines[lineNo].substring(with: 66..<67)
            // print("ramp: \(ramp)")
            deps.append(Dep(no: depNo, name: tag, shortDescription: "", units: units, ramp: ramp.integerValue ?? 0))
            lineNo += 1
            depNo += 1
            // print("Dep: \(tag) \(units)")
        }
        // print(deps)
        
        // Get Gains
        // lineNo += 1 // Get to dep line for gains
        // print("getting gains")
        for dep in deps {
            // let tDep = lines[lineNo].substring(with: 0..<13)
            lineNo += 11
            for ind in inds {
                // let tInd = lines[lineNo].substring(with: 0..<13)
                let textGain = lines[lineNo].substring(with: 46..<69)
                // print("Dep: \(tDep) \(tInd) textGain: \(textGain)")
                var originalGain = textGain.doubleValue!
                
                // If SS gain is not 0, append gain
                if originalGain != 0.0 {
                    lineNo += NumberCoefLines + 1
                    // print("number Gain: \(numberGain)")
                    gains.append(Gain(indNo: ind.index, depNo: dep.index, originalGain: originalGain))
                    // print("Dep: \(tDep)  Ind: \(tInd) textGain: \(textGain)")
                } else {
                    // scan coefs to check for dynamic curve
                    lineNo += 1  // at first line of coefs
                    var dynamicCurve = false
                    for _ in 1 ... NumberCoefLines {
                        let numbers = getNumberArray(lines[lineNo])
                        // print("\(numbers)")
                        for number in numbers {
                            if number != 0.0 {
                                dynamicCurve = true
                                // print("Dynamic Curve")
                            }
                        }
                        lineNo += 1
                    }
                    // lineNo++
                    if dynamicCurve {
                        originalGain = 0.0
                        // print("number Gain: \(numberGain)")
                        gains.append(Gain(indNo: ind.index, depNo: dep.index, originalGain: 0.0))
                        // print("Dynamic Dep: \(dep.no)  Ind: \(ind.no) textGain: \(textGain)")
                        
                    }
                }
            }
        } // Finished reading mdl
        
        
        
        print("noInds \(noInds)")
        print("noDeps \(noDeps)")
        print("noCoefs \(noCoefs)")
        print("timeToSS \(timeToSS)")
        print("numberCoefLines \(numberCoefLines)")
        print("noCurves \(gains.count)")
        print()
        
        print("reading dpa file")
        readDPA()
        print("Completely done with dpa!")
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
                let indName = tags[0]
                let depName = tags[1]
                curveSource.indName = indName
                curveSource.depName = depName
                let comment = tags[2]
                
                if comment.uppercased().contains("RGA ORIGINAL GAIN WAS") {
                    // print("Modified Gain")
                    if let i1 = comment.indexAfter("was "), let i2 = comment.indexBefore(" and"), let i3 = comment.indexAfter(" to") {
                        let gainOriginal = String(comment[i1...i2]).doubleValue
                        let gainAdjusted = String(comment[i3...]).doubleValue
                        let updateInd = inds.filter{$0.name == indName}
                        let indNo = updateInd[0].index
                        let updateDep = deps.filter{$0.name == depName}
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
                                gain[0].adjustType = .adjusted
                            }
                        }
                    }
                }

                
                
                

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
        print("getting GainWindows...")
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
        print("done getting GainWindows.")
    }
    
    func getCurveType(_ line: String) -> String {
        if line.count < 8 || line.hasPrefix("!") {
            return "none"
        } else {
            return line.left(8)
        }
    }
    public func depNo(name: String) -> Int {
        let dep = deps.filter{$0.name == name}
        if dep.count > 0 {
            return dep[0].index
        } else {
            return 0
        }
    }
    
    public func indNo(name: String) -> Int {
        let ind = inds.filter{$0.name == name}
        if ind.count > 0 {
            return ind[0].index
        } else {
            return 0
        }
    }
    
    public func calcRgas() {
        cRgas.removeAll()
        let nonZeroGains = gains.filter{$0.gain != 0.0}
        
        if numberMvs < 2 {
            return
        }
        
        var denseCRow = [Gain]() // gains for ind 1 where cv in both ind 1 and ind 2
        var denseDRow = [Gain]() // gains for ind 2 where cv in both ind 1 and ind 2
        
        var mvIndices = [Int]()
        print("number Mvs \(numberMvs)")
        for i in 0 ..< numberMvs {
            if !inds[i].excluded {
                mvIndices.append(inds[i].index)
                print("appended mv \(inds[i].index) to rga mvIndices.")
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
                            
                            let rga = Rga(ind1: denseCRow[c].indIndex, ind2: denseDRow[d].indIndex, dep1: denseCRow[c].depIndex, dep2: denseCRow[d].depIndex, gain11: denseCRow[c].gain, gain12: denseCRow[d].gain, gain21: denseDRow[c].gain, gain22: denseDRow[d].gain)
                            print(rga.ind1, rga.ind2, rga.dep1, rga.dep2, rga.rga)
                            cRgas.append(rga)
                        }
                    }
                }
            }
        }
        cRgas.sort{$0.rga > $1.rga}
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
        print("ind:  \(index)")
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
    
    public func filterRgas(rgaLimit: Double) {
        rgas = cRgas.filter{$0.rga >= rgaLimit}
        
    }



    public func calcRatios() {
        gainRatios.removeAll()
        if ratioByMvPair {
            let selectedMvs = inds.filter{$0.selected == true}
            if selectedMvs.count != 2 {
                // Need 2 selected
                print("Need 2 MV's to calc ratio")
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
                for ratio in gainRatios {
                    print("\(ratio.varIndex)  \(ratio.selected1Index)  \(ratio.selected2Index)  \(ratio.selected1Gain.gain)  \(ratio.selected2Gain.gain)  \(ratio.value)")
                }
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
                for ratio in gainRatios {
                    print("\(ratio.varIndex)  \(ratio.selected1Index)  \(ratio.selected2Index)  \(ratio.selected1Gain.gain)  \(ratio.selected2Gain.gain)  \(ratio.value)")
                }
                // print(ratios)
            }
        }
        
    }

    public func writeDpaFile(url: URL) {
        // let newUniqueFileName = GetUniqueFileName()
        // let uniqueURL = UniqueFileURL()
        // let newDpaURL = uniqueURL.newURL(fileURL: dirURL.appendingPathComponent(dpaName))
        // let newDpaName = newUniqueFileName.getUniqueFileName(fullFileName: configPath + "/" + dpaName)
        let newModelName = url.lastPathComponent
        
        
        
        // print("configPath: " + configPath)
        print("dpaName: " + dpaName)
        // print("newDpaName: " + newDpaURL.path)
        print("newModelName: " + newModelName)
        
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
                if let newGain = lastGain?.gain, let oldGain = lastGain?.originalGain {
                    if newGain != oldGain {
                        newDpaContents.append("    .GSCale   \(newGain.precisionString)\r\n")
                        print("appending GSCale for \(newGain)")
                    }
                }
                
                let params = line.substring(from: 14).quotedWords()
                // print(params)
                if params.count > 2 {
                    indName = params[0]
                    depName = params[1]
                    comment = params[2]
                    let ind = inds.filter{$0.name == indName}
                    let indNo = ind[0].index
                    let dep = deps.filter{$0.name == depName}
                    let depNo = dep[0].index
                    let fGains = gains.filter{$0.indIndex == indNo && $0.depIndex == depNo}
                    gain = fGains[0]  // Gain for Curve in gains
                    // print(gain.originalGain, gain.adjustedGain, gain.gain, gain.adjustType)
                    if gain.adjustType == .set {
                        if comment.count > 2 {
                            comment += "\r"
                        }
                        print("")
                        comment = "RGA Original Gain was \(gain.originalGain) and set to \(gain.gain)"
                        print(comment)
                    }
                    if gain.adjustType == .adjusted {
                        if comment.count > 2 {
                            comment += "\r"
                        }
                        print("")
                        comment = "RGA Original Gain was \(gain.originalGain) and adjusted to \(gain.gain.precisionString)"
                        print(comment)
                    }
                    newDpaContents.append(".CURve        \"\(indName)\"  \"\(depName)\"  \"\(comment)\"\r\n")
                }
                lastGain = gain
                
            } else {
                if operation == ".MOD" {
                    print("found the model!")
                    let params = line.substring(from: 13).quotedWords()
                    print(params.count)
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
                        print("operation: " + operation)
                        print(gain.adjustType)
                        print("go ahead and append")
                        newDpaContents.append("\(line)\r\n")
                    }
                    print("operation: " + operation)
                    print(gain.adjustType)
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
