//
//  CustomDropdownView.swift
//  dodo
//
//  Created by TCASSEMBLER on 13.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit

/**
 * CustomDropdownView delegate protocol
 *
 * - changes in 1.1:
 * - Fixed compile warnings.
 *
 * @author TCASSEMBLER
 * @version 1.1
 */
public protocol CustomDropdownDelegate {
    
    /**
     Notify that user tapped on the view
     
     - parameter dropdown: the dropdown view
     */
    func dropdownTapInside(dropdown: CustomDropdownView)
}

/**
 * Dropdown select
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
@IBDesignable public class CustomDropdownView: UIView {

    /// the width of the arrow area
    let ARROW_WIDTH: CGFloat = 45
    
    /// the title margings
    let TITLE_MARGIN_NO_ICON: CGFloat = 10
    let TITLE_MARGIN_HAS_ICON: CGFloat = 47.5
    
    /// the icon left margin
    let ICON_LEFT_MARGIN: CGFloat = 7
    
    /// the icon size
    let ICON_SIZE: CGFloat = 32
    
    /// the reference delegate
    public var delegate: CustomDropdownDelegate?
    
    /// the title
    @IBInspectable public var title: String = "Title" {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// the background color
    @IBInspectable public var bgColor: UIColor = UIColor(white: 1, alpha: 0.2) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// the border color
    @IBInspectable public var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// the arrow bg color
    @IBInspectable public var arrowBgColor: UIColor = UIColor(white: 0, alpha: 0.16) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// the icon before the title
    @IBInspectable public var iconImage: UIImage? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// added subviews
    var titleLabel: UILabel!
    var button: UIButton!
    var icon: UIImageView?
    var arrow: UIView!
    var arrowImageView: UIImageView!
    
    /**
     Layout subviews
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners()
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = 1
        self.backgroundColor = bgColor
        
        layoutTitle()
        layoutArrow()
        layoutIcon()
        layoutButton()
    }
    
    /**
     Layout title
     */
    func layoutTitle() {
        let frame = getTitleFrame()
        if titleLabel == nil {
            titleLabel = UILabel(frame: frame)
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.font = UIFont.lightOfSize(15)
            self.addSubview(titleLabel)
        }
        titleLabel.frame = frame
        titleLabel.text = title
    }
    
    /**
     Layout right arrow
     */
    func layoutArrow() {
        var frame = self.bounds
        frame.origin.x = self.bounds.width - ARROW_WIDTH
        frame.size.width = ARROW_WIDTH
        if arrow == nil {
            arrow = UIView(frame: frame)
            arrow.backgroundColor = arrowBgColor
            arrowImageView = UIImageView(image: UIImage(named: "dropDownArrow"))
            arrowImageView.frame = arrow.bounds
            arrowImageView.contentMode = .Center
            arrow.addSubview(arrowImageView)
            self.addSubview(arrow)
        }
        arrow.frame = frame
        arrowImageView.frame = arrow.bounds
    }
    
    /**
     Layout icon margin
     */
    func layoutIcon() {
        var frame = CGRect(x: ICON_LEFT_MARGIN, y: (self.bounds.height - ICON_SIZE) / 2,
            width: ICON_SIZE, height: ICON_SIZE)
        frame.origin.y -= 0.5 // change required to match the design
        if let iconImage = iconImage {
            if icon == nil {
                icon = UIImageView(frame: frame)
                icon?.makeRound()
                icon?.addBorder(UIColor.whiteColor(), borderWidth: 1)
                self.addSubview(icon!)
            }
            icon?.image = iconImage
            icon?.frame = frame
        }
        else {
            icon?.removeFromSuperview()
            icon = nil
        }
    }
    
    /**
     Layout button
     */
    func layoutButton() {
        if button == nil {
            button = UIButton(frame: self.bounds)
            self.addSubview(button)
            button.addTarget(self, action: #selector(CustomDropdownView.buttonAction(_:)), forControlEvents: .TouchUpInside)
        }
        button.frame = self.bounds
        self.bringSubviewToFront(button)
    }
    
    /**
     Button action handler
     
     - parameter sender: the button
     */
    func buttonAction(sender: AnyObject) {
        delegate?.dropdownTapInside(self)
    }
    
    /**
     Get frame for the title label
     
     - returns: the frame
     */
    func getTitleFrame() -> CGRect {
        var frame = self.bounds
        frame.origin.x = iconImage != nil ? TITLE_MARGIN_HAS_ICON : TITLE_MARGIN_NO_ICON
        frame.size.width = self.bounds.width - frame.origin.x - ARROW_WIDTH - 5
        frame.size.height -= 3 // change required to match the design
        return frame
    }

}
