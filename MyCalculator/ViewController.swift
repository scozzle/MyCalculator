//
//  ViewController.swift
//  MyCalculator
//
//  Created by dhk on 10/19/16.
//  Copyright © 2016 scozzle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Instantiation of the CalculatorBrain
    private var brain = CalculatorBrain()
    
    // the user in the middle of typing an operand?
    private var middleOfTyping = false
    
    // number of fractional digits
    private var numFractionalDigits = 6

    // should reset brain?
    private var shouldResetBrain = false
    
    // the display
    @IBOutlet private weak var display: UILabel!
    
    // the equation
    @IBOutlet private weak var equation: UILabel!
    
    // format the double to have at most i fractional digits and return the string form
    private func cutFractional(_ val: Double, i: Int) -> String{
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = i
        let newText = (val.truncatingRemainder(dividingBy: 1) == 0) ? String(Int(val)) : String(val)
        let nsNumber = NSNumber(value: Double(newText)!)
        return formatter.string(from: nsNumber)!
        
    }
    
    // the number on the display
    private var displayValue: Double? {
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
         // if does not end with dot, add dot at the end
        
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
    @IBAction private func backspace(_ sender: UIButton) {
        if middleOfTyping {
            if displayValue != nil {
                var currentText = display.text!
                currentText.remove(at: currentText.index(before: currentText.endIndex))
                if currentText == "" {
                    displayValue = nil
                } else {
                    displayValue = Double(currentText)
                }
            }
        } else {
            displayValue = nil
        }
    }
    
    // equation string with "=" or "..." added depending on result partial or not
    private var equationValue: String {
        get {
            return equation.text!
        }
        set(newVal) {
            let addText = brain.isPartialResult ? "..." : "="
            equation.text = newVal + addText
        }
    }
    
    // reset the calculator
    @IBAction private func reset(_ sender: UIButton) {
        brain.reset()
        middleOfTyping = false
        equation.text = "0"
        displayValue = 0
    }
    
    // operation button pressed, perform operation
    @IBAction private func performOperation(_ sender: UIButton) {
        // check if the string in display is a valid number first
        if !CalculatorBrain.containsValidNumber(display.text!) {
            return
        }
        
        // if new equation is starting, reset brain
        if shouldResetBrain {
            brain.reset()
            print("here")
            shouldResetBrain = false
        }
        
        // set the operand to the current number on display
        brain.setOperand(displayValue!)
        
        // perform the operation
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        
        // update the displays
        displayValue = brain.output
        equationValue = brain.desc
        
        // no longer in the middle of typing numbers
        middleOfTyping = false
    }
}
