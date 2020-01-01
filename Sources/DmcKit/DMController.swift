//
//  DMController.swift
//  DMCRead
//
//  Created by Richard Street on 11/8/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation
import StringKit

public class DMController {
    public var config = Config()
    public var model = Model()
    
    public var modelURL = URL.init(fileURLWithPath: "")
    public var configURL = URL.init(fileURLWithPath: "")
    public var loaded = false
    
    var excelInstalled = false
    var excelURLs = [URL]()
    
    
    public func loadAll(url: URL) {
        configURL = url
        config.readCCF(url: url)
        modelURL = self.configURL.deletingLastPathComponent()
        modelURL.appendPathComponent(self.config.modelName)
        model.readMDL(url: self.modelURL)
        integrate()
        loaded = true

    }
    
    func integrate() {
        // print("Integrating...")
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
        // print("Done integrating.")
    }
    
    public init() {
        self.init()
        loaded = false
    }
    
    /*
    func getSubControllerGains() {
        excelURLs.removeAll()

        let buildPercentGainsExcel = BuildPercentGainsExcel ()
        buildPercentGainsExcel.cvs = config.cvs
        buildPercentGainsExcel.inds = config.inds
        buildPercentGainsExcel.gains = model.gains
        // print("Excel file:")
        // print(config.configURL.path)
        let fileName = config.configURL.deletingLastPathComponent().path + "/" + config.baseName.capitalized + "_pGains.xlsx"
        buildPercentGainsExcel.outputFileName = fileName
        // print(fileName)
        buildPercentGainsExcel.run()
        excelURLs.append(URL(fileURLWithPath: fileName))
 

        if config.subs.count < 1 {
            return
        }
        var allCvSubs = [(Section, String)]()
        
        for cv in config.cvs {
            let subs = cv.cvinsb.value.components(separatedBy: "&")
            for sub in subs {
                allCvSubs.append((cv, sub))
            }
        }
        
        // print("Getting sub gains...")
        var subGains = [Gain]()
        for sub in config.subs {
            subGains.removeAll()
            let subCvs = allCvSubs.filter{$0.1 == sub}.map{$0.0} // Get cvs in sub
            // let subCvs = config.cvs.filter{$0.cvinsb.value.contains(target: sub)}
            // print()
            // print(sub)
            for cv in subCvs {
                subGains += model.gains.filter{$0.depIndex == cv.index}
                // print(cv.index)
            }
            var inds = subGains.map{$0.indIndex}
            inds = Array(Set(inds))
            inds.sort{$0 < $1}
            var subInds = [Section]()
            for ind in inds {
                subInds.append(config.inds[ind])
            }
            let fileName = config.configURL.deletingLastPathComponent().path + "/" + config.baseName.capitalized + "_" + sub + "_pGains.xlsx"
            buildPercentGainsExcel.outputFileName = fileName
            buildPercentGainsExcel.cvs = subCvs
            buildPercentGainsExcel.inds = subInds
            buildPercentGainsExcel.gains = subGains
            buildPercentGainsExcel.subName = sub
            buildPercentGainsExcel.run()
            excelURLs.append(URL(fileURLWithPath: fileName))
        }
        // print("done getting sub gains.")
    }
    */
    
}
