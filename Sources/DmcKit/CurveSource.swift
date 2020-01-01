//
//  CurveSource.swift
//  DMCTuner
//
//  Created by Rick Street on 8/23/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Cocoa
import StringKit

public class CurveSource {
    public var type = ""
    public var indIndex = 0
    public var depIndex = 0
    
    public var depSort: Int {
        return depIndex * 10000 + indIndex
    }
    
    public var indSort: Int {
        return indIndex * 10000 + depIndex
    }
    
    public var indName = ""
    public var depName = ""
    public var sourceInd = ""
    public var sourceDep = ""
    public var sourceCase = ""
    public var sourceCurve = ""
    public var convoluteIndName = ""
    public var convoluteCase = ""
    public var convoluteCurve = ""
    public var deadtime = 0.0
    public var tau = 0.0
    public var damp = 0.0
    public var gain = 0.0
    
    var sources = [CurveSourceType]()
    
    public var description: NSMutableAttributedString {
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
    public init() {}

}
