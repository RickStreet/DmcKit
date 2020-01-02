//
//  Enums.swift
//  DMCRead
//
//  Created by Richard Street on 11/8/19.
//  Copyright © 2019 Richard Street. All rights reserved.
//

import Foundation

public enum GainAdjustType: String {
    case none = "None"
    case set = "Set"
    case adjusted = "Adjust"
}


public enum PredictionFilterType: String {
    case none = "None"
    case firstOrder = "First Order"
    case timeHorizen = "Moving Average"
}

enum SolutionType: String {
    case LP = "L"
    case QP = "Q"
}

enum ETType: String {
    case none = "none"
    case rto = "rto"
    case irv = "irv"
}

enum RampType: String {
    case none = "None"
    case standard = "Ramp"
    case pseudo =  "Pseudo"
}

enum LPCriteria: String {
    case cost = "C"
    case move = "M"
}

public enum TransformType: String {
    case none = "None"
    case linear = "Linear Valve"
    case log = "Log"
    case ln = "Ln"
    case mLog = "Modified Log"
    case mLn = "Modified Ln"
    case parabolic = "Parabolic Valve"
    case pwl = "Piece-wise Linear"
    case shiftRatePower = "Shift-rate Power"
}

public enum CurveSourceType {
    case replace (ind: String, dep: String, sourceCase: String, sourceCurve: String)
    case unity
    case zero
    case first (deadtime: Double, tau: Double, gain: Double) // time in seconds
    case second (deadtime: Double, tau: Double, damp: Double, gain: Double) // time in seconds
    case convolute (model: String, ind: String, interModel: String, dep: String, interInd: String )
}
