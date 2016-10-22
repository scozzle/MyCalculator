//
//  CalculatorBrain.swift
//  MyCalculator
//
//  Created by dhk on 10/19/16.
//  Copyright © 2016 scozzle. All rights reserved.
//

import Foundation

class CalculatorBrain {
    // the current accumulator
    private var accumulator = 0.0
    
    // the output
    var output: Double {
        get {
            return accumulator
        }
    }
    
    // is it a partial result
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
    
    // all operations possible
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
    
    // saved info when binary operation pressed
    private struct pendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    // set the operand
    func setOperand(_ operand: Double) {
        accumulator = operand
        
    }
    
    // the instantiation of the pending info struct
    private var pending: pendingBinaryOperationInfo?
    
    // execute the pending binary operation
    // note that if there was no pending op, nothing is done
    private func executePendingBinaryOp() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    // perform the operation given in the argument
    func performOperation(_ operation: String) {
        //addDescription(operation)
        if let symbol = operations[operation] {
            switch symbol {
            case .Constant(let value):
                accumulator = value
            case .Unary(let function):
                accumulator = function(accumulator)
            case .Binary(let function):
                executePendingBinaryOp()
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOp()
            }
            // print(description)
        }
    }
    
    // check if numString contains a valid number
    static func containsValidNumber(_ numString: String) -> Bool {
        if Double(numString) != nil {
            return true
        } else {
            return false
        }
    }
    
    // description string
    var description = ""
    
    // equation state
    private var equationState = EquationState.Partial
    private enum EquationState {
        case Partial
        case Complete
    }
    
    // add description depending on the operation
    func addDescription(_ operation: String, _ middleOfTyping: Bool) {
        
        if let symbol = operations[operation] {
            let resetCondition1 = (equationState == EquationState.Complete)
            
            if middleOfTyping && resetCondition1 {
                description = String(accumulator)
            }
            
            // update as necessary
            switch symbol {
            case .Constant:
                // checking for reset condition
                if resetCondition1 {
                    description = String(accumulator)
                }
                description = (equationState == EquationState.Partial) ? description + operation : operation
                equationState = EquationState.Complete
            case .Unary:
                description = (equationState == EquationState.Partial) ? description + operation + String(accumulator) : operation + "(" + description + ")"
                equationState = EquationState.Complete
            case .Binary:
                description = (equationState == EquationState.Partial) ? description + String(accumulator) + operation : description + operation
                equationState = EquationState.Partial
            case .Equals:
                description = (equationState == EquationState.Partial) ? description + String(accumulator) : description
                equationState = EquationState.Complete
            }
        }
    }
    
    // reset everything
    func reset() {
        accumulator = 0.0
        pending = nil
        description = ""
        equationState = EquationState.Partial
    }
    
}
