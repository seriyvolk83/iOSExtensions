//
//  DatePickerViewController.swift
//  dodo
//
//  Created by TCASSEMBLER on 19.02.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit

/// the reference to last date picker
var LastDatePickerViewController: DatePickerViewController?

/**
 * DatePickerViewController delegate protocol
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
@objc protocol DatePickerViewControllerDelegate {
    
    /**
     Date updated
     
     - parameter date:   the date
     - parameter picker: the picker
     */
    optional func datePickerDateUpdated(date: NSDate, picker: DatePickerViewController)
    
    /**
     Date selected
     
     - parameter date:   the date
     - parameter picker: the picker
     */
    func datePickerDateSelected(date: NSDate, picker: DatePickerViewController)
    
    /**
     Picker cancelled
     
     - parameter picker: the picker
     */
    optional func datePickerCancelled(picker: DatePickerViewController)
}

/**
 * View controller that contains header and datepicker.
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class DatePickerViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var outsideButton: UIButton!
 
    /// selected item in the picker (value)
    var selectedObject: NSDate?
    
    // the mode
    var datePickerMode: UIDatePickerMode!
    
    // the delegate
    var delegate: DatePickerViewControllerDelegate?
    
    /**
     Show the picker
     
     - parameter title:          the title
     - parameter selectedDate:   the selected date
     - parameter datePickerMode: the date picker mode
     - parameter delegate:       the delegate
     */
    class func show(title title: String,
        selectedDate: NSDate? = nil,
        datePickerMode: UIDatePickerMode,
        delegate: DatePickerViewControllerDelegate,
        disableOutsideButton: Bool = false) -> DatePickerViewController? {
            LastDatePickerViewController?.closePicker()
            if let parent = UIViewController.getCurrentViewController() {
                if let vc = parent.create(DatePickerViewController.self, storyboardName: "Main") {
                    LastDatePickerViewController = vc
                    vc.title = title
                    vc.selectedObject = selectedDate ?? NSDate()
                    vc.datePickerMode = datePickerMode
                    vc.delegate = delegate
                    
                    let height: CGFloat = 217
                    let bounds = disableOutsideButton ? CGRect(x: 0, y: 0, width: parent.view.bounds.width, height: height) : parent.view.bounds
                    parent.showViewControllerFromSide(vc,
                        inContainer: parent.view,
                        bounds: bounds,
                        side: .Bottom, nil)
                    return vc
                }
            }
        return nil
    }
    
    /**
     Setup UI
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = self.title?.uppercaseString
        if !hasControls() {
            height.constant = 0
        }
        picker.datePickerMode = datePickerMode
        if datePickerMode == .DateAndTime {
            picker.minimumDate = NSDate()
        }
        picker.addTarget(self, action: "valueChanged", forControlEvents: UIControlEvents.ValueChanged)
        
        if let preselectDate = selectedObject {
            picker.date = preselectDate
        }
    }
    
    /**
     Check if need to show controls
     
     - returns: true - if title is not empty, false - else
     */
    func hasControls() -> Bool {
        return !(self.title ?? "").isEmpty
    }

    /**
     Callback when selected value changed
     */
    func valueChanged() {
        delegate?.datePickerDateUpdated?(picker.date, picker: self)
    }
    
    /**
     "Done" button action
     
     - parameter sender: the button
     */
    @IBAction func doneButtonAction(sender: AnyObject) {
        let date = picker.date
        self.delegate?.datePickerDateSelected(date, picker: self)
        self.closePicker()
    }

    /**
     "Close" button action handler
     
     - parameter sender: the button
     */
    @IBAction func closeButtonAction(sender: AnyObject) {
        self.delegate?.datePickerCancelled?(self)
        self.closePicker()
    }
    
    /**
     Close the picker
     */
    func closePicker(animated: Bool = true, _ callback: (()->())? = nil) {
        LastDatePickerViewController = nil
        if animated {
            self.dismissViewControllerToSide(self, side: .Bottom, callback)
        }
        else {
            self.removeFromParent()
        }
    }
}
