//
//  KeyboardUtils.swift
//  dodo
//
//  Created by Alexander Volkov on 07.04.15.
//  Copyright (c) 2015 seriyvolk83dodo. All rights reserved.
//

import UIKit


/**
Dodo

- parameter textField: the textField
- parameter range:     the range to replace the string
- parameter string:    the string to replace in the range

- returns: true
*/
func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
    replacementString string: String) -> Bool {
        var text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        dodo
        return true
}


// dodo На iPhone работает на ура
class KeyboardUtils: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var lastTextField: UIView?
    
    // MARK: Delegate methods
    // Save last used textField to determine the need to move the view up to reveal the field after the keyboard appear
    func textFieldDidBeginEditing(textField: UITextField) {
        lastTextField = textField
        UIView.animateWithDuration(0.3) {
            self.scrollView.contentOffset.y = textField.frame.maxY
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        lastTextField = textView
        UIView.animateWithDuration(0.3) {
            self.scrollView.contentOffset.y = textView.frame.maxY
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        lastTextField = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        lastTextField = nil
    }
    
    // MARK: Keyboard events
    
    /**
    Override to start listen keyboard events
    
    - parameter animated: flag whether the view is animated when appear
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Override to stop listen keyboard events
    
    - parameter animated: flag whether the view is animated when disappear
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Keyboard appear event handler
    
    - parameter notification: the notification object that contains keyboard size
    */
    func keyboardWillShow(notification: NSNotification) {
        
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3) {
            self.scrollView.contentInset.bottom = rect.height
        }
    }
    
    /**
    Keyboard disappear event handler. Rollback all changes in the scrollView
    
    - parameter notification: the notification object
    */
    func keyboardWillHide(notification: NSNotification) {
        
        self.scrollView.contentInset.bottom = 0
//        dodo это на случай если используется еще и KeyboardDismissingUIViewTarget
//        dispatch_async(dispatch_get_main_queue(), {
//            UIView.animateWithDuration(0.3) {
//                self.scrollView.contentInset.bottom = 0
//            }
//        })
        if let textField = lastTextField as? UITextField {
            textField.resignFirstResponder()
        }
        else if let textView = lastTextField as? UITextView {
            textView.resignFirstResponder()
        }
    }
    
    // MARK: ----------------------------------------------- dismissing keyboard
    
    /**
    Save reference to focused textView
    
    :param: sender the sender
    */
    func keyboardWillShow(sender: AnyObject){
        if self.searchTextField?.isFirstResponder() ?? false {
            KeyboardDismissingUIViewTarget = self.searchTextField
        }
    }
    
    /**
    Clean KeyboardDismissingUIViewTarget
    
    :param: sender the sender
    */
    func keyboardWillHide(sender: AnyObject){
        KeyboardDismissingUIViewTarget = nil
    }
}

/// the target view (textView) which should not dismiss the keyboard
var KeyboardDismissingUIViewTarget: UIView?

/**
* Custom class for top view that dismisses keyboard when tapped outside the given textView or textField
*
* @author Alexander Volkov
* @version 1.0
*/
class KeyboardDismissingUIView: UIView {
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var textFieldOrView: UIView?
        if let textField = KeyboardDismissingUIViewTarget as? UITextField {
            textFieldOrView = textField
        }
        else if let textView = KeyboardDismissingUIViewTarget as? UITextView {
            textFieldOrView = textView
        }
        if let targetView = textFieldOrView {
            // Convert the point to the target view's coordinate system.
            // The target view isn't necessarily the immediate subview
            let pointForTargetView = targetView.convertPoint(point, fromView: self)
            
            if CGRectContainsPoint(targetView.bounds, pointForTargetView) {
                return targetView.hitTest(pointForTargetView, withEvent: event)
            }
            else {
                KeyboardDismissingUIViewTarget = nil
                targetView.resignFirstResponder()
                return nil
            }
        }
        return super.hitTest(point, withEvent: event)
    }
}

//////////////////////////////////////////// IN TABLE
// table view должна быть сверху прицеплена ко view а не top guide
/**
Move table down after the editing and update changed value in CreateIssueViewController
*/
func textViewDidEndEditing(textView: UITextView) {
    if let scrollView = self.findScrollView() {
        let navigationBarHeight: CGFloat = 64
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
            options: nil, animations: { () -> Void in
                scrollView.contentOffset.y = -navigationBarHeight
            }, completion: nil)
    }
    notifyTextChanged(textView.text)
}


/**
Move table up to reveal the textView
*/
func textViewDidBeginEditing(textView: UITextView) {
    if let scrollView = self.findScrollView() {
        let currentPosition = textView.convertRectCorrectly(textView.frame, toView: scrollView)
        let visibleHeight = UIScreen.mainScreen().bounds.height - KeyboardHeight
        let fieldOy = scrollView.frame.origin.y + currentPosition.origin.y
        let extraOffsetUnderKeyboard: CGFloat = 44
        let maxFieldOy = visibleHeight - currentPosition.height - extraOffsetUnderKeyboard
        if fieldOy > maxFieldOy {
            let viewAdditionalOffset = fieldOy - maxFieldOy
            scrollView.setContentOffset(CGPointMake(0, viewAdditionalOffset), animated: true)
        }
    }
}

/**
Get nearest scrollView

:returns: scrollView or nil
*/
func findScrollView() -> UIScrollView? {
    var view = self.view
    while true {
        if let scroll = view as? UITableView { !!!!!!!!!!!! table!
            return scroll
        }
        view = view.superview
    }
}
/////////////////////////////////// UITextField in table /////////////////////////////////////////////////////////

/// last focused text field
var LastFocusedTextField: UITextField?

/// last focused tableView initial inset
var InitialTableViewContentInset: UIEdgeInsets?

/**
* Extenstion that scrolls related table view to show the textField.
* Method scrollTableView() must be invoked from both: keyboardWillShow and textFieldDidBeginEditing:
*   LastFocusedTextField = textField  // only in textFieldDidBeginEditing
*   LastFocusedTextField?.scrollTableView()
* Method resetTableViewInset() must be invoked from keyboardWillHide:
*   LastFocusedTextField?.resetTableViewInset()
*
* In textFieldDidEndEditing you must provide the following code:
*   if LastFocusedTextField == textField {
*       LastFocusedTextField = nil
*   }
* @author Alexander Volkov
* @version 1.0
*/
extension UITextField {
    
    /**
     Scrolls the tableView up to make this field visible
     
     - parameter parentView: the top parent view
     */
    func scrollTableView(parentView: UIView) {
        if let scrollView = self.findScrollView() {
            if InitialTableViewContentInset == nil {
                InitialTableViewContentInset = scrollView.contentInset
            }
            if let textField = LastFocusedTextField {
                let currentPosition = textField.convertRectCorrectly(textField.frame, toView: scrollView)
                let visibleHeight = UIScreen.mainScreen().bounds.height - KeyboardHeight
                let fieldOy = scrollView.frame.origin.y + currentPosition.origin.y
                let extraOffsetUnderKeyboard: CGFloat = 44
                let maxFieldOy = visibleHeight - currentPosition.height - extraOffsetUnderKeyboard
                if fieldOy > maxFieldOy {
                    let viewAdditionalOffset = fieldOy - maxFieldOy
                    scrollView.setContentOffset(CGPointMake(0, viewAdditionalOffset), animated: true)
                }
            }
        }
    }
    
    /**
    Resets scrollView insets to turn back the changes in scrollTableView()
    */
    func resetTableViewInset() {
        if let scrollView = self.findScrollView() {
            if let inset = InitialTableViewContentInset {
                InitialTableViewContentInset = nil
                scrollView.contentInset = inset
            }
            if scrollView.contentSize.height < scrollView.bounds.height {
                scrollView.contentOffset.y = 0
            }
        }
    }
    
    /**
    Get nearest scrollView
    
     - returns: scrollView or nil
    */
    func findScrollView() -> UIScrollView? {
        var view: UIView? = LastFocusedTextField
        if view != nil {
            while true {
                if let scroll = view as? UITableView {
                    return scroll
                }
                view = view?.superview
            }
        }
        return nil
    }
    
}

////////////////////////////////////////////
/* Когда не в таблице, а просто на экране в форме:
1. найти 0y поля формы при начале редактирования
2. Найти размер клавиатуры
3. Зная размер клавиатуры высчитать нужное положение поля для видимости
4. изменить одну из вертикальных constraint для всей формы, чтобы передвинуть форму вверх.
*/

// 1. и 3.4.

// 2. dodo почему то keyboardWillShow вызывается после textFieldShouldBeginEditing
/// the height of the opened keyboard
var KeyboardHeight: CGFloat = isIPad ? 403 : 258

// MARK: Keyboard

/**
Dismiss keyboard

- parameter textField: the textField

- returns: true
*/
func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
}

/**
Move form up when the field is focused

- parameter textField: the textField

- returns: true
*/
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    // move form up to reveal the field
    print("frame=\(textField.frame)") // dodo remove comment
    let currentPosition = textField.superview!.convertRect(textField.frame, toView: self.view)
    print("currentPosition=\(currentPosition)")
    
    let visibleHeight = UIScreen.mainScreen().bounds.height - KeyboardHeight
    let fieldOy = self.view.frame.origin.y + currentPosition.origin.y
    let extraOffsetUnderKeyboard: CGFloat = 44
    let maxFieldOy = visibleHeight - currentPosition.height - extraOffsetUnderKeyboard
    print("visibleHeight=\(visibleHeight)")
    print("maxFieldOx=\(maxFieldOy)")
    if fieldOy > maxFieldOy {
        let viewAdditionalOffset = fieldOy - maxFieldOy
        for constraint in formOffsetOy {
            constraint.constant = viewAdditionalOffset
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    return true
}


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
    KeyboardHeight = rect.height
}

/**
Keyboard disappear event handler

:param: notification the notification object
*/
func keyboardWillHide(notification: NSNotification) {
    for constraint in formOffsetOy {
        constraint.constant = 0
    }
    UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.view.layoutIfNeeded()
    })
}

/**
*  //////////////////////////////////////////////////////////////////////
*/

/**
 Date text field action handler
 
 - parameter sender: the text field
 */
@IBAction func textFieldEditing(sender: UITextField) {
    let datePickerView = UIDatePicker()
    datePickerView.datePickerMode = UIDatePickerMode.Date
    sender.inputView = datePickerView
    
    let toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.size.width, 44))
    let spaceButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target:nil, action:nil)
    let doneButton = UIBarButtonItem(title:"Done", style:UIBarButtonItemStyle.Done, target:self, action:"hideDatePicker")
    doneButton.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFontOfSize(15)], forState: UIControlState.Normal)
    
    let clearButton = UIBarButtonItem(title:"Clear", style:UIBarButtonItemStyle.Done, target:self, action:"cleanDate")
    clearButton.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFontOfSize(15)], forState: UIControlState.Normal)
    
    let titleLabel = UILabel(frame:CGRectMake(0, 0, 200, 44))
    titleLabel.textAlignment = NSTextAlignment.Center;
    titleLabel.textColor = UIColor.black()
    titleLabel.text = "Select Date"
    titleLabel.font = UIFont.boldSystemFontOfSize(17)
    let titleButton = UIBarButtonItem(customView: titleLabel)
    
    toolbar.setItems([clearButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
    sender.inputAccessoryView = toolbar;
    datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
}

func hideDatePicker() {
    datePickerValueChanged(self.dateField.inputView as! UIDatePicker)
    self.dateField.endEditing(true)
}

func cleanDate() {
    // TODO add selectedDate = nil
    dateField.text = ""
    self.dateField.endEditing(true)
}


//**
*  /////////////////////////////////////////////////////
*/

/**
 * Extends UIView to support table scrolling while text field in one of the cells is edited
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
extension UIView {
    
    func scrollToY(y: CGFloat) {
        UIView.beginAnimations("registerScroll", context: nil)
        UIView.setAnimationCurve(.EaseInOut)
        UIView.setAnimationDuration(0.3)
        self.transform = CGAffineTransformMakeTranslation(0, y)
        UIView.commitAnimations()
    }
    
    func scrollToView(view: UIView) {
        let theFrame = view.frame
        var y = theFrame.origin.y - 15
        y -= y/1.7
        self.scrollToY(-y)
    }
    
    func scrollElement(view: UIView, toPoint y: CGFloat) {
        let theFrame = view.frame
        let orig_y = theFrame.origin.y
        let diff = y - orig_y
        if diff < 0 {
            self.scrollToY(diff)
        }
        else {
            self.scrollToY(0)
        }
    }
}

func textFieldDidBeginEditing(textField: UITextField) {
    parent.view.scrollToView(textField)
}

func textFieldDidEndEditing(textField: UITextField) {
    parent.view.scrollToY(0)
}
