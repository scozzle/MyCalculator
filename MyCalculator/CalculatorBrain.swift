//
//  CalculatorBrain.swift
//  MyCalculator
//
//  Created by dhk on 10/19/16.
//  Copyright © 2016 scozzle. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // the current accumulator or operand
    private var accumulator = 0.0
    
    // the output
    var output: Double {
        get {
            return accumulator
        }
    }
    
    // is it a partial result, i.e. there is pending binary operation
    var isPartialResult: Bool {
        get {
            return (pending != nil)
        }
    }
    
    // operator types
    private enum OperatorType {
        case Constant(Double)
        case Unary((Double) -> Double)
        case Binary((Double,Double) -> Double)
        case Equals
    }
    
    // all operations available
    private var operations: Dictionary<String,OperatorType> = [
        "π": OperatorType.Constant(M_PI),
        "e": OperatorType.Constant(M_E),
        "√": OperatorType.Unary(sqrt),
        "cos": OperatorType.Unary(cos),
        "sin": OperatorType.Unary(sin),
        "tan": OperatorType.Unary(tan),
        "log2": OperatorType.Unary(log2),
        "+": OperatorType.Binary({$0 + $1}),
        "×": OperatorType.Binary({$0 * $1}),
        "÷": OperatorType.Binary({$0 / $1}),
        "-": OperatorType.Binary({$0 - $1}),
        "^": OperatorType.Binary(pow),
        "=": OperatorType.Equals
    ]
    
    // model the pending binary operation info saved for later
    private struct pendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    // set the operand
    func setOperand(_ operand: Double) {
        accumulator = operand
        
    }
    
    // the pending binary info
    private var pending: pendingBinaryOperationInfo?
    
    // execute the pending binary operation if there is one
    private func executePendingBinaryOp() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    
    // the description string
    private var description = ""
    
    // does the current description end with an operand?
    private var endsWithOperand = false
    
    // description string accessible from outside
    var desc: String {
        get {
            return description
        }
    }
    
    // add description depending on the operation
    private func addDescription(_ operation: String, middleOfTyping: Bool) {
        
        // check description reset conditions first
        if !isPartialResult && middleOfTyping {
            if let symbol = operations[operation] {
                switch symbol {
                case .Constant: description = ""
                case .Binary: description = String(accumulator)
                case .Unary: description = String(accumulator)
                default: break
                }
            }
        }
        
        // add appropriate description
        if let symbol = operations[operation] {
            switch symbol {
            case .Constant:
                description = isPartialResult ? description + operation : operation
            case .Unary:
                description = isPartialResult ? description + operation + "(\(String(accumulator)))" : (operation + "(\(description))")
            case .Binary:
                description = isPartialResult ? description + String(accumulator) + operation : description + operation
            case .Equals:
                description = isPartialResult ? (endsWithOperand ? description : description + String(accumulator)) : (description)
            }
        }
    }
    
    // perform the operation given in the argument
    func performOperation(_ operation: String, wasTyping: Bool) {
        addDescription(operation, middleOfTyping: wasTyping)
        endsWithOperand = true
        if let symbol = operations[operation] {
            switch symbol {
            case .Constant(let value):
                accumulator = value
            case .Unary(let function):
                accumulator = function(accumulator)
            case .Binary(let function):
                executePendingBinaryOp()
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                endsWithOperand = false
            case .Equals:
                executePendingBinaryOp()
            }
        }
    }
    
    // check if numString contains a valid number
    func containsValidNumber(_ numString: String) -> Bool {
        if Double(numString) != nil {
            return true
        } else {
            return false
        }
    }
    
    // reset everything
    func reset() {
        accumulator = 0.0
        pending = nil
        description = ""
    }
}
