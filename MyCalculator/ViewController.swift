//
//  ViewController.swift
//  MyCalculator
//
//  Created by dhk on 10/19/16.
//  Copyright © 2016 scozzle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /*
     * internal variables
     */
    
    private var brain = CalculatorBrain() // The CalculatorBrain model.
    
    private var middleOfTyping = false // the user in the middle of typing an operand?
    
    private var numFractionalDigits = 6 // number of fractional digits

    private var shouldResetBrain = false // should reset brain?
    
    @IBOutlet private weak var display: UILabel! // the display label
    
    @IBOutlet private weak var equation: UILabel! // the equation label
    
    private var displayValue: Double? { // the number on the display
        get {
            return display.text == " " ? nil : Double(display.text!)
        }
        set(newVal) {
            if newVal == nil {
                display.text = " "
            } else {
                display.text = cutFractional(newVal!, i: numFractionalDigits)
            }
        }
    }
    
    private var equationValue: String { // equation string with "=" or "..." added depending on result partial or not
        get {
            return equation.text!
        }
        set(newVal) {
            let addText = brain.isPartialResult ? "..." : "="
            equation.text = newVal + addText
        }
    }
    
    /*
     * Helper Functions
     */
    
    // format the double to have at most i fractional digits and return the string form
    private func cutFractional(_ val: Double, i: Int) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = i
        let newText = (val.truncatingRemainder(dividingBy: 1) == 0) ? String(Int(val)) : String(val)
        let nsNumber = NSNumber(value: Double(newText)!)
        return formatter.string(from: nsNumber)!
    }
    
    // reset the calculator
    @IBAction private func reset() {
        brain.reset()
        middleOfTyping = false
        equation.text = "0"
        displayValue = 0
        shouldResetBrain = false
    }
    
    /*
     * Action functions called from View
     */
    
    // numerical button pressed
    @IBAction private func buttonPressed(_ sender: UIButton) {
        if display.text == " " || (!brain.isPartialResult && !middleOfTyping) {
            displayValue = Double(sender.currentTitle!)
            shouldResetBrain = true
        } else {
            let newText = middleOfTyping ? display.text! + sender.currentTitle! : sender.currentTitle!
            displayValue = Double(newText)
        }
        middleOfTyping = true
    }
    
    // random button pressed
    @IBAction func randomPressed() {
        let r = drand48()
        displayValue = r
        if !brain.isPartialResult || middleOfTyping {
            shouldResetBrain = true
        }
    }
    
    // dot pressed
    @IBAction func dotPressed(_ sender: UIButton) {
        if display.text == " " || (!brain.isPartialResult && !middleOfTyping) {
            display.text = "."
            shouldResetBrain = true
        } else {
            if display.text?.range(of: ".") == nil {
                display.text = display.text! + "."
            }
        }
        middleOfTyping = true
    }
    
    // backspace button
    @IBAction private func backspace() {
        if middleOfTyping {
            var currentText = display.text!
            currentText.remove(at: currentText.index(before: currentText.endIndex))
            if currentText == "" {
                displayValue = nil
            } else {
                if CalculatorBrain.containsValidNumber(currentText) {
                    displayValue = Double(currentText)
                } else {
                    displayValue = nil
                    display.text = currentText // happens when currentText == "."
                }
            }
        } else {
            displayValue = nil
            shouldResetBrain = true
        }
    }
   
    // variable button pressed
    @IBAction func variablePressed(_ sender: UIButton) {
        if shouldResetBrain || brain.endsInOperand {
            brain.reset()
            shouldResetBrain = false
        }
        brain.setOperand(sender.currentTitle!)
        displayValue = brain.output
        equationValue = brain.desc
        middleOfTyping = false
    }
    
    // want to set the variable value
    @IBAction func setVariable(_ sender: UIButton) {
        if !CalculatorBrain.containsValidNumber(display.text!) {
            return // can't set the variable value
        }
        let buttonName = sender.currentTitle!
        let varName = buttonName.substring(from: buttonName.index(buttonName.startIndex, offsetBy: 1))
        brain.variableValues[varName] = Double(display.text!)!
        // need to re-run the internal program with the new value
        brain.rerunProgram()
        shouldResetBrain = false
        displayValue = brain.output
        equationValue = brain.desc
    }
    
    // constant button pressed
    @IBAction func performOperandInput(_ sender: UIButton) {
        if shouldResetBrain || brain.endsInOperand {
            brain.reset()
            shouldResetBrain = false
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        displayValue = brain.output
        equationValue = brain.desc
        middleOfTyping = false

    }
    
    // equals operation pressed
    @IBAction func equalsPressed(_ sender: UIButton) {
        if !CalculatorBrain.containsValidNumber(display.text!) {
            return
        }
        if shouldResetBrain {
            brain.reset()
            shouldResetBrain = false
        }
        if !brain.endsInOperand {
            brain.setOperand(displayValue!)
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        displayValue = brain.output
        equationValue = brain.desc
        middleOfTyping = false
    }
    
    // undo button pressed
    @IBAction func undoPressed() {
        if middleOfTyping {
            backspace()
        } else {
            brain.undo()
            displayValue = brain.output
            equationValue = brain.desc
        }
    }
    
    // operation button pressed
    @IBAction private func performOperation(_ sender: UIButton) {
        if !CalculatorBrain.containsValidNumber(display.text!) {
            return
        }
        if shouldResetBrain {
            brain.reset()
            shouldResetBrain = false
        }
        if middleOfTyping {
            brain.setOperand(displayValue!)
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        displayValue = brain.output
        equationValue = brain.desc
        middleOfTyping = false
    }
}
