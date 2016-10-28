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

    // the display
    @IBOutlet private weak var display: UILabel!
    
    // the equation
    @IBOutlet private weak var equation: UILabel!
    
    // backspace button
    @IBAction func backspace(_ sender: UIButton) {
        // if not middleOfTyping => erase entire thing, put space there
        // if middleOfTyping => get the current string, cut off end if possible
        
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
    
    // numerical button pressed
    @IBAction private func buttonPressed(_ sender: UIButton) {
        // dirty here, clean up 
        if display.text! == " " {
            display.text = ""
        }
        let newText = middleOfTyping ? display.text! + sender.currentTitle! : sender.currentTitle!

        display.text = newText
        middleOfTyping = true
    }
    
    // the number on the display
    private var displayValue: Double? {
        get {
            return display.text == " " ? nil : Double(display.text!)!
        }
        set(newVal) {
            if newVal == nil {
                display.text = " "
            } else {
                // using NSFormatter and NSNumber so that number of fractional digits shown is 6 in displayText
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 6
                let newText = (newVal!.truncatingRemainder(dividingBy: 1) == 0) ? String(Int(newVal!)) : String(newVal!)
                let nsNumber = NSNumber(value: Double(newText)!)
                display.text = formatter.string(from: nsNumber)
            }
        }
    }
    
    // the equation string
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
    @IBAction func reset(_ sender: UIButton) {
        brain.reset()
        middleOfTyping = false
        equation.text = "0"
        displayValue = 0
    }
    
    // operation button pressed, perform operation
    @IBAction private func performOperation(_ sender: UIButton) {
        if !CalculatorBrain.containsValidNumber(display.text!) {
            return
        }
        // set the operand to the current number on display
        brain.setOperand(displayValue!)
        
        // perform the operation
        if let operation = sender.currentTitle {
            brain.performOperation(operation, wasTyping: middleOfTyping)
        }
        
        // update the displays
        displayValue = brain.output
        equationValue = brain.desc
        
        // no longer in the middle of typing numbers
        middleOfTyping = false
    }
}
