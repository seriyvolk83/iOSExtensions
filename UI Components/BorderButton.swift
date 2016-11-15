//
//  BorderButton.swift
//  dodo
//
//  Created by Volkov Alexander on 28.10.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit

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
        self.titleLabel?.textAlignment = .center
        self.setNeedsLayout()
    }
    
    /**
     draw rect
     */
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let color = (self.isHighlighted || self.isSelected) ? self.titleColor(for: .highlighted) : self.titleColor(for: .normal)
        color?.setStroke()
        let ctx = UIGraphicsGetCurrentContext()!
        let stroke: CGRect = CGRect(x: 0.0, y: 0.0, width: rect.size.width, height: rect.size.height)
        ctx.stroke(stroke)
    }
    
    /// content inset
    override var contentEdgeInsets: UIEdgeInsets {
        get {
            if (self.image(for: .normal) != nil) {
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
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if (self.image(for: .normal) != nil) {
            return CGRect(x: 24.0, y: 10.0, width: contentRect.size.width - 16.0, height: contentRect.size.height)
        }
        else {
            return CGRect(x: 24.0, y: 10.0, width: contentRect.size.width, height: contentRect.size.height)
        }
    }
    
    /**
     image rect
     */
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        if (self.image(for: .normal) != nil) {
            return CGRect(x: contentRect.size.width - contentRect.size.height + 34.0, y: 10.0, width: contentRect.size.height, height: contentRect.size.height)
        }
        else {
            return CGRect.zero
        }
    }
    
    /// invert colors when highlighted
    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = self.titleColor(for: isHighlighted ? .normal : .highlighted)
            self.setNeedsDisplay()
        }
    }
    
    /// invert colors when selected
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = self.titleColor(for: isSelected ? .normal : .highlighted)
            self.setNeedsDisplay()
        }
    }
}
