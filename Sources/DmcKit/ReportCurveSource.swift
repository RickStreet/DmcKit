//
//  ReportCurveSource.swift
//  DMCTuner
//
//  Created by Rick Street on 4/9/18.
//  Copyright © 2018 Rick Street. All rights reserved.
//

import Cocoa
import NSStringKit

public class ReportCurveSource {
    public var controller = DmcController()
    var curveSources = [CurveSource]()
    
    public var sortByDep = true
    
    public let contents = NSMutableAttributedString()
    
    @available(macOS 11.0, *)
    public func getContents() {
        
        curveSources = controller.model.curveSources
        contents.deleteCharacters(in: NSRange(location: 0, length: contents.length))
        
        
        
        // Set Styles
        
        let headerParagraphStyle = NSMutableParagraphStyle()
        headerParagraphStyle.tabStops = [NSTextTab(textAlignment: NSTextAlignment.right, location: 30.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 40.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 135.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 275.0, options: [:])]
        // headerParagraphStyle.lineSpacing = 2.5
        
        
        let normalParagraphStyle = NSMutableParagraphStyle()
        normalParagraphStyle.tabStops = [NSTextTab(textAlignment: NSTextAlignment.right, location: 60.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 70.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 165.0, options: [:]),
                                         NSTextTab(textAlignment: NSTextAlignment.left, location: 275.0, options: [:])]
        normalParagraphStyle.lineSpacing = 2.5
        
        /*
         let convParagraphStyle = NSMutableParagraphStyle()
         convParagraphStyle.tabStops = [NSTextTab(textAlignment: NSTextAlignment.left, location: 60.0, options: [:]),
         NSTextTab(textAlignment: NSTextAlignment.left, location: 70.0, options: [:]),
         NSTextTab(textAlignment: NSTextAlignment.right, location: 130.0, options: [:]),
         NSTextTab(textAlignment: NSTextAlignment.left, location: 135.0, options: [:])]
         //convParagraphStyle.lineSpacing = 2.5
         */
        
        let titleAttribute = [ NSAttributedString.Key.foregroundColor: dynamicNavy,
                               NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-BoldItalic", size: 20.0)!]
        
        let headerAttribute = [ NSAttributedString.Key.foregroundColor: dynamicNavy,
                                NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-Italic", size: 12.0)!,
                                .paragraphStyle: headerParagraphStyle]
        
        let normalAttribute = [ NSAttributedString.Key.foregroundColor: NSColor.textColor,
                                NSAttributedString.Key.font: NSFont(name: "HelveticaNeue", size: 10.0)!,
                                .paragraphStyle: normalParagraphStyle]
        /*
         let convAttributes = [ NSAttributedString.Key.foregroundColor: NSColot.textColor,
         NSAttributedString.Key.font: NSFont(name: "HelveticaNeue", size: 10.0)!,
         .paragraphStyle: convParagraphStyle]
         */
        
        // let smallAttribute = [ NSAttributedStringKey.foregroundColor: dynamicNavy, NSAttributedStringKey.font: NSFont(name: "HelveticaNeue", size: 6.0)!]
        
        let blankLine = NSMutableAttributedString(string: "\n")
        
        // let contents = NSMutableAttributedString()
        
        if sortByDep {
            curveSources.sort{$0.depSort < $1.depSort}
            let titleString = NSAttributedString(string: "\(controller.config.baseName) Curve Source Sorted by Dependent\n".capitalized, attributes: titleAttribute)
            contents.append(titleString)


        } else {
            curveSources.sort{$0.indSort < $1.indSort}
            let titleString = NSAttributedString(string: "\(controller.config.baseName) Curve Source Sorted by Independent\n".capitalized, attributes: titleAttribute)
            contents.append(titleString)

        }
        
        // Model Notes
        let noteTitleString = NSAttributedString(string: "\nModel Notes\n", attributes: headerAttribute)
        contents.append(noteTitleString)
        let noteString = NSAttributedString(string: "\(controller.model.modelNotes)\n", attributes: normalAttribute)
        contents.append(noteString)

        
        if sortByDep {
            var depLast = ""
            for curve in curveSources {
                if depLast != curve.depName {
                    contents.append(blankLine)
                    print()
                    // Dep Header
                    let headerString = NSAttributedString(string: "\t\(curve.depIndex + 1).\t\(curve.depName)\t\(controller.model.deps[curve.depIndex].shortDescription)\n", attributes: headerAttribute)
                    contents.append(headerString)
                    
                    print(headerString)
                }
                
                // Ind Header
                let normalString = NSAttributedString(string: "\t\(curve.indIndex + 1).\t\(curve.indName)\t\(controller.model.inds[curve.indIndex].shortDescription)\n", attributes: normalAttribute)
                print("normalString")
                contents.append(normalString)
                
                addSourcesToContents(curve: curve)
                
                // let description = NSMutableAttributedString()
                // let sources = curve.sources
                
                /*
                 for source in sources {
                 // print("getting descriptiopn")
                 // print(source)
                 switch source {
                 case .replace (let ind, let dep, let sourceCase, let sourceCurve):
                 let sourceString = NSAttributedString(string: "\t\t\(sourceCase)   \(sourceCurve)\n", attributes: normalAttribute)
                 description.append(sourceString)
                 if curve.indName != curve.sourceInd {
                 let notMatchString = NSAttributedString(string: "\t\tSource Ind: \(ind)\n", attributes: normalAttribute)
                 description.append(notMatchString)
                 }
                 if curve.depName != curve.sourceDep {
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
                 */
                contents.append(blankLine)
                depLast = curve.depName
            }
            
            
            
        } else {
            var indLast = ""
            for curve in curveSources {
                if indLast != curve.depName {
                    contents.append(blankLine)
                    print()
                    // Ind Header
                    let headerString = NSAttributedString(string: "\t\(curve.indIndex + 1).\t\(curve.indName)\t\(controller.model.inds[curve.indIndex].shortDescription)\n", attributes: headerAttribute)
                    contents.append(headerString)
                    
                    print(headerString)
                }
                
                // Dep Header
                let normalString = NSAttributedString(string: "\t\(curve.depIndex + 1).\t\(curve.depName)\t\(controller.model.deps[curve.depIndex].shortDescription)\n", attributes: normalAttribute)
                print("normalString")
                contents.append(normalString)
                
                addSourcesToContents(curve: curve)
                
                // let description = NSMutableAttributedString()
                // let sources = curve.sources
                
                /*
                 for source in sources {
                 // print("getting descriptiopn")
                 // print(source)
                 switch source {
                 case .replace (let ind, let dep, let sourceCase, let sourceCurve):
                 let sourceString = NSAttributedString(string: "\t\t\(sourceCase)   \(sourceCurve)\n", attributes: normalAttribute)
                 description.append(sourceString)
                 if curve.indName != curve.sourceInd {
                 let notMatchString = NSAttributedString(string: "\t\tSource Ind: \(ind)\n", attributes: normalAttribute)
                 description.append(notMatchString)
                 }
                 if curve.depName != curve.sourceDep {
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
                 */
                contents.append(blankLine)
                indLast = curve.depName
            }
            
            
            
        }
        
        
        
        
        
        
        /*
        let titleString = NSAttributedString(string: "\(controller.config.baseName) Curve Source Sorted by Dependent\n".capitalized, attributes: titleAttribute)
        contents.append(titleString)
        var depLast = ""
        
        for curve in curveSources {
            if depLast != curve.depName {
                contents.append(blankLine)
                print()
                let headerString = NSAttributedString(string: "\t\(curve.depIndex + 1).\t\(curve.depName)\t\(controller.model.deps[curve.depIndex].shortDescription)\n", attributes: headerAttribute)
                contents.append(headerString)
                
                print(headerString)
            }
            
            // Ind Header
            let normalString = NSAttributedString(string: "\t\(curve.depIndex + 1).\t\(curve.indName)\t\(controller.model.inds[curve.indIndex].shortDescription)\n", attributes: normalAttribute)
            print("normalString")
            contents.append(normalString)
            
            addSourcesToContents(curve: curve)
            */
            // let description = NSMutableAttributedString()
            
            
            // let sources = curve.sources
            
            /*
             for source in sources {
             // print("getting descriptiopn")
             // print(source)
             switch source {
             case .replace (let ind, let dep, let sourceCase, let sourceCurve):
             let sourceString = NSAttributedString(string: "\t\t\(sourceCase)   \(sourceCurve)\n", attributes: normalAttribute)
             description.append(sourceString)
             if curve.indName != curve.sourceInd {
             let notMatchString = NSAttributedString(string: "\t\tSource Ind: \(ind)\n", attributes: normalAttribute)
             description.append(notMatchString)
             }
             if curve.depName != curve.sourceDep {
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
             */
            
            
            
            
            // description.addAttributes(normalAttribute, range: NSRange(location: 0, length: description.length))
            // contents.append(description)
            
            // print(curve.description + "\n")
            contents.append(blankLine)
            
            // depLast = curve.depName
       // }
        
       // print(contents)
        
           
    }
 
    @available(macOS 11.0, *)
    public func write(){
        getContents()
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [.documentType: NSAttributedString.DocumentType.rtf]
        
        
        var rtfData = Data()
        do {
            rtfData = try contents.data(from: NSRange(location: 0, length: contents.length), documentAttributes: documentAttributes)
        } catch {
            print("Error converting string to rtf data")
        }
        
        var url = controller.configURL.deletingLastPathComponent()
        url.appendPathComponent("\(controller.model.baseName)_CurveSorce.rtf")
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
    
    
    func addSourcesToContents(curve: CurveSource) {
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
        
        
        
        let description = NSMutableAttributedString()
        
        let sources = curve.sources
        for source in sources {
            // print("getting descriptiopn")
            // print(source)
            switch source {
            case .replace (let ind, let dep, let sourceCase, let sourceCurve):
                let sourceString = NSAttributedString(string: "\t\t\(sourceCase)   \(sourceCurve)\n", attributes: normalAttribute)
                description.append(sourceString)
                if curve.indName != curve.sourceInd {
                    let notMatchString = NSAttributedString(string: "\t\tSource Ind: \(ind)\n", attributes: normalAttribute)
                    description.append(notMatchString)
                }
                if curve.depName != curve.sourceDep {
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
        if !curve.note.isEmpty {
            let aString = NSAttributedString(string: "\t\tNote: \(curve.note)\n", attributes: normalAttribute)
            description.append(aString)
        }
        contents.append(description)
        
    }
    
    public init() {}
    
}

