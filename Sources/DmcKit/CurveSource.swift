//
//  CurveSource.swift
//  DMCTuner
//
//  Created by Rick Street on 8/23/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Cocoa

class CurveSource {
    var type = ""
    var indIndex = 0
    var depIndex = 0
    
    var depSort: Int {
        return depIndex * 10000 + indIndex
    }
    
    var indSort: Int {
        return indIndex * 10000 + depIndex
    }
    
    var indName = ""
    var depName = ""
    var sourceInd = ""
    var sourceDep = ""
    var sourceCase = ""
    var sourceCurve = ""
    var convoluteIndName = ""
    var convoluteCase = ""
    var convoluteCurve = ""
    var deadtime = 0.0
    var tau = 0.0
    var damp = 0.0
    var gain = 0.0
    
    var sources = [CurveSourceType]()
    
    var description: NSMutableAttributedString {
        let description = NSMutableAttributedString()
        
        let normalParagraphStyle = NSMutableParagraphStyle()
        normalParagraphStyle.tabStops = [NSTextTab(textAlignment: NSTextAlignment.right, location: 60.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 70.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 165.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 275.0, options: [:])]
        normalParagraphStyle.lineSpacing = 2.5
        
        let convParagraphStyle = NSMutableParagraphStyle()
        convParagraphStyle.tabStops = [NSTextTab(textAlignment: NSTextAlignment.left, location: 60.0, options: [:]),
                                       NSTextTab(textAlignment: NSTextAlignment.left, location: 70.0, options: [:]),
                                       NSTextTab(textAlignment: NSTextAlignment.right, location: 130.0, options: [:]),
                                       NSTextTab(textAlignment: NSTextAlignment.left, location: 135.0, options: [:])]
        //convParagraphStyle.lineSpacing = 2.5

        let normalAttribute = [ NSAttributedString.Key.foregroundColor: black,
                                NSAttributedString.Key.font: NSFont(name: "HelveticaNeue", size: 10.0)!,
                                .paragraphStyle: normalParagraphStyle]
        
        let convAttributes = [ NSAttributedString.Key.foregroundColor: black,
                               NSAttributedString.Key.font: NSFont(name: "HelveticaNeue", size: 10.0)!,
                               .paragraphStyle: convParagraphStyle]
        

        
        // let sources = curve.sources
        
        for source in sources {
            // print("getting descriptiopn")
            // print(source)
            switch source {
            case .replace (let ind, let dep, let sourceCase, let sourceCurve):
                let sourceString = NSAttributedString(string: "\t\t\(sourceCase)   \(sourceCurve)\n", attributes: normalAttribute)
                description.append(sourceString)
                if indName != sourceInd {
                    let notMatchString = NSAttributedString(string: "\t\tSource Ind: \(ind)\n", attributes: normalAttribute)
                    description.append(notMatchString)
                }
                if depName != sourceDep {
                    let notMatchString = NSAttributedString(string: "\t\tSource Dep: \(dep)\n", attributes: normalAttribute)
                    description.append(notMatchString)
                }
            case .unity:
                let aString = NSAttributedString(string: "\t\tUnity Curve\n", attributes: normalAttribute)
                description.append(aString)
            case .zero:
                let aString = NSAttributedString(string: "\t\tZero Curve\n", attributes: normalAttribute)
                description.append(aString)
            case .first (let deadtime, let tau, let gain):
                let aString = NSAttributedString(string: "\t\tFirst Order:  Deadtime: \(deadtime),  Tau: \(tau),   Gain: \(gain)\n", attributes: normalAttribute)
                description.append(aString)
            case .second (let deadtime, let tau, let damp, let gain):
                let aString = NSAttributedString(string: "\t\tSecond Order:  Deadtime: \(deadtime),  Tau: \(tau),   Damping Coef: \(damp),   Gain: \(gain)\n", attributes: normalAttribute)
                description.append(aString)
            case .convolute (let model, let ind, let interModel, let dep, let interInd):
                let aString = NSAttributedString(string: "\t\tConvolute:\n\t\t\tModel:\t\(model)\n\t\t\tInd:\t\(ind)\n\t\t\tInter Model:\t\(interModel)\n\t\t\tDep:\t\(dep)\n\t\t\tInter Ind:\t\(interInd)\n", attributes: convAttributes)
                description.append(aString)
            }
        }

        return description
    }

}
