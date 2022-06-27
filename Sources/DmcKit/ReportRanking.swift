//
//  ReportRanking.swift
//  DMCTuner
//
//  Created by Rick Street on 4/9/18.
//  Copyright © 2018 Rick Street. All rights reserved.
//

import Cocoa
import StringKit

public class ReportRanking {
    public var controller = DmcController()

    let tabParagraphStyle = NSMutableParagraphStyle()

    var model: String {
        let value = controller.model.baseName
        if let index = value.index(of: ".") {
            // return value.substring(to: index)
            return String(value[..<index])
        }
        return value
    }
    
    var controllerName: String {
        return controller.config.baseName
    }


    
    public func write() {
        let cvs = controller.config.cvs
        var rankings = [Ranking]()

        tabParagraphStyle.tabStops = [NSTextTab(textAlignment: NSTextAlignment.right, location: 40.0, options: [:]),
                                   NSTextTab(textAlignment: NSTextAlignment.left, location: 50.0, options: [:]),
                                   NSTextTab(textAlignment: NSTextAlignment.left, location: 135.0, options: [:]),
                                   NSTextTab(textAlignment: NSTextAlignment.left, location: 275.0, options: [:])]
        
        tabParagraphStyle.lineSpacing = 2.5
        
        let titleAttribute = [ NSAttributedString.Key.foregroundColor: navy, NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-BoldItalic", size: 20.0)!]
        let headerAttribute = [ NSAttributedString.Key.foregroundColor: navy, NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-Italic", size: 12.0)!]
        let normalAttribute = [ NSAttributedString.Key.foregroundColor: black, NSAttributedString.Key.font: NSFont(name: "HelveticaNeue", size: 10.0)!, .paragraphStyle: tabParagraphStyle]
        // let smallAttribute = [ NSAttributedStringKey.foregroundColor: navy, NSAttributedStringKey.font: NSFont(name: "HelveticaNeue", size: 6.0)!]

        for cv in cvs {
            rankings.append(Ranking(index: cv.index, name: cv.name, description: cv.shortDescription, rankLimitType: "CV Lower", rankType: cv.cvlpql.intValue, rank: cv.cvrankl.intValue))
            rankings.append(Ranking(index: cv.index, name: cv.name, description: cv.shortDescription, rankLimitType: "CV Upper", rankType: cv.cvlpqu.intValue, rank: cv.cvranku.intValue))
            if cv.etcswc.intValue > 0 {
                rankings.append(Ranking(index: cv.index, name: cv.name, description: cv.shortDescription, rankLimitType: "ET Lower", rankType: cv.etclpql.intValue, rank: cv.etcrl.intValue))
                rankings.append(Ranking(index: cv.index, name: cv.name, description: cv.shortDescription, rankLimitType: "ET Upper", rankType: cv.etclpqu.intValue, rank: cv.etcru.intValue))
            }
        }
        rankings.sort(){$0.sortVar < $1.sortVar}
        
        let contents = NSMutableAttributedString(string: "\(controllerName) Ranking Report\n".capitalized, attributes: titleAttribute)
        var rank = 0
        for ranking in rankings {
            if ranking.rank != rank {
                // Write Header
                let headerString = NSAttributedString(string: "\n\(ranking.rank) Ranking\n", attributes: headerAttribute)
                rank = ranking.rank
                contents.append(headerString)
            }
            // let tag = "\(ranking.name),".padding(toLength: 16, withPad: " ", startingAt: 0)
            // let description = "\(ranking.description)".padding(toLength: 22, withPad: " ", startingAt: 0)
            let line = NSAttributedString(string: "\t\(ranking.index + 1).\t\(ranking.name)\t\(ranking.description)\t\(ranking.rankLimitType)\n", attributes: normalAttribute)
            contents.append(line)
        }
        print(contents)
        
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [.documentType: NSAttributedString.DocumentType.rtf]
        

        var rtfData = Data()
        do {
            rtfData = try contents.data(from: NSRange(location: 0, length: contents.length), documentAttributes: documentAttributes)
        } catch {
            print("Error converting string to rtf data")
        }
        
        var url = controller.configURL.deletingLastPathComponent()
        url.appendPathComponent("\(controller.model.baseName)_Ranking.rtf")
            print(url.path)
            
            do {
                // print(newCcfContents)
                print("writing to \(url.path)")
                try rtfData.write(to: url)
            }
            catch {
                /* error handling here */
                print("error writting rtf file")
            }
            NSWorkspace.shared.open(url)
        
        

    }
    public init() {}


}

