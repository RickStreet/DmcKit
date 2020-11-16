//
//  DMController.swift
//  DMCRead
//
//  Created by Richard Street on 11/8/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation
import StringKit
import DialogKit

public class DmcController {
    public var config = Config()
    public var model = Model()
    
    public var modelURL = URL.init(fileURLWithPath: "")
    public var configURL = URL.init(fileURLWithPath: "")
    public var loaded = false
    
    var dpaTypicalMoves = [Double]()
    var ccfTypicalMoves = [Double]()
    
    var excelInstalled = false
    var excelURLs = [URL]()
    
    
    public func loadAll(url: URL) {
        configURL = url
        print("reading config file...")
        config.readCCF(url: url)
        modelURL = self.configURL.deletingLastPathComponent()
        modelURL.appendPathComponent(self.config.modelName)
        print("reading model file \(modelURL.path)...")
        model.readMDL(url: self.modelURL)
        integrate()
        loaded = true
        print("load complete!")
        for i in 0..<model.inds.count {
            print("dpa typmov \(model.inds[i].typicalMove)")
            dpaTypicalMoves.append(model.inds[i].typicalMove)
        }
        for i in 0..<config.inds.count {
            print("ccf typmov \(config.inds[i].typmov.doubleValue)")
            ccfTypicalMoves.append(config.inds[i].typmov.doubleValue)
        }
    }
    
    public func typicalMovesByDPA() {
        for i in 0..<model.inds.count {
            model.inds[i].typicalMove = dpaTypicalMoves[i]
        }
        model.getGainWindows()
    }
    
    public func typicalMovesByCCF() {
        for i in 0..<model.inds.count {
            model.inds[i].typicalMove = ccfTypicalMoves[i]
        }
        model.getGainWindows()
    }
    
    func integrate() {
        print("Integrating...")
        model.numberMvs = config.mvs.count
        for i in 0..<config.inds.count {
            model.inds[i].shortDescription = config.inds[i].shortDescription
            config.inds[i].longDescription = model.inds[i].longDescription
        }
        
        for i in 0..<config.cvs.count {
            model.deps[i].shortDescription = config.cvs[i].shortDescription
            config.cvs[i].longDescription = model.deps[i].longDescription
        }
        /*
         print()
         for ind in model.inds {
         print("\(ind.name),   \(ind.longDescription),  \(ind.shortDescription)")
         }
         for dep in model.deps {
         print("\(dep.name),   \(dep.longDescription),   \(dep.shortDescription),   \(dep.gainWindow)")
         }
         */
        print("Done integrating.")
    }
    
    public func getSubControllers() -> [SubController] {
        
        var subs = [SubController]()
        let mainController = SubController()
        mainController.name = model.baseName
        mainController.inds = model.inds
        mainController.deps = model.deps
        mainController.gains = model.gains
        subs.append(mainController)
        
        if config.subs.count > 0 {
            
            var allCvSubNames = [(cv: String, sub: String)]()
            
            for cv in config.cvs {
                let cvNames = cv.cvinsb.value.components(separatedBy: "&")
                for sub in cvNames {
                    allCvSubNames.append((cv.name, sub))
                }
            }
            for sub in config.subs {
                let subController = SubController()
                subController.name = sub.name
                let subCvNames = allCvSubNames.filter{$0.1 == sub.name}.map{$0.0}  // list od dep names in sub
                for cvName in subCvNames {
                    subController.deps.append(contentsOf: model.deps.filter{$0.name == cvName})
                }
                for dep in subController.deps {
                    subController.gains += model.gains.filter{$0.depIndex == dep.index}
                }
                var indInices = subController.gains.map{$0.indIndex}
                indInices = Array(Set(indInices)) // Get ride of duplicate indices
                indInices.sort{$0 < $1}
                for index in indInices {
                    subController.inds.append(model.inds[index])
                }
                subs.append(subController)
            }
        }
        return subs
    }
    
    /// Writes new dpa file using ccf descriptions and move sizes
    /// - Parameter url: file location to write to
    public func wrireDpaFile(url: URL) {
        
        for i in 0..<model.inds.count {
            print("\(i), \(model.inds[i].name), \(config.inds[i].name)")
        }
        
        // let modelURL = url.deletingPathExtension()
        // let newModelName = modelURL.lastPathComponent
        var newDpaContents = ""
        for (_, line) in model.dpaContents.enumerated() {
            let operation = line.trim().left(4)
            var params = [String]()
            var tag = ""
            switch operation {
            case ".IND":
                print("IND \(line)")
                print()
                params = line.components(separatedBy: "  ")
                print("params")
                print(params)
                print()
                if params.count > 1 {
                    tag = params[1].trimQuotes()
                    print("tag \(tag)")
                }
                let inds = config.inds.filter{$0.name.uppercased() == tag.uppercased()}
                if !inds.isEmpty {
                    let ind = inds[0]
                    let newLine = "\(params[0])  \"\(tag)\"  \(params[2])  \"\(ind.shortDescription)\"  \(ind.typmov.doubleValue)"
                    print(newLine)
                    newDpaContents += newLine + "\r\n"
                } else {
                    print("Cannot get ind \(tag) from config")
                }
            case ".DEP":
                print("DEP \(line)")
                print()
                params = line.components(separatedBy: "  ")
                print("params")
                print(params)
                print()
                if params.count > 1 {
                    tag = params[2].trimQuotes()
                    print("tag \(tag)")
                }

                let deps = config.cvs.filter{$0.name.uppercased() == tag.uppercased()}
                if !deps.isEmpty {
                    let dep = deps[0]
                    let newLine = "\(params[0])  \"\(tag)\"  \(params[2].trimQuotes())  \"\(dep.shortDescription)\"  \"\(params[4])\""
                    newDpaContents += newLine + "\r\n"

                    print(newLine)
                } else {
                    print("Cannot get dep \(tag) from config")
                }

            default:
                newDpaContents += line + "\r\n"
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
    }

    
    public init() {}
}
