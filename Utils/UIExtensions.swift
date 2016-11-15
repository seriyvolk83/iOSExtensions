//
//  UIExtensions.swift
//  dodo
//
//  Created by Alexander Volkov on 16.04.15.
//  Copyright (c) 2015 seriyvolk83dodo. All rights reserved.
//

import UIKit

/**
A set of helpful extensions for classes from UIKit
*/

/**
 * Extends UIColor with color methods from design.
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UIColor {
    
    /**
     Creates new color with RGBA values from 0-255 for RGB and a from 0-1
     
     - parameter r: the red color
     - parameter g: the green color
     - parameter b: the blue color
     - parameter a: the alpha color
     */
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
    
    /**
     Creates new color with RGBA values from 0-255 for RGB and a from 0-1
     
     - parameter g: the gray color
     - parameter a: the alpha color
     */
    convenience init(gray: CGFloat, a: CGFloat = 1) {
        self.init(r: gray, g: gray, b: gray, a: a)
    }
    
    /**
     Get UIColor from hex string, e.g. "FF0000" -> red color
     
     - parameter hexString: the hex string
     - returns: the UIColor instance or nil
     */
    class func fromString(hexString: String) -> UIColor? {
        if hexString.characters.count == 6 {
            let redStr = hexString.substringToIndex(hexString.startIndex.advancedBy(2))
            let greenStr = hexString.substringWithRange(
                hexString.startIndex.advancedBy(2)..<hexString.startIndex.advancedBy(4))
            let blueStr = hexString.substringFromIndex(hexString.startIndex.advancedBy(4))
            return UIColor(
                r: CGFloat(Int(redStr, radix: 16)!),
                g: CGFloat(Int(greenStr, radix: 16)!),
                b: CGFloat(Int(blueStr, radix: 16)!))
        }
        return nil
    }
    
    /**
     Get same color with given transparancy
     
     - parameter alpha: the alpha channel
     
     - returns: the color with alpha channel
     */
    func alpha(alpha: CGFloat) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b :CGFloat = 0
        if (self.getRed(&r, green:&g, blue:&b, alpha:nil)) {
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }
        return self
    }
    
    /**
     Gray color (#aaaaaa)
     
     - returns: UIColor instance
     */
    class func gray() -> UIColor {
        return UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
    }
    
    /**
     Gray color (#cccccc) for search field border
     
     :returns: UIColor instance
     */
    class func grayBorder() -> UIColor {
        return UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
    }
    
    /**
     Gray color (#999999) for search field placeholder
     
     :returns: UIColor instance
     */
    class func placeholderColor() -> UIColor {
        return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 153/255)
    }
}

/**
* Custom UIPageControl
*
* @author Alexander Volkov
* @version 1.0
*/
class CustomUIPageControl: UIPageControl {
    
    func updateDots() {
        for i in 0..<self.subviews.count {
            let view = self.subviews[i] as! UIView
            if i == self.currentPage {
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor.redColor().CGColor
            }
            else {
                view.layer.borderWidth = 0
            }
            view.setNeedsDisplay()
        }
    }
}

/**
* Adds methods for changing navigation title.
*
* @author Alexander Volkov
* @version 1.0
*/
extension UINavigationController {
    
    /**
    Changes navigation bar title to given title.
    Applies dark font color assuming that the navigation bar is white.
    
    :param: title the title
    */
    func setNavigationTitleForWhiteBackground(title: String) {
        // Title
        let font = UIFont(name: "ProximaNova-Regular", size: 18)!
        var string = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.gray()
        ])
        let label = UILabel(frame: CGRectMake(0, 0, 20, 150))
        label.attributedText = string
        self.navigationBar.topItem?.titleView = label
        
        // Add white background with rounded corners
        let bgView = UIView(frame: CGRectMake(0, 20, UIScreen.mainScreen().bounds.width, 44))
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = UIColor.greenColor()
        let image = UIImage.imageFromView(bgView)
        
        // Use different images for different screen sizes
        if !isIPhone5() {
            self.navigationBar.setBackgroundImage(UIImage(named: "navBg"), forBarMetrics: UIBarMetrics.Default)
        }
        else {
            self.navigationBar.setBackgroundImage(UIImage(named: "navBgIPhone5"), forBarMetrics: UIBarMetrics.Default)
        }
    }
    
}

// UINavigationController Setup

/**
* Extends UIViewController with shortcut methods
*
* - author: TCASSEMBLER
* - version: 1.0
*/
extension UIViewController {
    
    /**
    Change navigation bar title with given title assuming that the navigation bar is white.
    
    :param: title the title
    */
    func initWhiteNavigationBar(title: String) {
        self.navigationController?.setNavigationTitleForWhiteBackground(title)
    }
    
    /**
    Initialize right navigation buttons
    
    :param: buttons the data for the buttons (icon and selector)
    */
    func initRightButtons(buttons: [(UIImage?, Selector)]) {
        var list = [UIBarButtonItem]()
        for data in buttons {
            let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            button.frame = CGRectMake(10, 0, 30, 30)
            button.setImage(data.0, forState: UIControlState.Normal)
            button.addTarget(self, action: data.1, forControlEvents: .TouchUpInside)
            list.append(UIBarButtonItem(customView: button))
        }
        self.navigationItem.rightBarButtonItems = list
    }
    
    /**
    Add "Close" button to the navigation bar
    */
    func initRightCloseButton() {
        // Right navigation button ("CLOSE")
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 50, 30))
        let buttonClose = UIButton()
        buttonClose.addTarget(self, action: "closeButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        buttonClose.frame = CGRectMake(10, 0, 50, 30);
        buttonClose.setAttributedTitle(createAttributedStringForNavigation("Close"), forState: UIControlState.Normal)
        
        customBarButtonView.addSubview(buttonClose)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }
    
    /**
    Initialize back button for next view controller that will be pushed
    */
    func initBackButtonFromParent() {
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    // dodo !!!!!!!!!!!! Это лучшый способ. Добавить вызов initBackButtonFromChild() в viewWillAppear
    /**
    Initialize back button for current view controller that will be pushed
    */
    func initBackButtonFromChild() {
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
        // Button
        let button = UIButton()
        button.addTarget(self, action: "backButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 40, 30);
        
        // Button title
        button.setAttributedTitle(createAttributedStringForNavigation("Back"), forState: UIControlState.Normal)
        button.setImage(UIImage(named:"backArrow"), forState: UIControlState.Normal)
        
        // Set custom view for left bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }
    
    /**
    Creates attributed string from given text.
    Returns uppercase string with a special font.
    
    - parameter text: the text
    
    - returns: NSMutableAttributedString
    */
    func createAttributedStringForNavigation(text: String) -> NSMutableAttributedString {
        let string = NSMutableAttributedString(string: text, attributes: [
            NSFontAttributeName: UIFont(name: Fonts.Regular, size: 18.0)!,
            NSForegroundColorAttributeName: UIColor(r: 0, g: 157, b: 206)
            ])
        return string
    }

    /**
    "Close" button action handler.
    */
    func closeButtonAction() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    "Back" button action handler
    */
    func backButtonAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

// ADD background or image in NSAttributedString
if item.question.hasRecommendation {
    
    let attachment = NSTextAttachment()
    attachment.image = #imageLiteral(resourceName: "iconRecommendation")
    let attrStringWithImage = NSAttributedString(attachment: attachment)
    attributedString.replaceCharactersInRange(NSMakeRange(text1.length, text2.length), withAttributedString: attachment)
    // dodo
    //            attributedString.addAttributes([
    //                NSBackgroundColorAttributeName: UIColor(r: 137, g: 141, b: 141),
    //                NSFontAttributeName: UIFont(name: Fonts.BARIOL_Regular, size: 11)!,
    //                NSForegroundColorAttributeName: UIColor.whiteColor()
    //                ], range: NSMakeRange(text1.length, text2.length))
}

UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
// UINavigationBar.appearance().barTintColor = UIColor(gray: 253) // dodo

// navigation title style
let fontSize: CGFloat = 15
let titleAttribute = [NSForegroundColorAttributeName: UIColor.topMenuTitle(),
    NSFontAttributeName:UIFont(name: Fonts.Light, size: fontSize)!]
UINavigationBar.appearance().titleTextAttributes = titleAttribute

// dodo Чтобы убрать текст "Back" нужно установить пустую строку для Back button item (" ") либо в IB (лучше), либо в коде

UINavigationBar.appearance().shadowImage = UIImage()
UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)


/// COMPLETE EXAMPLE FOR APP_DELEGATE 
UITabBarItem.appearance().setTitleTextAttributes(
    [NSFontAttributeName: UIFont(name: Fonts.Regular, size: 10)!], forState: .Normal)
UIBarButtonItem.appearance().setTitleTextAttributes(
    [NSFontAttributeName: UIFont(name: Fonts.Regular, size: 17)!], forState: .Normal)
UINavigationBar.appearance().tintColor = UIColor.whiteColor()
UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backButton")
UINavigationBar.appearance().shadowImage = UIImage()
UINavigationBar.appearance().backgroundColor = UIColor.clearColor()
UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
UINavigationBar.appearance().translucent = false ??
///
/**
* Extension adds methods that change navigation bar
*
* @author TCASSEMBLER
* @version 1.0
*/
extension UIViewController {
    
    /**
    Changes navigation bar design
    */
    func setupNavigationBar(isTransparent isTransparent: Bool = false) {
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav-header-bg"
            + (isTransparent ? "-transparent" : "")),
            forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.translucent = isTransparent
        if isTransparent {
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        setupNavigationBarTitle()
    }
    
    /**
    Changes the navigation title style
    */
    func setupNavigationBarTitle() {
        // navigation title style
        let fontSize: CGFloat = 17
        let titleAttribute = [NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName:UIFont(name: Fonts.Regular, size: fontSize)!]
        navigationController?.navigationBar.titleTextAttributes = titleAttribute
    }
    
    /**
    Add right button to the navigation bar
    
    - parameter title:    the butotn title
    - parameter selector: the selector to invoke when tapped
    */
    func addRightButton(title: String, selector: Selector) {
        // Right navigation button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createBarButton(title, selector: selector))
    }
    
    /**
    Add left button to the navigation bar
    
    - parameter title:    the butotn title
    - parameter selector: the selector to invoke when tapped
    */
    func addLeftButton(title: String, selector: Selector) {
        // Left navigation button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: createBarButton(title, selector: selector))
    }
    
    /**
    Create button for the navigation bar
    
    - parameter title:    the butotn title
    - parameter selector: the selector to invoke when tapped
    
    - returns: the view
    */
    func createBarButton(title: String, selector: Selector) -> UIView {
        // Right navigation button
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 50, 30))
        let b = UIButton()
        b.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        b.frame = CGRectMake(-5, 0, 60, 30);
        b.setAttributedTitle(createAttributedStringForNavigation(title), forState: UIControlState.Normal)
        
        customBarButtonView.addSubview(b)
        return customBarButtonView
    }
    
    /**
    Creates attributed string from given text.
    Returns uppercase string with a special font.
    
    - parameter text: the text
    */
    func createAttributedStringForNavigation(text: String) -> NSMutableAttributedString {
        let string = NSMutableAttributedString(string: text, attributes: [
            NSFontAttributeName: UIFont(name: Fonts.Bold, size: 14.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ])
        return string
    }
    
    /**
    Initialize back button for current view controller
    */
    func addBackButton() {
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
        // Button
        let button = UIButton()
        button.addTarget(self, action: "backButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(-17, 0, 57, 30) // position like in design
        
        // Button icon
        button.setImage(UIImage(named: "iconBack"), forState: UIControlState.Normal)
        
        // Set custom view for bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }
    
    /**
    "Back" button action handler
    */
    func backButtonAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
    Add right button with given icon
    
    - parameter iconName: the name of the icon
    - parameter selector: the selector to invoke when tapped
    */
    func addRightButton(iconName iconName: String, selector: Selector) {
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
        // Button
        let button = UIButton()
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 59, 30) // position like in design
        
        // Button icon
        button.setImage(UIImage(named: iconName), forState: UIControlState.Normal)
        
        // Set custom view for bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }
}

/**
 View transition type (from corresponding side)
 */
enum Transition {
    case Right, Left, Bottom, None
}
/**
 * Methods for custom transitions from the sides
 *
 * @author Alexander Volkov
 * @version 1.0
 */
extension UIViewController {
    
    /**
     Show view controller from the side.
     See also dismissViewControllerToSide()
     
     - parameter viewController: the view controller to show
     - parameter side:           the side to move the view controller from
     - parameter bounds:         the bounds of the view controller
     - parameter callback:       the callback block to invoke after the view controller is shown and stopped
     */
    func showViewControllerFromSide(viewController: UIViewController,
        inContainer containerView: UIView, bounds: CGRect, side: Transition, _ callback:(()->())?) {
            // New view
            let toView = viewController.view;
            
            // Setup bounds for new view controller view
            toView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            var frame = bounds
            frame.origin.y = containerView.frame.height - bounds.height
            switch side {
            case .Bottom:
                frame.origin.y = containerView.frame.size.height // From bottom
            case .Left:
                frame.origin.x = -containerView.frame.size.width // From left
            case .Right:
                frame.origin.x = containerView.frame.size.width // From right
            default:break
            }
            toView.frame = frame
            
            self.addChildViewController(viewController)
            containerView.addSubview(toView)
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0, options: .CurveEaseOut, animations: { () -> Void in
                    switch side {
                    case .Bottom:
                        frame.origin.y = containerView.frame.height - bounds.height + bounds.origin.y
                    case .Left, .Right:
                        frame.origin.x = 0
                    default:break
                    }
                    toView.frame = frame
                }) { (fin: Bool) -> Void in
                    viewController.didMoveToParentViewController(self)
                    callback?()
            }
    }
    
    /**
     Dismiss the view controller through moving it back to given side
     See also showViewControllerFromSide()
     
     - parameter viewController: the view controller to dismiss
     - parameter side:           the side to move the view controller to
     - parameter callback:       the callback block to invoke after the view controller is dismissed
     */
    func dismissViewControllerToSide(viewController: UIViewController, side: Transition, _ callback:(()->())?) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0, options: .CurveEaseOut, animations: { () -> Void in
                // Move back to bottom
                switch side {
                case .Bottom:
                    viewController.view.frame.origin.y = self.view.frame.height
                case .Left:
                    viewController.view.frame.origin.x = -self.view.frame.size.width
                case .Right:
                    viewController.view.frame.origin.x = self.view.frame.size.width
                default:break
                }
                
            }) { (fin: Bool) -> Void in
                viewController.willMoveToParentViewController(nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
                callback?()
        }
    }
    
}

/**
 * Methods for loading and removing a view controller and its views,
 * and shortcut helpful methods for instantiating UIViewController
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UIViewController {
    
    /**
     Shortcut method for loading view controller, making it full transparent and fading in.
     
     - parameter viewController: the view controller to show
     - parameter containerView:  view to load into
     - parameter callback:       callback block to invoke after the view controller is fully visible (alpha=1)
     */
    func fadeInViewController(viewController: UIViewController, _ containerView: UIView? = nil,
                              _ callback: (()->())? = nil) {
        let viewToShow = viewController.view
        viewToShow.alpha = 0
        loadViewController(viewController, containerView ?? self.view)
        
        // Fade in
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            viewToShow.alpha = 1
        }) { (fin: Bool) -> Void in
            callback?()
        }
    }
    
    /**
    Add the view controller and view into the current view controller
    and given containerView correspondingly.
    Uses autoconstraints.
    
    - parameter childVC:       view controller to load
    - parameter containerView: view to load into
    */
    func loadViewController(childVC: UIViewController, _ containerView: UIView) {
        let childView = childVC.view
        childView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth,  UIViewAutoresizing.FlexibleHeight]
        loadViewController(childVC, containerView, withBounds: containerView.bounds)
    }
    
    /**
    Add the view controller and view into the current view controller
    and given containerView correspondingly.
    Sets fixed bounds for the loaded view in containerView.
    Constraints can be added manually or automatically.
    
    - parameter childVC:       view controller to load
    - parameter containerView: view to load into
    - parameter bounds:        the view bounds
    */
    func loadViewController(childVC: UIViewController, _ containerView: UIView, withBounds bounds: CGRect) {
        let childView = childVC.view
        
        childView.frame = bounds
        
        // Adding new VC and its view to container VC
        self.addChildViewController(childVC)
        containerView.addSubview(childView)
        
        // Finally notify the child view
        childVC.didMoveToParentViewController(self)
    }
    
    /**
    Remove view controller and view from their parents
    */
    func removeFromParent() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    /**
    Instantiate given view controller.
    The method assumes that view controller is identified the same as its class
    and view is defined in the same storyboard.
    
    - parameter viewControllerClass: the class name
    - parameter storyboardName:      the name of the storyboard (optional)
    
    - returns: view controller or nil
    */
    func create<T: UIViewController>(viewControllerClass: T.Type, storyboardName: String? = nil) -> T? {
        let className = NSStringFromClass(viewControllerClass).componentsSeparatedByString(".").last!
        var storyboard = self.storyboard
        if let storyboardName = storyboardName {
            storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        }
        return storyboard?.instantiateViewControllerWithIdentifier(className) as? T
    }
    
    /**
    Instantiate given view controller and push into navigation stack
    
    - parameter viewControllerClass: the class name
    - parameter storyboardName:      the name of the storyboard (optional)
    
    - returns: view controller or nil
    */
    func pushViewController<T: UIViewController>(viewControllerClass: T.Type, storyboardName: String? = nil) -> T? {
        if let vc = create(viewControllerClass, storyboardName: storyboardName) {
            self.navigationController?.pushViewController(vc, animated: true)
            return vc
        }
        return nil
    }
    
    /**
    Instantiate given view controller.
    The method assumes that view controller is identified the same as its class
    and view is defined in "Main" storyboard.
    
    - parameter viewControllerClass: the class name
    
    - returns: view controller or nil
    */
    class func createFromMainStoryboard<T: UIViewController>(viewControllerClass: T.Type) -> T? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let className = NSStringFromClass(viewControllerClass).componentsSeparatedByString(".").last!
        return storyboard.instantiateViewControllerWithIdentifier(className) as? T
    }
    
    /**
    Get currently opened view controller
    
    - returns: the top visible view controller
    */
    class func getCurrentViewController() -> UIViewController? {
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    /**
    Returns the navigation controller if it exists
    
    - returns: the navigation controller or nil
    */
    class func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    /**
    Wraps the given view controller into NavigationController
    
    - returns: NavigationController instance
    */
    func wrapInNavigationController() -> UINavigationController {
        let navigation = UINavigationController(rootViewController: self)
        navigation.navigationBar.translucent = false
        return navigation
    }
}

/* Last created blurred image.
Can be used as cache or where there is no ability to access view controller that need to blur
*/
var UIViewControllerLastExtraLightEffectImage: UIImage?
/**
* Methods for creating snapshots
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    // Returns blurred image of this window
    func createBlurredImageView() -> UIImage {
        let blurredImage = createSnapshort().applyExtraLightEffect()
        
        // Save image in cache
        UIViewControllerLastExtraLightEffectImage = blurredImage
        return blurredImage
        
    }
    
    /**
    Create snapshort of the current view
    
    :returns: snapshort image
    */
    func createSnapshort() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
//        UIGraphicsBeginImageContext(self.view.frame.size) dodo
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: false)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /**
    Get cached blurred snapshot. If the spanshot is requested for the first time,
    then creates a new one.
    
    :returns: a blurred snapshot image
    */
    class func getCachedBlurredSnapshort() -> UIImage {
        if let image = UIViewControllerLastExtraLightEffectImage {
            return image
        }
        let top = UIApplication.sharedApplication().keyWindow?.rootViewController
        return top!.createBlurredImageView()
    }

}

/**
* Extends UIViewController with shortcut methods
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Initialize back button for next view controller that will be pushed
    */
    func initBackButtonFromParent() {
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    /**
    Initialize back button for current view controller that will be pushed
    */
    func initBackButtonFromChild() {
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
        // Button
        let button = UIButton()
        button.addTarget(self, action: "backButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 40, 30);
        
        // Button title
        button.setAttributedTitle(createAttributedStringForNavigation("Back"), forState: UIControlState.Normal)
        button.setImage(UIImage(named:"backArrow"), forState: UIControlState.Normal)
        
        // Set custom view for left bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }
    
}

/**
* Extends UIView with shortcut methods
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIView {
    
    /**
    Adds bottom border to the view
     
     - parameter color:       the border color
     - parameter borderWidth: the size of the border
    */
    func addBottomBorder(color: UIColor = UIColor.boxBorderColor(), borderWidth: CGFloat = 0.5) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, self.frame.height - borderWidth, self.frame.size.width, borderWidth);
        bottomBorder.backgroundColor = color.CGColor
        self.layer.addSublayer(bottomBorder)
    }
    
    /**
    Adds bottom border to the view with given side margins
    
    - parameter height:  the height of the border
    - parameter color:   the border color
    - parameter margins: the left and right margin
    
    - returns: the border view
    */
    func addBottomBorder(height height: CGFloat = 1, color: UIColor = UIColor(r: 105, g: 154, b: 198), margins: CGFloat = 0) -> UIView {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1, constant: height))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1, constant: margins))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1, constant: -margins))
        return border
    }
    
    /**
     Adds top border to the view with given side margins
     
     - parameter height:  the height of the border
     - parameter color:   the border color
     - parameter margins: the left and right margin
     
     - returns: the border view
     */
    func addTopBorder(height height: CGFloat = 1, color: UIColor = UIColor.blue(), margins: CGFloat = 0) -> UIView {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1, constant: height))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1, constant: margins))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1, constant: -margins))
        return border
    }
    
    /**
    Add border for the view
    
    - parameter color:       the border color
    - parameter borderWidth: the size of the border
    */
    func addBorder(color: UIColor = UIColor.boxBorderColor(), borderWidth: CGFloat = 0.5) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.CGColor
    }

    /**
    Add border view for the view in superview
    
    - parameter borderWidth: the size of the border
    - parameter color:       the border color
    - parameter shift:       the shift of the view (if used as a shadow)
    
    - returns: the view
    */
    func addBorderView(borderWidth: CGFloat = 2, color: UIColor = UIColor.whiteColor(),
        shift: CGSize = CGSizeZero) -> UIView {
            let border = UIView()
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            let superview = self.superview!
            superview.addSubview(border)
            
            superview.addConstraint(NSLayoutConstraint(item: border,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1, constant: -borderWidth + shift.height))
            superview.addConstraint(NSLayoutConstraint(item: border,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1, constant: borderWidth + shift.height))
            superview.addConstraint(NSLayoutConstraint(item: border,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1, constant: -borderWidth + shift.width))
            superview.addConstraint(NSLayoutConstraint(item: border,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1, constant: borderWidth + shift.width))
            superview.bringSubviewToFront(self)
            border.layoutIfNeeded()
            border.makeRound()
            return border
    }
}

/**
* Extension that replaces standard convertRect
*
* @author TCASSEMBLER
* @version 1.0
*/
extension UIView {
    
    /**
    Same as standard convertRect but fixed to provide correct origin coordinates.
    
    - parameter rect: the rect to convert
    - parameter view: the reference view there to convert the coordinates to
    
    - returns: the coordinates of the given rect in the given view
    */
    func convertRectCorrectly(rect: CGRect, toView view: UIView) -> CGRect {
        if UIScreen.mainScreen().scale == 1 {
            return self.convertRect(rect, toView: view)
        }
        else if self == view {
            return rect
        }
        else {
            var rectInParent = self.convertRect(rect, toView: self.superview)
            rectInParent.origin.x /= UIScreen.mainScreen().scale
            rectInParent.origin.y /= UIScreen.mainScreen().scale
            let superViewRect = self.superview!.convertRectCorrectly(self.superview!.frame, toView: view)
            rectInParent.origin.x += superViewRect.origin.x
            rectInParent.origin.y += superViewRect.origin.y
            return rectInParent
        }
    }
}

/**
 * Separator inset fix
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class ZeroMarginsCell: UITableViewCell {
    
    /// separator inset fix
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
    
    /**
    Setup UI
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }
}

// ios8 separator inset fix dodo
// set the "separator inset" to be "custom", and left=0, right=0
class ZeroMaringsTableView : UITableView {
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
}

/**
 * Shortcut methods for UITableView
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UITableView {
    
    /**
    Prepares tableView to have zero margins for separator
    and removes extra separators after all rows
    */
    func separatorInsetAndMarginsToZero() {
        let tableView = self
        if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    /**
    Register given cell class for the tableView.
    
    - parameter cellClass: a cell class
    */
    func registerCell(cellClass: UITableViewCell.Type) {
        let className = NSStringFromClass(cellClass).componentsSeparatedByString(".").last!
        let nib = UINib(nibName: className, bundle: nil)
        self.registerNib(nib, forCellReuseIdentifier: className)
    }
    
    /**
    Get cell of given class for indexPath
    
    - parameter indexPath: the indexPath
    - parameter cellClass: a cell class
    
    - returns: a reusable cell
    */
    func getCell<T: UITableViewCell>(indexPath: NSIndexPath, ofClass cellClass: T.Type) -> T {
        let className = NSStringFromClass(cellClass).componentsSeparatedByString(".").last!
        return self.dequeueReusableCellWithIdentifier(className, forIndexPath: indexPath) as! T
    }
}

/// MARK: - /////////////////////////////// NO CACHE for loading images
/**
* Helpful methods to load avatars
*
* - author: TCASSEMBLER
* - version: 1.0
*/
extension UIImage {
    
    /**
    Load image asynchronously and return in callback
    
    :param: url      the url of the image
    :param: callback the callback block to return the image
    */
    class func loadFromURLAsync(url: NSURL, callback: (UIImage?)->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let imageData = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue(), {
                if let data = imageData {
                    if let image = UIImage(data: data) {
                        // If image is correct, then return it
                        callback(image)
                        return
                    }
                    else {
                        println("ERROR: Error occured while creating image from the data: \(data)")
                    }
                }
                // No image - return nil
                callback(nil)
            })
        })
    }
    
    /**
     Make the image square
     
     - parameter size: the size of the square
     
     - returns: square image
     */
    func square(size: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: CGSize(width: size, height: size))
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(self.CGImage, rect)!
        return UIImage(CGImage: imageRef, scale: 0, orientation: self.imageOrientation)
    }
    
    /**
     Resize image
     
     - parameter sizeChange: the new size
     
     - returns: resized image
     */
    func imageResize(sizeChange: CGSize)-> UIImage {
        let imageObj = self
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    /**
     Resize image
     
     - parameter longSide: the long side length
     
     - returns: resized image
     */
    func imageResizeProportionally(longSide: CGFloat)-> UIImage {
        let image = self
        if max(image.size.width, image.size.height) <= longSide {
            return image
        }
        var size: CGSize!
        if image.size.width > image.size.height {
            size = CGSize(width: longSide, height: longSide * image.size.height / image.size.width)
        }
        else {
            size = CGSize(width: longSide * image.size.width / image.size.height, height: longSide)
        }
        return imageResize(size)
    }
}

/// MARK: - //////////////////////////////////////// IMAGES ARE CACHED

/// type alias for image request callback
typealias ImageCallback = (UIImage?)->()

/**
 * Class for storing in-memory cached images
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class UIImageCache {
    dodo private and save/get methods
    /// Cache for images
    var CachedImages = [String: (UIImage?, [ImageCallback])]()
    
    /// the singleton
    class var sharedInstance: UIImageCache {
        struct Singleton { static let instance = UIImageCache() }
        return Singleton.instance
    }
}

/**
 * Extends UIImage with a shortcut method.
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UIImage {
    
    /**
    Get image from given view
    
    :param: view the view
    
    :returns: UIImage
    */
    class func imageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
    Load image asynchronously

    - parameter url:      image URL
    - parameter callback: the callback to return the image
    */
    class func loadFromURLAsync(url: NSURL, callback: ImageCallback) {
        let key = url.absoluteString
        
        // If there is cached data, then use it
        if let data = UIImageCache.sharedInstance.CachedImages[key] {
            if data.1.isEmpty { // Is image already loadded, then use it
                callback(data.0)
            }
            else { // If image is not yet loaded, then add callback to the list of callbacks
                var savedCallbacks: [ImageCallback] = data.1
                savedCallbacks.append(callback)
                UIImageCache.sharedInstance.CachedImages[key] = (nil, savedCallbacks)
            }
            return
        }
        // If the image is first time requested, then load it
        UIImageCache.sharedInstance.CachedImages[key] = (nil, [callback])
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else { callback(nil); return }
                    if let image = UIImage(data: data) {
                        
                        // Notify all callbacks
                        for callback in UIImageCache.sharedInstance.CachedImages[key]!.1 {
                            callback(image)
                        }
                        UIImageCache.sharedInstance.CachedImages[key] = (image, [])
                        return
                    }
                    else {
                        print("ERROR: Error occured while creating image from the data: \(data)")
                    }
                }
                }.resume()
        })
    }
    
    /**
     Load image asynchronously.
     More simple method than loadFromURLAsync() that helps to cover common fail cases
     and allow to concentrate on success loading.
     
     - parameter urlString: the url string
     - parameter callback:  the callback to return the image
     */
    public class func loadAsync(urlString: String?, callback: (UIImage?)->()) {
        if let urlStr = urlString {
            if urlStr.hasPrefix("http") {
                if let url = NSURL(string: urlStr) {
                    UIImage.loadFromURLAsync(url, callback: { (image: UIImage?) -> () in
                        callback(image)
                    })
                    return
                }
                else {
                    print("ERROR: Wrong URL: \(urlStr)")
                    callback(nil)
                }
            }
                // If urlString is not real URL, then try to load image from assets
            else if let image = UIImage(named: urlStr) {
                callback(image)
            }
        }
        else {
            callback(nil)
        }
    }
}
/// MARK: - ////////////////////////////////////////

extension UIImage {
    
    /**
    Creates a circular image with the passed parameters.
    
    :param: diameter  The diameter
    :param: color     The color
    :param: isFill    The is fill
    :param: lineWidth The line width
    
    :returns: the circular image.
    */
    class func circularImage(#diameter: CGFloat, color: UIColor?, isFill: Bool, var lineWidth: CGFloat = 0) -> UIImage {
        if isFill {
            lineWidth = 0
        }
        
        let size = CGSize(width: diameter, height: diameter)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        let path = UIBezierPath(ovalInRect: CGRect(origin: CGPoint.zeroPoint,
            size: size).rectByInsetting(dx: lineWidth / 2, dy: lineWidth / 2))
        path.lineWidth = lineWidth
        
        if isFill {
            color?.setFill()
            path.fill()
        } else {
            color?.setStroke()
            path.stroke()
        }
        
        CGContextRestoreGState(context)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
}

/**
 * Shake effect support on a view
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
extension UIView {
    
    /**
     Shake the view as rejection action.
     */
    func shake() {
        shake(5)
    }
    
    /**
     Shake the view
     
     :param: shakes The number of shakes.
     */
    private func shake(shakes: Int) {
        if shakes == 0 {
            self.transform = CGAffineTransformIdentity
            return
        }
        
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            self.transform = CGAffineTransformMakeTranslation(shakes % 2 == 0 ? 5 : -5, 0)
            }) { (_) -> Void in
                self.shake(shakes - 1)
        }
    }
}

class Photo {
    
    var imageURL: NSURL?
    // Cached squared leader's image or nil if there is no images or the image if note yet requested
    private var image: UIImage?
    
    /// Flag that if true if image was already requested from the server
    private var imageWasRequested: Bool = false
    
    // Callback with image if have imageURL and it can provide real image
    func getSquareImage(callback: (UIImage?)->()) {
        // If image was requested, then return it
        if imageWasRequested {
            callback(image)
        }
        else {
            // Request image from the server
            imageWasRequested = true
            if let url = imageURL {
                UIImage.loadFromURLAsync(url, callback: {
                    (possibleImage: UIImage?)->() in
                    if let image = possibleImage {
                        self.image = image.square(image.size.width) // cache
                    }
                    callback(self.image)
                })
            }
        }
    }
}

// dodo
extension UIView {
    
    func addWithConstraints(view: UIVIew) {
        let containerView = self
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: view.frame.origin.y))
        containerView.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: -1 * (containerView.bounds.height - view.frame.origin.y - view.frame.height)))
        containerView.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: view.frame.origin.x))
        containerView.addConstraint(NSLayoutConstraint(item: view,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1.0,
            constant: -1 * (containerView.bounds.width - view.frame.origin.x - view.frame.width)))

    }
}

/**
Update UI when text is changed

:param: textField the textField
:param: range     the range to replace the string
:param: string    the string to replace in the range

:returns: true
*/
func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
    replacementString string: String) -> Bool {
        var text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        text = text.lowercaseString
        updateSearchResultsWithText(text)
        return true
}

// tags: digits, numeric, customfield

/**
 Type only digits
 
 - parameter textField: the textField
 - parameter range:     the range
 - parameter string:    the string
 
 - returns: false
 */
func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
    replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let components = newString.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let decimalString = components.joinWithSeparator("")
        textField.text = decimalString
        return false
}

func updateSearchResultsWithText(string: String) {
    // dodo
}


/// TOOLBARS under the keyboard

// Prepare toolbar
let toolbar = UIToolbar()
toolbar.sizeToFit()
let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButton:")
toolbar.items = [space, doneButton]

// Add done button toolbar above keyboard
subjectTextField.inputAccessoryView = toolbar
messageTextView.inputAccessoryView = toolbar


/**
Represents a helper extension for the UIView class.

@author dodo

@version 1.0
*/
extension UIView {
    
    /**
    Finds the first responder
    
    :returns: the first responder, or nil if nothing found.
    */
    private func findFirstResponder() -> UIView? {
        if isFirstResponder() { return self }
        else {
            for view in subviews as! [UIView] {
                if let responder = view.findFirstResponder() {
                    return responder
                }
            }
            return nil
        }
    }
    
    /**
    Add auto layout subview.
    
    :param: subview the subview
    */
    func addAutoLayoutSubview(subview: UIView) {
        subview.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(subview)
    }
    
    /**
    Add leading constraint to parent.
    
    :param: view the child view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addParentLeadingConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add trailing constraint to parent.
    
    :param: view the child view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addParentTrailingConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add top constraint to parent.
    
    :param: view the child view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addParentTopConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add bottom constraint to parent.
    
    :param: view the child view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addParentBottomConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add center X constraint to parent.
    
    :param: view the child view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addParentCenterXConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add Center Y constraint to parent.
    
    :param: view the child view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addParentCenterYConstraint(view: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add height constraint.
    
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addHeightConstraint(value: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add width constraint.
    
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addWidthConstraint(value: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Pin the view to parent horizontally.
    
    :param: view the child view.
    :param: leadingValue the constant value to add to leading.
    :param: trailingValue the constant value to add to trailing.
    :returns: the created constraints.
    */
    func pinParentHorizontal(view: UIView, leadingValue: CGFloat = 0, trailingValue: CGFloat = 0) -> [NSLayoutConstraint]{
        var array: [NSLayoutConstraint] = []
        array.append(addParentLeadingConstraint(view, value: leadingValue))
        array.append(addParentTrailingConstraint(view, value: trailingValue))
        return array
    }
    
    /**
    Pin the view to parent vertically.
    
    :param: view the child view.
    :param: topValue the constant value to add to leading.
    :param: bottomValue the constant value to add to trailing.
    :returns: the created constraints.
    */
    func pinParentVertical(view: UIView, topValue: CGFloat = 0, bottomValue: CGFloat = 0) -> [NSLayoutConstraint]{
        var array: [NSLayoutConstraint] = []
        array.append(addParentTopConstraint(view, value: topValue))
        array.append(addParentBottomConstraint(view, value: bottomValue))
        return array
    }
    
    /**
    Pin the view to parent.
    
    :param: view the child view.
    :param: leadingValue the constant value to add to leading.
    :param: trailingValue the constant value to add to trailing.
    :param: topValue the constant value to add to leading.
    :param: bottomValue the constant value to add to trailing.
    :returns: the created constraints.
    */
    func pinParentAllDirections(view: UIView, leadingValue: CGFloat = 0, trailingValue: CGFloat = 0,
        topValue: CGFloat = 0, bottomValue: CGFloat = 0) -> [NSLayoutConstraint]{
            var array: [NSLayoutConstraint] = []
            array += pinParentHorizontal(view, leadingValue: leadingValue, trailingValue: trailingValue)
            array += pinParentVertical(view, topValue: topValue, bottomValue: bottomValue)
            return array
    }
    
    /**
    Center in container.
    
    :param: view the child view.
    :param: centerX the constant value to add to center x.
    :param: centerY the constant value to add to center y.
    :returns: the created constraints.
    */
    func addParentCenter(view: UIView, centerX: CGFloat = 0, centerY: CGFloat = 0) -> [NSLayoutConstraint]{
        var array: [NSLayoutConstraint] = []
        array.append(addParentCenterXConstraint(view, value: centerX))
        array.append(addParentCenterYConstraint(view, value: centerY))
        return array
    }
    
    
    /**
    Add right constraint to sibling.
    
    :param: left the left view.
    :param: right the right view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addSiblingHorizontalContiguous(#left: UIView, right: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: right,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: left,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add vertical spacing constraint to sibling.
    
    :param: top the top view.
    :param: bottom the bottom view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addSiblingVerticalContiguous(#top: UIView, bottom: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: bottom,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: top,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add equal width constraint to sibling.
    
    :param: view1 the first view.
    :param: view2 the second view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addEqualWidthConstraint(#view1: UIView, view2: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view1,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view2,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add equal height constraint to sibling.
    
    :param: view1 the first view.
    :param: view2 the second view.
    :param: value the constant value to add.
    :returns: the created constraint.
    */
    func addEqualHeightConstraint(#view1: UIView, view2: UIView, value: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view1,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view2,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: value)
        addConstraint(constraint)
        return constraint
    }
    
    /**
    Add equal size constraint to sibling.
    
    :param: view1 the first view.
    :param: view2 the second view.
    :param: widht the constant value to add to the width.
    :param: height the constant value to add to the height.
    :returns: the created constraints.
    */
    func addEqualSizeConstraints(#view1: UIView, view2: UIView, width: CGFloat = 0, height: CGFloat = 0) -> [NSLayoutConstraint] {
        var array: [NSLayoutConstraint] = []
        array.append(addEqualHeightConstraint(view1: view1, view2: view2, value: height))
        array.append(addEqualWidthConstraint(view1: view1, view2: view2, value: width))
        return array
    }
    
    /**
    Add size constraint.
    
    :param: widht the constant value to add to the width.
    :param: height the constant value to add to the height.
    :returns: the created constraints.
    */
    func addSizeConstraint(#width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
        var array: [NSLayoutConstraint] = []
        array.append(addWidthConstraint(width))
        array.append(addHeightConstraint(height))
        return array
    }
}

/**
* Shortcut methods for UIView
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIView {
    
    /**
    Make round corners for the view
    
    - parameter radius: the radius of the corners
    */
    func roundCorners(radius: CGFloat = 4) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    /**
    Make the view round
    */
    func makeRound() {
        self.layoutIfNeeded()
        self.roundCorners(self.bounds.height / 2)
    }
    
    /**
     Add shadow to the view
     
     - parameter size: the size of the shadow
     */
    func addShadow(size: CGFloat = 1, shift: CGFloat? = 0.5, opacity: Float = 0.1) {
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, shift ?? size)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = size
    }
}

/**
 * Helpful extentions for UITextField
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UITextField {
    
    /**
    Placeholder text as the main text
    
    - parameter aDecoder: decoder
    
    - returns: the instance
    */
    public override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        super.awakeAfterUsingCoder(aDecoder)
        setPlaceholderColor(self.textColor!)
        return self
    }
    
    /**
    Set placeholder text color
    
    - parameter color: the color
    */
    func setPlaceholderColor(color: UIColor) {
        self.setValue(color, forKeyPath: "_placeholderLabel.textColor")
    }
}

// dodo
extension UIViewController {
    
    // dodo
    func wrapInNavigationController() -> UINavigationController {
        let navigation = UINavigationController(rootViewController: self)
        navigation.navigationBar.translucent = false
        return navigation
    }
}

/**
* Helpful class to set preferred status bar
*
* @author TCASSEMBLER
* @version 1.0
*/
class NavigationController: UINavigationController {
    
    /**
    Set dark status bar
    
    - returns: .Default
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
}
 /////////////////////////////////////////// Fonts


// the main font prefix
public let FONT_PREFIX = "SourceSansPro"

/**
 * Common fonts used in the app
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
public struct Fonts {
    
    static var Regular = "\(FONT_PREFIX)-Regular"
    static var Bold = "\(FONT_PREFIX)-Bold"
    static var Thin = "\(FONT_PREFIX)-ExtraLight"
    static var ThinItalic = "\(FONT_PREFIX)-ExtraLightIt"
    static var Light = "\(FONT_PREFIX)-Light"
    static var Semibold = "\(FONT_PREFIX)-Semibold"
    static var Italic = "\(FONT_PREFIX)-It"
}

/**
* Applies default family fonts for UILabels from IB.
*
* @author TCASSEMBLER
* @version 1.0
*/
extension UILabel {
    
    /**
    Applies default family fonts
    */
    public override func awakeFromNib() {
        super.awakeFromNib()
        applyDefaultFontFamily()
    }
    
    /**
    Applies default family fonts
    
    - parameter aDecoder: the decoder
    
    - returns: UILabel instance
    */
    public override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        self.applyDefaultFontFamily()
        return self
    }
    
    /**
    Applies default family fonts
    */
    func applyDefaultFontFamily() {
        if font.fontName.contains("Thin", caseSensitive: false) {
            if font.fontName.contains("Italic", caseSensitive: false) {
                self.font = UIFont(name: Fonts.ThinItalic, size: self.font.pointSize)
            }
            else {
                self.font = UIFont(name: Fonts.Thin, size: self.font.pointSize)
            }
        }
        else if font.fontName.contains("Light", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Light, size: self.font.pointSize)
        }
        else if font.fontName.contains("Semibold", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Semibold, size: self.font.pointSize)
        }
        else if font.fontName.contains("Bold", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Bold, size: self.font.pointSize)
        }
        else if font.fontName.contains("Italic", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Italic, size: self.font.pointSize)
        }
        else if font.fontName.contains("Regular", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Regular, size: self.font.pointSize)
        }
    }
}

/**
* Helpful layout methods
*
* @author TCASSEMBLER
* @version 1.0
*/
extension UIView {
    
    /**
    Flip constraints for this view from left to right and visa versa
    */
    func flipConstraints() {
        var newConstraints = [NSLayoutConstraint]()
        for c in constraints {
            let first = flipHorizontallyLayoutAttribute(c.firstAttribute, constant: c.constant)
            let second = flipHorizontallyLayoutAttribute(c.secondAttribute, constant: c.constant)
            let newConstraint = NSLayoutConstraint(item: c.firstItem,
                attribute: first.0,
                relatedBy: c.relation,
                toItem: c.secondItem,
                attribute: second.0,
                multiplier: c.multiplier, constant: first.1)
            newConstraints.append(newConstraint)
        }
        self.removeConstraints(self.constraints)
        self.addConstraints(newConstraints)
    }
    
    /**
    Get flipped constraint.
    
    - parameter attr:     the attribute
    - parameter constant: the constant used for the constraint
    
    - returns: horizontally flipped constraint
    */
    func flipHorizontallyLayoutAttribute(attr: NSLayoutAttribute, constant: CGFloat) -> (NSLayoutAttribute, CGFloat) {
        if attr == NSLayoutAttribute.Leading {
            return (NSLayoutAttribute.Trailing, -constant)
        }
        else if attr == NSLayoutAttribute.Trailing {
            return (NSLayoutAttribute.Leading, -constant)
        }
        return (attr, constant)
    }
}
  ///\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ Fonts


/**
* Class for a general loading view (for api calls).
*
* - author: TCASSEMBLER
* - version: 1.0
*/
class LoadingView: UIView {
    
    /// loading indicator
    var activityIndicator: UIActivityIndicatorView!
    
    /// flag: true - the view is terminated, false - else
    var terminated = false
    
    /// flag: true - the view is shown, false - else
    var didShow = false
    
    /// the reference to the parent view
    var parentView: UIView?
    
    /**
    Initializer
    
    - parameter parentView: the parent view
    - parameter dimming:    true - need to add semitransparent overlay, false - just loading indicator
    */
    init(parentView: UIView?, dimming: Bool = true) {
        super.init(frame: parentView?.bounds ?? UIScreen.mainScreen().bounds)
        
        self.parentView = parentView
        
        setupUI(dimming)
    }
    
    /**
    Required initializer
    */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
    Adds loading indicator and changes colors
    
    - parameter dimming: true - need to add semitransparent overlay, false - just loading indicator
    */
    private func setupUI(dimming: Bool) {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.center
        self.addSubview(activityIndicator)
        
        if dimming {
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        }
        else {
            activityIndicator.activityIndicatorViewStyle = .Gray
            self.backgroundColor = UIColor.clearColor()
        }
        self.alpha = 0.0
    }
    
    /**
    Removes the view from the screen
    */
    func terminate() {
        terminated = true
        if !didShow { return }
        UIView.animateWithDuration(0.25, animations: { _ in
            self.alpha = 0.0
            }, completion: { success in
                self.activityIndicator.stopAnimating()
                self.removeFromSuperview()
        })
    }
    
    /**
     Show the view
     
     - returns: self
     */
    func show() -> LoadingView {
        didShow = true
        if !terminated {
            if let view = parentView {
                view.addSubview(self)
                return self
            }
            UIApplication.sharedApplication().delegate!.window!?.addSubview(self)
        }
        return self
    }
    
    /**
    Change alpha after the view is shown
    */
    override func didMoveToSuperview() {
        activityIndicator.startAnimating()
        UIView.animateWithDuration(0.25) {
            self.alpha = 0.75
        }
    }
}

// WITH label
/**
* Class for a general loading view (for api calls).
*
* @author Alexander Volkov
* @version 1.0
*/
class LoadingView: UIView {
    
    var activityIndicator: UIActivityIndicatorView!
    var titleLabel: UILabel!
    
    /*
    not yet implemented, but may want a message to appear on the loading screen
    that is specific to the data being loaded.
    */
    var message:String?
    var terminated = false
    var didShow = false
    var parentView:UIView?
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    init(message:String,parentView:UIView?) {
        super.init(frame: UIScreen.mainScreen().bounds)
        
        self.message = message
        self.parentView = parentView
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.center
        self.addSubview(activityIndicator)
        
        let size = CGSizeMake(100, 30)
        let point = CGPointMake((self.bounds.width - size.width)/2, self.bounds.height/2 + 15)
        titleLabel = UILabel(frame: CGRect(origin: point, size: size))
        titleLabel.text = message ?? ""
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.whiteColor()
        self.addSubview(titleLabel)
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        self.alpha = 0.0
    }
    
    func terminate() {
        terminated = true
        if !didShow { return }
        UIView.animateWithDuration(0.25, animations: { _ in
            self.alpha = 0.0
            }, completion: { success in
                self.activityIndicator.stopAnimating()
                self.removeFromSuperview()
        })
    }
    
    func showWithDelay() {
        delay(0.25) {
            self.didShow = true
            if !self.terminated {
                if let view = self.parentView {
                    view.addSubview(self)
                    return
                }
                UIApplication.sharedApplication().delegate!.window!?.addSubview(self)
            }
        }
    }
    
    func show() {
        didShow = true
        if !terminated {
            if let view = parentView {
                view.addSubview(self)
                return
            }
            UIApplication.sharedApplication().delegate!.window!?.addSubview(self)
        }
    }
    
    override func didMoveToSuperview() {
        activityIndicator.startAnimating()
        UIView.animateWithDuration(0.25) {
            self.alpha = 0.75
        }
    }
}


/**
 * Extension to display alerts
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UIViewController {
    
    /**
     Displays alert with specified title & message
     
     - parameter title:      the title
     - parameter message:    the message
     - parameter completion: the completion callback
     */
    func showAlert(title: String, _ message: String, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default,
            handler: { (_) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
                dispatch_async(dispatch_get_main_queue()) {
                    completion?()
                }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     Create general failure callback that show alert with error message over the current view controller
     
     - parameter loadingView: the loading view parameter
     
     - returns: FailureCallback instance
     */
    func createGeneralFailureCallback(loadingView: LoadingView? = nil) -> FailureCallback {
        return { (errorMessage) -> () in
            self.showAlert(NSLocalizedString("Error", comment: "Error"), errorMessage)
            loadingView?.terminate()
        }
    }
}

/**
* Extends UIView with shortcut methods
*
* @author TCASSEMBLER
* @version 1.0
*/
extension UITextField {
    
    /**
     Get float value from the field
     
     - returns: the float value
     */
    func getFloat() -> Float? {
        // dodo check - may be we neeed nsformatter with US locale
        return Float((self.text?.trim() ?? "").replace(",", withString: ""))
    }
}

/**
 * Text field with border
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class TextField: UITextField {
    
    /**
     Designated initializer
     
     - parameter frame: frame
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    /**
     Required initializer
     
     - parameter aDecoder: decoder
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    /**
     Setups view
     */
    func setupView() {
        self.layer.borderColor = ABColor.blackColor().CGColor
        self.layer.borderWidth = 1.0
    }
    
    /**
     text rect
     */
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        let originalRect: CGRect = super.editingRectForBounds(bounds)
        return CGRectMake(originalRect.origin.x + 10.0, originalRect.origin.y, originalRect.size.width - 20.0, originalRect.size.height)
    }
    
    /**
     editing rect
     */
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        let originalRect: CGRect = super.editingRectForBounds(bounds)
        return CGRectMake(originalRect.origin.x + 10.0, originalRect.origin.y, originalRect.size.width - 20.0, originalRect.size.height)
    }
    
}

/**
 * button with border
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable
class BorderButton: UIButton {
    
    /**
     Designated initializer
     
     - parameter frame: frame
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    /**
     Required initializer
     
     - parameter aDecoder: decoder
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    /**
     Setups view
     */
    func setupView() {
        self.adjustsImageWhenDisabled = false
        self.titleLabel?.textAlignment = .Center
        self.setNeedsLayout()
    }
    
    /**
     draw rect
     */
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let color: UIColor = ((self.highlighted || self.selected) ? self.titleColorForState(.Highlighted)
            : ( enabled ? self.titleColorForState(.Normal) : self.titleColorForState(.Disabled) ))
            ?? UIColor.blackColor()
        color.setStroke()
        let ctx = UIGraphicsGetCurrentContext()
        let stroke: CGRect = CGRectMake(0.0, 0.0, rect.size.width, rect.size.height)
        CGContextStrokeRect(ctx, stroke)
        
        // dodo
//        let context = UIGraphicsGetCurrentContext()!
//        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
//        CGContextAddPath(context, path.CGPath)
//        CGContextSetStrokeColorWithColor(context, color.CGColor)
//        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
    }
    
    /// content inset
    override var contentEdgeInsets: UIEdgeInsets {
        get {
            if (self.imageForState(.Normal) != nil) {
                return UIEdgeInsetsMake(10.0, 29.0, 10.0, 29.0)
            }
            else {
                return UIEdgeInsetsMake(10.0, 24.0, 10.0, 24.0)
            }
        }
        set {
        }
    }
    
    /**
     title rect
     */
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        if (self.imageForState(.Normal) != nil) {
            return CGRectMake(24.0, 10.0, contentRect.size.width - 16.0, contentRect.size.height)
        }
        else {
            return CGRectMake(24.0, 10.0, contentRect.size.width, contentRect.size.height)
        }
    }
    
    /**
     image rect
     */
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        if (self.imageForState(.Normal) != nil) {
            return CGRectMake(contentRect.size.width - contentRect.size.height + 34.0, 10.0, contentRect.size.height, contentRect.size.height)
        }
        else {
            return CGRectZero
        }
    }
    
    /// highlighted
    override var highlighted: Bool {
        didSet {
            self.backgroundColor = self.titleColorForState(highlighted ? .Normal : .Highlighted)
            self.setNeedsDisplay()
        }
    }
    
    /// selected
    override var selected: Bool {
        didSet {
            self.backgroundColor = self.titleColorForState(selected ? .Normal : .Highlighted)
            self.setNeedsDisplay()
        }
    }
    
    /// enalbed
    public override var enabled: Bool {
        didSet {
            self.backgroundColor = self.titleColorForState(enabled ? .Highlighted : .Selected)
            self.setNeedsDisplay()
        }
    }
}

extension NumericTextField {
    
    /**
     Allow to input numbers only
     
     - parameter textField: the textField
     - parameter range:     the range to update
     - parameter string:    the string to substitute in the range
     
     - returns: false
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            let newString = ((textField.text ?? "") as NSString).stringByReplacingCharactersInRange(range,
                withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(
                NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            textField.text = components.joinWithSeparator("")
            return false
    }
}

/**
 * Extends UIImageView with a shortcut method.
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UIImageView {
    
    /**
     Expand/collapse arrow animation
     
     - parameter expand: true - need to expand, false - need to collapse
     */
    func expandArrow(expand: Bool, changeTintColor: Bool) {
        let arrowAngle: CGFloat = expand ? 0 : CGFloat(M_PI)
        let tintColor = expand ? UIColor.blue() : UIColor.whiteColor()
        
        // Animate arrow rotation
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
            options: .CurveEaseOut,
            animations: { () -> Void in
                self.transform = CGAffineTransformMakeRotation(arrowAngle)
                self.superview?.layoutIfNeeded()
                if changeTintColor {
                    self.tintColor = tintColor
                }
            }, completion: nil)
    }
}

func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row + 1 == menuItems.count && !isLoading {
        loadNextMenuItems()
    }
}

/**
 * A view with lines (underline, etc).
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
@IBDesignable public class LinesView: UIView {
    
    /// the color of the lines
    @IBInspectable public var lineColor: UIColor = UIColor(red: 225/255, green: 230/255, blue: 233/255, alpha: 1)
    
    /// the width of the line
    @IBInspectable public var lineWidth: CGFloat = 0.5
    
    /// flags: true - will show corresponding line, false - else
    @IBInspectable public var bottomLine: Bool = true
    @IBInspectable public var rightLine: Bool = false
    
    /**
     Draw extra underline
     
     - parameter rect: the rect to draw in
     */
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        lineColor.set()
        let yShift = (self.bounds.height - lineWidth)
        
        let currentContext = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(currentContext, lineWidth)
        
        if bottomLine {
            CGContextMoveToPoint(currentContext, 0, yShift)
            CGContextAddLineToPoint(currentContext, self.bounds.width, yShift)
            CGContextStrokePath(currentContext)
        }
        if rightLine {
            CGContextMoveToPoint(currentContext, self.bounds.width - lineWidth, 0)
            CGContextAddLineToPoint(currentContext, self.bounds.width - lineWidth, yShift)
            CGContextStrokePath(currentContext)
        }
    }
}
