//
//  FormViewController.swift
//  dodo
//
//  Created by TCASSEMBLER on 06.11.15.
//  Copyright © 2015 seriyvolk83dodo. All rights reserved.
//

import UIKit

/// stores estimated keyboard height
var KeyboardHeight: CGFloat = isIPad ? 403 : 258 // 258 for iPhone, dodo change to desired

/**
* Abstract class used for subclassing. Contains methods that move screen up when keyboard appear.
* Provides keyboard related features.
*
* - author: TCASSEMBLER
* - version: 1.0
*/
class FormViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    /// outlet
    @IBOutlet var formOffsetOy: [NSLayoutConstraint]!
    
    /// flag: true - keyboard is on the screen, false - keyboard is not shown
    var keyboardIsShown = false
    
    /// the extra offset under the keyboard
    var extraOffsetUnderKeyboard: CGFloat {
        return 44
    }
    
    /// the reference to last edited field
    var lastEditedField: UIView!
    
    // MARK: Keyboard
    
    /**
    Add keyboard listeners
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Remove listeners
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Handle keyboard opening
    */
    func keyboardWillShow(notification: NSNotification) {
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let lastKeyboardHeight = KeyboardHeight
        KeyboardHeight = rect.height
        keyboardIsShown = true
        if lastKeyboardHeight != KeyboardHeight {
            // move form up to reveal the field
            if let textField = lastEditedField {
                moveFormUp(textField)
            }
        }
    }
    
    /**
    Keyboard disappear event handler
    
    - parameter notification: the notification object
    */
    func keyboardWillHide(notification: NSNotification) {
        keyboardIsShown = false
        moveFormDown()
    }
    
    /**
    Close the keyboard or the form when tapped anywhere
    
    - parameter touches: the touches
    - parameter event:   the event
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if keyboardIsShown {
            self.view.endEditing(true)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    /**
    Save reference to last edited view
    
    - parameter textField: the textField
    
    - returns: true
    */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        lastEditedField = textField
        moveFormUp(textField)
        return true
    }
    
    /**
    Move form up
    
    - parameter fieldView: the editanble field
    */
    func moveFormUp(fieldView: UIView) {
        let currentPosition = fieldView.superview!.convertRect(fieldView.frame, toView: self.view)
        let visibleHeight = UIScreen.mainScreen().bounds.height - KeyboardHeight
        let fieldOy = self.view.frame.origin.y + currentPosition.origin.y + formOffsetOy[0].constant
        let maxFieldOy = visibleHeight - getMaxFieldHeight(visibleHeight, fieldViewHeight: currentPosition.height) - extraOffsetUnderKeyboard
        if fieldOy > maxFieldOy {
            let viewAdditionalOffset = fieldOy - maxFieldOy
            for constraint in formOffsetOy {
                constraint.constant = viewAdditionalOffset
            }
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        else {
            moveFormDown()
        }
    }
    
    /**
     Get max field height
     
     - parameter visibleScreenHeight: the visible screen height
     - parameter fieldViewHeight:     the field height
     
     - returns: the effective field height
     */
    func getMaxFieldHeight(visibleScreenHeight: CGFloat, fieldViewHeight: CGFloat) -> CGFloat {
        let hasNavigationBar = self.navigationController != nil && !self.navigationController!.navigationBarHidden
        let visibleHeight = visibleScreenHeight - (hasNavigationBar ? (20 + 44) : 0)
        if fieldViewHeight > visibleScreenHeight {
            return visibleHeight
        }
        return fieldViewHeight
    }
    
    /**
    Move form down
    */
    func moveFormDown() {
        for constraint in formOffsetOy {
            constraint.constant = 0
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    /**
    Dismiss keyboard
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: UITextViewDelegate

    /**
    Move form up when the field is focused
    
    - parameter textView: the textView
    
    - returns: true
    */
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        lastEditedField = textView
        moveFormUp(textView)
        return true
    }
    
    /**
     Can be used as follows:
     override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
         let selectedRange = textView.selectedRange
         let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
         textView.text = newText
         let size = textView.sizeThatFits(textView.bounds.size)
         applyTextFieldSize(textView, size: size, heightConstraint: titleHeight)
         
         textView.selectedRange = getNewSelectedRange(selectedRange, replacementText: text)
         if text == "\n" {
             textView.resignFirstResponder()
         }
         return false
     }

     
     - parameter selectedRange: the selected range before text is changed
     - parameter text:          the replacement text
     
     - returns: new range to set
     */
    internal func getNewSelectedRange(selectedRange: NSRange, replacementText text: String) -> NSRange {
        if !text.isEmpty {
            return NSMakeRange(selectedRange.location + text.length, 0)
        }
        else if selectedRange.length == 0 {
            return NSMakeRange(selectedRange.location - 1, 0)
        }
        else {
            return NSMakeRange(selectedRange.location, 0)
        }
    }

}
