//
//  Model.swift
//  DMCRead
//
//  Created by Richard Street on 11/7/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation

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
    
    public var mdlURL = URL.init(fileURLWithPath: "")
    public var dpaURL = URL.init(fileURLWithPath: "")
    
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
            let result = dialogOK("Missing Model file (*.mdl).  Please make sure it is in the same directory as the controller ccf file", text: "Missing .mdl File")
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
        
        
        /*
        print("noInds \(noInds)")
        print("noDeps \(noDeps)")
        print("noCoefs \(noCoefs)")
        print("timeToSS \(timeToSS)")
        print("numberCoefLines \(numberCoefLines)")
        print("noCurves \(gains.count)")
        print()
        */
        
        getDPA()
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
    
    func getDPA() {
        let modelFile = mdlURL.lastPathComponent
        name = modelFile
        if var dpaFile = modelFile.fileBase() {
            baseName = dpaFile
            dpaFile += ".dpa"
            dpaName = dpaFile
            dpaURL = mdlURL.deletingLastPathComponent().appendingPathComponent(dpaFile)
            // print("dpaURL \(dpaURL.path)")
        }
        let fm = FileManager.default
        
        if !fm.fileExists(atPath: dpaURL.path) {
            let answer = dialogOK("Missing dpa file (*.mdl).  Please make sure it is in the same directory as the controller ccf file", text: "Missing .dpa File")
            print(answer)
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
        // print(lines)
        
        // get long descriptions and step size for Ind
        lineNo = 7
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
        // print("getting curve sources:")
        // print("line count", dpaContents.count)
        // print("line", lineNo)
        // print(dpaContents[lineNo])
        while lineNo < dpaContents.count {
            if dpaContents[lineNo].hasPrefix(".CUR") {
                curveSources.append(CurveSource())
                let curveSource = curveSources.last!
                let tags = dpaContents[lineNo].substring(from: 14).quotedWords()
                curveSource.indName = tags[0]
                curveSource.depName = tags[1]
                curveSource.indIndex = indNo(name: tags[0])
                curveSource.depIndex = depNo(name: tags[1])
                // print("Curve", tags[0], tags[1])
                if lineNo < dpaContents.count - 1 {
                    lineNo += 1
                }
                // print("line after CUR", lineNo)
                // print(dpaContents[lineNo])

                while !dpaContents[lineNo].hasPrefix(".CUR"){
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
                }
            }
            // lineNo += 1
            // print("line end file while", lineNo)
            // print(dpaContents[lineNo])
        }
        // print("done getting curvesources")
        // print()
        getGainWindows()
        
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
    

    


}
