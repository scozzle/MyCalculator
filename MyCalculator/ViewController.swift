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
    
    // dot pressed
    @IBAction func dotPressed(_ sender: UIButton) {
        // if nothing in display set to dot
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
            if display.text != " " {
                var currentText = display.text!
                currentText.remove(at: currentText.index(before: currentText.endIndex))
                if currentText == "" {
                    displayValue = nil
                } else {
                    if CalculatorBrain.containsValidNumber(currentText) {
                        displayValue = Double(currentText)
                    } else {
                        displayValue = nil
                        display.text = "."
                    }
                }
            }
        } else {
            displayValue = nil
        }
    }
    
    // constant or random button pressed
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
    
    // operation button pressed
    @IBAction private func performOperation(_ sender: UIButton) {
        if !CalculatorBrain.containsValidNumber(display.text!) {
            return
        }
        
        if shouldResetBrain {
            brain.reset()
            shouldResetBrain = false
        }
        
        brain.setOperand(displayValue!)
        
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        
        displayValue = brain.output
        equationValue = brain.desc
        
        middleOfTyping = false
    }
}
