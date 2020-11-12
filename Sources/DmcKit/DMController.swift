//
//  DMController.swift
//  DMCRead
//
//  Created by Richard Street on 11/8/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation
import StringKit

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
        mainController.name = model.name
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
    
    public init() {}
}
