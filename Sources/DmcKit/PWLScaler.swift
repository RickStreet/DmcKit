//
//  PWLScaler.swift
//  FitAndTransform
//
//  Created by Rick Street on 10/11/23.
//

import Foundation

class PWLScaler {
    
    var xLo = 0.0
    var xHi = 100.0
    var y0 = 0.0 // Unscaled yLo (extrapulated)
    var factor = 1.0
    var bias = 0.0

    var points = [(x: Double, y: Double)]()
    var unscaledPoints: [(x: Double, y: Double)] {
        return points.sorted(){$0.0 < $1.0}
    }
    
    var scaledPoints:  [(x: Double, y: Double)] {
        var sPoints = [(x: Double, y: Double)]()
        guard points.count > 1 else {
            return sPoints
        }
        let points = unscaledPoints
        let n = points.count - 1
        
        // extrapulate to y0
        let slopeLow = (points[1].1 - points[0].1) / (points[1].0 - points[0].0)
        print("delta y low \(points[1].1 - points[0].1)")
        print("slopeLow \(slopeLow)")
        // let ymin = points[0].y - slopeLow * (points[0].x - xLo)
        let startPoint = (x: xLo, y: points[0].1 - slopeLow * (points[0].0 - xLo))
        print("startPoint \(startPoint)")

        // extrapulate y to xHi
        let slopeHigh = (points[n].1 - points[n - 1].1) / (points[n].0 - points[n - 1].0)
        print("slopeHigh \(slopeHigh)")
        let endPoint = (x: xHi, y: points[n].1 + slopeHigh * (xHi - points[n].0))
        print("endPoint \(endPoint)")
        print("delta y hi \(points[n].1 - points[n - 1].1)")
        
        let deltaY = endPoint.y - startPoint.y
        factor = 100.0 / deltaY
        bias = startPoint.1 - y0
        print("deltaY \(deltaY)  factor \(factor)")


        let scaledStartPoint = scalePoint(startPoint)
        let scaledEndPoint = scalePoint(endPoint)

        sPoints.append(scaledStartPoint)
        for i in 1 ..< points.count - 1 {
            sPoints.append(scalePoint(points[i]))
        }
        sPoints.append(scaledEndPoint)

        return sPoints
    }
    
    func scalePoint(_ point: (x: Double, y: Double)) -> (x: Double, y: Double) {
        let scaledPoint = (point.x, (point.y - bias) * factor)
        return scaledPoint
    }
    
    init(points: [(x: Double, y: Double)]) {
        self.points = points
    }
    
    init() {
        
    }
}
