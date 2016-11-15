//
//  CustomSegmentedControl.swift
//  dodo
//
//  Created by TCASSEMBLER on 13.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit

/**
 * Custom segmented control
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
public class CustomSegmentedControl: UISegmentedControl {
    
    /// the font
    public var font: UIFont = UIFont(name: "HelveticaNeue", size: 15.77)! {
        didSet {
            updateUI()
        }
    }
    
    /**
     Setup UI
     */
    override public func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    /**
     Update UI
     */
    func updateUI() {
        let attrDefault: [NSObject : AnyObject] = [NSFontAttributeName: font]
        let attrSelected: [NSObject : AnyObject] = [NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.setTitleTextAttributes(attrDefault, forState: .Normal)
        self.setTitleTextAttributes(attrSelected, forState: .Selected)
        
        let selectedImage = UIImage(named: "segmentedSelected")!.resizableImageWithCapInsets(
            UIEdgeInsetsMake(10, 10, 10, 10))
        let defaultImage = UIImage(named: "segmented")!.resizableImageWithCapInsets(UIEdgeInsetsMake(10, 10, 10, 10))
        self.setBackgroundImage(defaultImage, forState: .Normal, barMetrics: .Default)
        self.setBackgroundImage(selectedImage, forState: .Selected, barMetrics: .Default)
        self.setDividerImage(UIImage(named: "segmentControlSeparator"),
            forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    }
}
