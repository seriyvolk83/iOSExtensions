//
//  NotificationsWidget.swift
//  dodo
//
//  Created by Alexander Volkov on 28.11.14.
//  Copyright (c) 2014 seriyvolk83dodo. All rights reserved.
//

import UIKit
import QuartzCore

// Shows red widget with number
@IBDesignable
public class NotificationsWidget: UIView {
    
    @IBInspectable var CORDER_RADIUS: CGFloat = 8
    
    @IBInspectable public var additionalWidth: CGFloat = 0
    
    // Change this number then notifications number is changed
    @IBInspectable public var number: Int = 5 {
        didSet {
            if number > 999 {
                additionalWidth = 12
            }
            else if number > 99 {
                additionalWidth = 6
            }
            else if number > 9 {
                additionalWidth = 2
            }
            else {
                additionalWidth = 0
            }
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var bgColor = UIColor.redColor()
    @IBInspectable var textColor = UIColor.whiteColor()
    
    
    let FONT = UIFontDescriptor(fontAttributes: [UIFontDescriptorTextStyleAttribute:"Regular", UIFontDescriptorFamilyAttribute:"Opensans"])
    
    var textField: UITextField?
    
    override public func drawRect(rect: CGRect) {

        let c = UIGraphicsGetCurrentContext()
        
        // DO not paint red background if number is zero
        if number > 0 {
            var borderBounds = getCircleBounds()
            
            CGContextSetFillColorWithColor(c , bgColor.CGColor)
            let path = CGPathCreateWithRoundedRect(borderBounds, CORDER_RADIUS, CORDER_RADIUS, nil)
            CGContextAddPath(c, path)
            CGContextFillPath(c)
        }
        
    }
    
    private func drawCircleInBounds(bounds: CGRect) {
        
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutNumber()
    }
    
    private func getCircleBounds() -> CGRect {
        return CGRect(x: bounds.width/2 - CORDER_RADIUS - additionalWidth/2, y: bounds.height/2 - CORDER_RADIUS, width: CORDER_RADIUS * 2 + additionalWidth, height: CORDER_RADIUS * 2)
    }
    
    private func layoutNumber() {
        var bounds = getCircleBounds()
        
        if textField == nil {
            textField = UITextField(frame: bounds)
            textField?.textAlignment = NSTextAlignment.Center
            textField?.textColor = textColor
            textField?.font = UIFont(descriptor: FONT, size: 12)
            textField?.enabled = false
            self.addSubview(textField!)
        }
        textField?.text = "\(number)"
        textField?.frame = bounds
        // DO not show number if the number is zero or less
        textField?.hidden = (number <= 0)
    }
    
    /**
     Create UIBarButtonItem with given icon and ABPPNotificationsWidget
     
     - parameter type:          the type of the widget
     - parameter iconName:      the icon name
     - parameter selector:      the selector
     - parameter initialNumber: the initial number
     
     - returns: UIBarButtonItem
     */
    class func getIconWithWidget(type: ABPPNavigationItemType, iconName: String, selector: Selector, initialNumber: Int) -> UIBarButtonItem {
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 44, 44))
        
        // Create widget for notifications number
        let widget = ABPPNotificationsWidget()
        widget.backgroundColor = UIColor.clearColor()
        
        // Calculate bounds
        let size = CGSize(width: 20, height: 20)
        widget.frame = CGRect(origin: CGPoint(
            x: customBarButtonView.bounds.width - size.width,
            y: 0),
                              size: size)
        
        notificationsWidgets[type] = widget
        widget.number = initialNumber
        
        let buttonClose = UIButton()
        buttonClose.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        buttonClose.frame = CGRectMake(0, 0, 44, 44)
        buttonClose.setImage(UIImage(named: iconName), forState: .Normal)
        
        customBarButtonView.addSubview(buttonClose)
        customBarButtonView.addSubview(widget)
        return UIBarButtonItem(customView: customBarButtonView)
    }
}
