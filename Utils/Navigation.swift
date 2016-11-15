// Partially copied from UIExtensions.swift

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
        navigationController!.navigationBar.tintColor = UIColor.blue()
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
        let fontSize: CGFloat = 18
        let titleAttribute = [NSForegroundColorAttributeName: UIColor(r: 69, g: 85, b: 96),
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
    
    - parameter title:    the button title
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
