//
//  SlideMenuViewController.swift
//  dodo
//
//  Created by Volkov Alexander on 12.09.15.
//  Copyright (c) 2015 seriyvolk83dodo. All rights reserved.
//

import UIKit

/**
 * Represents the slide menu side width delegate protocol.
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
@objc
protocol SlideMenuSideWidthDelegate {
    
    /**
     Gets left slide menu width
     
     :returns: the width
     */
    func slideLeftMenuSideWidth() -> CGFloat
    
    /**
     Gets right slide menu width
     
     :returns: the width
     */
    func slideRightMenuSideWidth() -> CGFloat
}

/**
 * Represents the slide menu view controller class
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
class SlideMenuViewController: UIViewController {
    
    /**
     Gets the sliding state
     
     - LeftOpen:			the Left Open
     - RightOpen:		the Right Open
     - Collapsed:		the Collapsed
     - LeftOpening:		the Left Opening
     - RightOpening:		the Right Opening
     - LeftClosing:		the Left Closing
     - RightClosing:		the Right Closing
     - Interactive:		the Interactive
     */
    enum SlideState {
        case LeftOpen
        case RightOpen
        case Collapsed
        case LeftOpening
        case RightOpening
        case LeftClosing
        case RightClosing
        case Interactive
    }
    
    /// the menu state
    var state: SlideState = .Collapsed {
        didSet {
            // disable interaction on content views when menu is opened
            for view in contentView.subviews as! [UIView] {
                view.userInteractionEnabled = state == .Collapsed
            }
            swipeRightGesture.enabled = state != .LeftOpen
            swipeLeftGesture.enabled = state != .RightOpen
            interactiveEdgeGesture.enabled = (state != .LeftOpen) || (state != .RightOpen)
            tapGesture.enabled = (state == .LeftOpen) || (state == .RightOpen)
        }
    }
    
    /// the width delegate used to define menu width
    weak var widthDelegate: SlideMenuSideWidthDelegate?
    
    /// Gets the left side controller
    let leftSideController: UIViewController
    /// Gets the content controller
    var contentController: UIViewController
    /// Gets the right side controller
    let rightSideController: UIViewController
    /// Gets the animation duration
    var animationDuration = 0.3
    
    /// Gets the content view
    var contentView = UIView()
    /// Gets the content left constraint
    var contentLeft: NSLayoutConstraint!
    
    /// Gets the interactive gesture recognizer.
    var interactiveEdgeGesture = UIScreenEdgePanGestureRecognizer()
    /// Gets the swipe  gesture recognizer
    var swipeRightGesture = UISwipeGestureRecognizer()
    /// Gets the swipe gesture recognizer
    var swipeLeftGesture = UISwipeGestureRecognizer()
    /// Gets the tap gesture recognizer
    var tapGesture = UITapGestureRecognizer()
    /// Gets the interactive width
    var interactiveWidth = CGFloat(0)
    
    /**
     Creates new instance
     
     :param: leftSideController  the left side controller
     :param: rightSideController the right side controller
     :param: defaultContent      the default content
     :param: widthDelegate       the width delegate
     
     :returns: the created instance
     */
    init(leftSideController: UIViewController, rightSideController: UIViewController, defaultContent: UIViewController, widthDelegate: SlideMenuSideWidthDelegate) {
        self.leftSideController = leftSideController
        self.rightSideController = rightSideController
        self.contentController = defaultContent
        self.widthDelegate = widthDelegate
        
        tapGesture.enabled = false
        swipeRightGesture.direction = .Right
        swipeLeftGesture.direction = .Left
        interactiveEdgeGesture.edges = [.Left, .Right]
        
        contentView.addGestureRecognizer(swipeRightGesture)
        contentView.addGestureRecognizer(swipeLeftGesture)
        contentView.addGestureRecognizer(interactiveEdgeGesture)
        contentView.addGestureRecognizer(tapGesture)
        
        super.init(nibName: nil, bundle: nil)
        
        // add the left side controller
        addChildViewController(leftSideController)
        leftSideController.didMoveToParentViewController(self)
        leftSideController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftSideController.view)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
            options: NSLayoutFormatOptions(), metrics: nil, views: ["view" : leftSideController.view]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view(==menuWidth)]",
            options: NSLayoutFormatOptions(), metrics: ["menuWidth":leftMenuWidth()], views: ["view" : leftSideController.view]))
        
        // add the right side controller
        addChildViewController(rightSideController)
        rightSideController.didMoveToParentViewController(self)
        rightSideController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightSideController.view)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
            options: NSLayoutFormatOptions(), metrics: nil, views: ["view" : rightSideController.view]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(==menuWidth)]-0-|",
            options: NSLayoutFormatOptions(), metrics: ["menuWidth":rightMenuWidth()], views: ["view" : rightSideController.view]))
        
        // add the content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        contentLeft = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading,
                                         relatedBy: NSLayoutRelation.Equal, toItem: view,
                                         attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        view.addConstraint(contentLeft)
        view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal, toItem: contentView,
            attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
            options: NSLayoutFormatOptions(), metrics: nil, views: ["view" : contentView]))
        
        // create the gestures
        swipeRightGesture.addTarget(self, action: "swipeRightGestureRecognizerFired")
        swipeLeftGesture.addTarget(self, action: "swipeLeftGestureRecognizerFired")
        interactiveEdgeGesture.addTarget(self, action: "viewPanned:")
        tapGesture.addTarget(self, action: "hideSideMenu")
        
        setContentViewController(defaultContent)
    }
    
    /**
     Required initializer
     
     :param: aDecoder The a decoder
     
     :returns: always fails
     */
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     the left menu width.
     
     :returns: the width.
     */
    func leftMenuWidth() -> CGFloat {
        return widthDelegate?.slideLeftMenuSideWidth() ?? view.bounds.width - 40
    }
    
    /**
     the right menu width.
     
     :returns: the width.
     */
    func rightMenuWidth() -> CGFloat {
        return widthDelegate?.slideRightMenuSideWidth() ?? view.bounds.width - 50
    }
    
    /**
     Called by gesture recognizer, open right side menu
     or hide left side if it's already open.
     */
    func swipeLeftGestureRecognizerFired() {
        if state == .Collapsed {
            showRightSideMenu()
        }
        else if state == .LeftOpen {
            hideSideMenu()
        }
    }
    
    /**
     Called by gesture recognizer, open left side menu
     or hide right side if it's already open.
     */
    func swipeRightGestureRecognizerFired() {
        if state == .Collapsed {
            showLeftSideMenu()
        }
        else if state == .RightOpen {
            hideSideMenu()
        }
    }
    
    /**
     Show left side menu.
     */
    func showLeftSideMenu(callback: (()->())? = nil) {
        if state != .Collapsed {
            return
        }
        
        state = .LeftOpening
        view.insertSubview(leftSideController.view, belowSubview: contentView)
        contentLeft.constant = leftMenuWidth()
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                                   options: .CurveEaseOut, animations: { () -> Void in
                                    self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            self.state = .LeftOpen
            callback?()
        }
    }
    
    /**
     Show right side menu.
     */
    func showRightSideMenu() {
        if state != .Collapsed {
            return
        }
        
        state = .RightOpening
        view.insertSubview(rightSideController.view, belowSubview: contentView)
        contentLeft.constant = rightMenuWidth() * -1
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
                                   options: .CurveEaseOut, animations: { () -> Void in
                                    self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            self.state = .RightOpen
        }
    }
    
    /**
     Hide side menu.
     */
    func hideSideMenu() {
        if state != .LeftOpen && state != .RightOpen {
            return
        }
        
        // hide the keyboard
        self.view.endEditing(true)
        
        state = state == .LeftOpen ? .LeftClosing : .RightClosing
        contentLeft.constant = 0
        
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
                                   options: .CurveEaseOut, animations: { () -> Void in
                                    self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            self.state = .Collapsed
        }
    }
    
    /**
     View has been panned.
     
     :param: gesture The gesture
     */
    func viewPanned(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            state = .Interactive
        case .Changed:
            let translation = gesture.translationInView(gesture.view!).x
            contentLeft.constant = max(leftMenuWidth(), min(translation, rightMenuWidth()))
            
            view.layoutIfNeeded()
        case .Ended:
            
            var percentage : CGFloat = 0
            if contentLeft.constant > 0 {
                percentage = min(1, (leftMenuWidth() - contentLeft.constant) / leftMenuWidth())
                view.insertSubview(leftSideController.view, belowSubview: contentView)
            }
            else {
                percentage = min(1, (rightMenuWidth() - (contentLeft.constant * -1)) / rightMenuWidth())
                view.insertSubview(rightSideController.view, belowSubview: contentView)
            }
            
            let willShow = percentage < 0.7
            let leftCaseConstant = willShow ? leftMenuWidth() : 0
            let rightCaseConstant = willShow ? (rightMenuWidth() * -1) : 0
            
            contentLeft.constant = max(leftCaseConstant, rightCaseConstant)
            
            UIView.animateWithDuration(
                animationDuration * Double(abs(percentage)),
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .CurveEaseOut,
                animations: { () -> Void in
                    self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                if self.contentLeft.constant == 0 {
                    self.state = .Collapsed
                }
                else {
                    self.state = self.contentLeft.constant > 0 ? .LeftOpen : .RightOpen
                }
                
            }
            
        case .Cancelled, .Failed, .Possible:
            // cancel, failed close
            
            contentLeft.constant = 0
            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
                                       options: .CurveEaseOut, animations: { () -> Void in
                                        self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.state = .Collapsed
            }
        }
    }
    
    /**
     Set content view controller.
     
     :param: newController The new controller
     */
    func setContentViewController(newController: UIViewController) {
        // delete old
        if contentController.parentViewController != nil {
            contentController.willMoveToParentViewController(nil)
            contentController.removeFromParentViewController()
            contentController.view.removeFromSuperview()
        }
        
        contentController = newController
        
        // add the new
        addChildViewController(contentController)
        contentController.didMoveToParentViewController(self)
        contentController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentController.view)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
            options: NSLayoutFormatOptions(), metrics: nil, views: ["view" : contentController.view]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|",
            options: NSLayoutFormatOptions(), metrics: nil, views: ["view" : contentController.view]))
        
        self.view.layoutIfNeeded()
        
        hideSideMenu()
    }
    
    
    /**
     Called when new view controller is being pushed
     side menu is going to hide
     
     :param: aNotification   notification with new view controller
     */
    func newViewControllerIsBeingPushed(aNotification : NSNotification) {
        self.hideSideMenu()
    }
}

/**
 * Helpful extensions related to SlideMenuViewController
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
extension UIViewController {
    
    /// gets the slide menu controller
    var slideMenuController: SlideMenuViewController? {
        var parent: UIViewController? = self
        while (parent != nil) {
            if let parent = parent as? SlideMenuViewController {
                return parent
            }
            parent = parent?.parentViewController
        }
        return nil
    }
    
    /**
     Show view controller from given storyboard and with given identifier
     
     :param: storyboardName the storyboard name
     :param: identifier     the view controller identifier
     */
    func showController(storyboardName: String = "Main", identifier: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier(identifier) as! UIViewController
        self.slideMenuController?.setContentViewController(controller.wrapInNavigationController())
    }
    
    /**
     Add menu button
     */
    func addMenuButton() {
        var menuBtn = UIBarButtonItem(image: UIImage(named: "menu-icon"), style: .Plain, target: self, action: "showLeftSideMenuAction")
        self.navigationItem.leftBarButtonItem = menuBtn
    }
    
    // dodo alternative addMenuButton
    /**
     Add menu button
     */
    func addMenuButton() {
        let button = UIButton(frame: CGRectMake(-9, 7.5, 32, 32)) // position is taked from the design
        button.setImage(UIImage(named: "iconMenu"), forState: .Normal)
        button.addTarget(self, action: "showLeftSideMenuAction", forControlEvents: UIControlEvents.TouchUpInside)
        let view = UIView(frame: CGRectMake(0, 0, 44, 44))
        view.addSubview(button)
        let menuBtn = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = menuBtn
    }
    
    /**
     "Menu" button action handler
     
     :param: sender the button
     */
    @IBAction func showLeftSideMenuAction() {
        slideMenuController?.showLeftSideMenu()
    }
    
    /**
     Right side menu button action handler
     
     :param: sender the button
     */
    @IBAction func showRightSideMenuAction() {
        slideMenuController?.showRightSideMenu()
    }
}
