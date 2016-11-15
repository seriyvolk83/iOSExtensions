//
//  ComboBoxTextField.swift
//  dodo
//
//  Created by TCASSEMBLER on 11/2/15.
//  Copyright © 2015 seriyvolk83dodo. All rights reserved.
//

import UIKit


/**
 * ComboBoxTextField
 * Text field with picker keyboard
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
class ComboBoxTextField: UITextField {
    
    /// combo box data
    var data = [String]()
    
    /// the picker
    var picker: UIPickerView!
    
    /// current selected index
    var selectedIndex: Int = 0
    
    /**
     Initialization with frame
     
     - Parameter frame: the frame
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    /**
     Initialization with a decoder
     
     - Parameter coder: a decoder
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    /**
     Setup
     */
    func setup() {
        picker = UIPickerView()
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        self.inputView = picker
        self.addAccessoryView()
    }
}


/**
 * MARK: UIPickerView DataSource
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
extension ComboBoxTextField: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
}


/**
 * MARK: UIPickerView Delegate
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
extension ComboBoxTextField: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = data[row]
        selectedIndex = row
        
        self.sendActionsForControlEvents(UIControlEvents.EditingChanged)
    }
}

/**
 * Extension for UITextField
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
extension UITextField {
    
    /**
     Add accessory view for Keyboard
     */
    func addAccessoryView() {
        // UIToolBar
        let accessoryView = UIToolbar()
        accessoryView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        accessoryView.sizeToFit()
        var frame = accessoryView.frame
        frame.size.height = 44.0
        accessoryView.frame = frame
        
        // Add done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButtonDidPress:")
        let flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        accessoryView.setItems([flexibleSpaceLeft, doneButton], animated: false)
        self.inputAccessoryView = accessoryView
    }
    
    /**
     Action for done button
     */
    func doneButtonDidPress(sender: AnyObject) {
        self.resignFirstResponder()
    }
    
}
