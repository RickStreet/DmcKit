//
//  ModelCurve.swift
//  DMC
//
//  Created by Rick Street on 2/26/18.
//  Copyright © 2018 Rick Street. All rights reserved.
//

import Foundation

/**
 Curve from model file
 */
public class ModelCurve {
    public var indName = ""
    public var indIndex = 0
    public var depName = ""
    public var depIndex = 0
    public var gain = 0.0
    public var coefficients = [Double]()
    public var modifiedCoefficients = [Double]()
    public var isRamp = false
    public var modified = false // Curve modified (shown in modifiedXCoefficients
    public var fitGain: Double?
    public var tau: Double?
    public var deadtime: Double?
    
    public var curveLength: Int {
        return coefficients.count
    }
    
    public var maxAbsCoefficient: Double {
        let absMax = coefficients.map{abs($0)}
        //print("maxAbs \(max)")
        return absMax.max() ?? 0.0
    }
    
    public var maxCoefficient: (Int, Double) {
        var maxValue = coefficients[0]
        var maxIndex = 0
        for (index, value) in coefficients.enumerated() {
            if value > maxValue {
                maxValue = value
                maxIndex = index
            }
        }
        return (maxIndex, maxValue)
    }

    public var minCoefficient: (Int, Double) {
        var minValue = coefficients[0]
        var minIndex = 0
        for (index, value) in coefficients.enumerated() {
            if value < minValue {
                minValue = value
                minIndex = index
            }
        }
        return (minIndex, minValue)
    }
    
    public var inverseResponse: Bool {
        if gain > 0.0 && minCoefficient.1 < 0.0 {
            return true
        }
        if gain < 0 && maxCoefficient.1 > 0.0 {
            return true
        }
        return false
    }
   
    public var plotData: [(x: Double, y: Double)] {
        var x = 0.0
        var plot = [(x: Double, y: Double)]()
        plot.append((0.0, 0.0))
        x += 1.0
        for coef in coefficients {
            plot.append((x, coef))
            x += 1.0
        }
        return plot
    }
 
    public var modifiedPlotData: [(x: Double, y: Double)] {
        var x = 0.0
        var plot = [(x: Double, y: Double)]()
        plot.append((0.0, 0.0))
        x += 1.0
        for coef in modifiedCoefficients {
            plot.append((x, coef))
            x += 1.0
        }
        return plot
    }
    
    public func reduceInverse(by factor: Double) {
        print("reducing inverse")
        if !modified {
            modifiedCoefficients = coefficients
            modified = true
        }
        if gain > 0.0 && minCoefficient.1 < 0.0 {
            print("negative inverse")
            for index in 0..<coefficients.count {
                if modifiedCoefficients[index] <= 0.0 {
                    print("\(modifiedCoefficients[index]) reduced to \(modifiedCoefficients[index]) * \(factor)")
                    modifiedCoefficients[index] *= factor
                }
            }
        }
        if gain < 0.0 && maxCoefficient.1 > 0.0 {
            print("positive inverse")
            for index in 0..<coefficients.count {
                if coefficients[index] >= 0.0 {
                    print("\(coefficients[index]) reduced to \(coefficients[index]) * \(factor)")
                    coefficients[index] *= factor
                }
            }
        }

    }

}
