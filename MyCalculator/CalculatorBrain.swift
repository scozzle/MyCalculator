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
    
    // the description string
    private var description = ""
    
    // the index in description of the last binary operation symbol
    private var lastOpSymIndex: Int?
    
    // does the current description end with an operand?
    private var endsWithOperand = false
    
    // access to above
    var endsInOperand: Bool {
        get {
            return endsWithOperand
        }
    }
    
    // description string accessible from outside
    var desc: String {
        get {
            return description
        }
    }
    
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
        case Random(() -> Double)
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
        "=": OperatorType.Equals,
        "Ran": OperatorType.Random(drand48)
    ]
    
    // model the pending binary operation info saved for later
    private struct pendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
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
    
    // check if numString contains a valid number
    static func containsValidNumber(_ numString: String) -> Bool {
        if Double(numString) != nil {
            return true
        } else {
            return false
        }
    }
    
    // set the operand
    func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        
    }
    
    // reset everything
    func reset() {
        accumulator = 0.0
        pending = nil
        description = ""
        endsWithOperand = false
        lastOpSymIndex = nil
        internalProgram.removeAll()
    }
    
    
    // perform the operation given in the argument
    func performOperation(_ operation: String) {
        internalProgram.append(operation as AnyObject)

        // variable used if "Rand" operation is performed
        var random: Double? = nil
        
        if let symbol = operations[operation] {
            switch symbol {
            case .Constant(let value):
                
                setOperand(value)
                description = isPartialResult ? description + operation : operation
                
                endsWithOperand = true
                
            case .Unary(let function):
                
                switch (isPartialResult, endsWithOperand) {
                case (true,true):
                    let prefix = description.substring(to: description.index(description.startIndex, offsetBy: lastOpSymIndex!+1))
                    let suffix = description.substring(from: description.index(description.startIndex, offsetBy: lastOpSymIndex!+1))
                    description = prefix + operation + "(\(suffix))"
                case (true,false):
                    description = description + operation + "(\(String(accumulator)))"
                case (false,true):
                    description = operation + "(\(description))"
                case (false,false):
                    description = operation + "(\(String(accumulator)))"
                }
                
                accumulator = function(accumulator)
                
                endsWithOperand = true
                
            case .Binary(let function):
                
                let descLen = description.characters.count
                
                switch (isPartialResult, endsWithOperand) {
                case (true,true):
                    description = description + operation
                    lastOpSymIndex = descLen
                case (true, false):
                    description = description + String(accumulator) + operation
                    lastOpSymIndex = descLen + String(accumulator).characters.count
                case (false, true):
                    description = description + operation
                    lastOpSymIndex = descLen
                case (false,false):
                    description = String(accumulator) + operation
                    lastOpSymIndex = String(accumulator).characters.count
                }
                
                executePendingBinaryOp()
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                
                endsWithOperand = false
                
            case .Equals:
                
                description = isPartialResult ? (endsWithOperand ? description : description + String(accumulator)) : (description)
                
                executePendingBinaryOp()
                
                endsWithOperand = true
                
            case .Random(let function):
                random = function()
                
                description = isPartialResult ? description + "\(random!)" : "\(random!)"
                
                setOperand(random!)
                
                endsWithOperand = true
            }
        }
    }
    
    // storing program
    private var internalProgram = [AnyObject]()
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        } set {
            reset()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    }
                    if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    
}
