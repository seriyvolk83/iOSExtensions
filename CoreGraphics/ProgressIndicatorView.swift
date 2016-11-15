//
//  ProgressIndicatorView.swift
//  dodo
//
//  Created by TCCODER on 12.11.15.
//  Copyright © 2015 seriyvolk83dodo. All rights reserved.
//

import UIKit

/// option: true - will hide "0/0 Loads" text when there is no data, false - will show it
let OPTION_HIDE_LOADS_LABEL_WHEN_RESET = false

/**
* Process indicator
*
* @author TCCODER
* @version 1.0
*/
@IBDesignable
public class ProgressIndicatorView: UIView {
    
    // the cut off sector at the bottom
    let cutoff: CGFloat = 82/360
    
    /// the position parameters for horizontal line
    let lineMargins: CGSize = CGSize(width: 27.5, height: 8) // horizontal margins value and shift from vertical center
    
    /// the width of the line
    @IBInspectable var lineWidth: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// the line color
    @IBInspectable var lineColor: UIColor = UIColor.redColor() {
        didSet {
            self.setNeedsLayout()
        }
    }

    /// the percent of the circle to draw
    @IBInspectable public var percentValue: Float {
        get {
            return percent
        }
        set {
            if percent > 1 {
                percent = 1
            }
            setNeedsLayout()
        }
    }
    
    /// effective percent value
    var percent: Float = 0.6
    
    // the percent font size
    public var percentFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 53)!
    
    // the load values font size
    public var loadValuesFont: UIFont = UIFont(name: "HelveticaNeue", size: 14)!
    
    /// the number of loaded trucks
    var loadedValue: Int = 12
    
    //// Added layers and subviews
    /// the total number of quota trucks
    var totalLoadsValue: Int = 60
    /// the circle layer
    public var circleLayer: CAShapeLayer!
    /// background ring layer
    var backgroundRingLayer: CAShapeLayer!
    /// the large percent label
    var percentLabel: UILabel!
    /// the "%" sign
    var percentSuffixLabel: UILabel!
    /// the constraint used to layout different percent values horizontally
    var horizontalPercentConstraint: NSLayoutConstraint!
    /// the loaded value label
    var loadedValueLabel: UILabel!
    /// the label for total number and "Loads" suffix
    var totalLoadsLabel: UILabel!
    /// horizontal line
    var lineView: UIView!
    /// complete icon
    var completeIcon: UIImageView!
    
    /**
    Create layers and add to layer
    */
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutRing()
        layoutPercentLabel()
        layoutLoadValuesLabels()
        layoutLine()
        layoutCompleteIcon()
    }
    
    /**
    Layout the percentage ring
    */
    func layoutRing() {
        if circleLayer == nil {
            circleLayer = CAShapeLayer()
            layer.addSublayer(circleLayer)
            let rect = CGRectInset(bounds, lineWidth/2, lineWidth/2)
            let path = UIBezierPath(ovalInRect: rect)
            circleLayer.path = path.CGPath
            circleLayer.fillColor = nil
            circleLayer.lineWidth = lineWidth
            circleLayer.lineCap = kCALineCapRound
            circleLayer.anchorPoint = CGPointMake(0.5, 0.5)
            circleLayer.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(M_PI * 1/2), 0, 0, 1)
            circleLayer.strokeStart = cutoff / 2
            circleLayer.strokeEnd = strokeEndFromPercent(percent)
        }
        circleLayer.frame = layer.bounds
        circleLayer.strokeColor = lineColor.CGColor
        
        // Background ring
        if backgroundRingLayer == nil {
            backgroundRingLayer = CAShapeLayer()
            layer.addSublayer(backgroundRingLayer)
            let rect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)
            let path = UIBezierPath(ovalInRect: rect)
            backgroundRingLayer.path = path.CGPath
            backgroundRingLayer.fillColor = nil
            backgroundRingLayer.lineWidth = lineWidth
            backgroundRingLayer.lineCap = kCALineCapRound
            backgroundRingLayer.anchorPoint = CGPointMake(0.5, 0.5)
            backgroundRingLayer.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(M_PI * 1/2), 0, 0, 1)
            backgroundRingLayer.strokeColor = UIColor(white: 1, alpha: 0.2).CGColor
            backgroundRingLayer.strokeStart = cutoff / 2
            backgroundRingLayer.strokeEnd = strokeEndFromPercent(1)
            
        }
        backgroundRingLayer.frame = layer.bounds
    }
    
    /**
    Calculate stroke end value for given percent
    
    - parameter percent: the percent
    
    - returns: the corrsponding stroke end value
    */
    public func strokeEndFromPercent(percent: Float) -> CGFloat {
        return (1 - cutoff) * CGFloat(percent) + cutoff / 2
    }
    
    /**
    Layout the percent label, e.g. "60%"
    */
    func layoutPercentLabel() {
        /*
        The coefficients are calculated from design. They help to keep adaptivity of the view.
        */
        var k1: CGFloat = 25 / 53 // desired label shift is 29 for font size 53
        if percent == 0 {
            k1 /= 2
        }
        let k2: CGFloat = 263 / 366 // desired height of the label is 263 for 366 view height
        let frame = CGRectMake(0, 0, self.bounds.width / 2 + k1 * percentFont.pointSize, k2 * self.bounds.height)
        let horizontalConstraintValue = k1 * percentFont.pointSize
        if percentLabel == nil {
            percentLabel = UILabel(frame: frame)
            percentLabel.textAlignment = .Right
            percentLabel.textColor = lineColor
            percentLabel.font = percentFont
            percentLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(percentLabel)
            self.horizontalPercentConstraint = NSLayoutConstraint(item: percentLabel,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1, constant: horizontalConstraintValue)
            self.addConstraint(self.horizontalPercentConstraint)
            self.addConstraint(NSLayoutConstraint(item: percentLabel,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: percentLabel,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.Height,
                multiplier: 1, constant: k2 * self.bounds.height))
            
            percentSuffixLabel = UILabel()
            percentSuffixLabel.text = "%"
            percentSuffixLabel.textColor = lineColor
            percentSuffixLabel.font = UIFont(name: loadValuesFont.fontName, size: 25.5)
            percentSuffixLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(percentSuffixLabel)
            self.addConstraint(NSLayoutConstraint(item: percentSuffixLabel,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: percentLabel,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1, constant: 7.5))
            self.addConstraint(NSLayoutConstraint(item: percentSuffixLabel,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: percentLabel,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: percentSuffixLabel,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: percentLabel,
                attribute: NSLayoutAttribute.Height,
                multiplier: 84/100, constant: 0))
        }
        else {
            horizontalPercentConstraint.constant = horizontalConstraintValue
        }
        updatePercent(percent)
        percentLabel.frame = frame
    }
    
    /**
    Layout load values, e.g. "12/60 Loads"
    */
    func layoutLoadValuesLabels() {
        /*
        The coefficients are calculated from design. They help to keep adaptivity of the view.
        */
        let k1: CGFloat = 23 / 14 // desired label shift is 44 for font size 14
        let k2: CGFloat = 260 / 366 // desired height of the label is 258 for 366 view height
        let height = k2 * self.bounds.height
        let frame = CGRectMake(self.bounds.width / 2 - k1 * loadValuesFont.pointSize,
            self.bounds.height - height, self.bounds.width / 2, height)
        let frameLoadedValue = CGRectMake(0, frame.origin.y, frame.origin.x, frame.height)
        if totalLoadsLabel == nil {
            totalLoadsLabel = UILabel(frame: frame)
            
            totalLoadsLabel.textAlignment = .Left
            totalLoadsLabel.textColor = UIColor.whiteColor()
            totalLoadsLabel.font = loadValuesFont
            totalLoadsLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(totalLoadsLabel)
            self.addConstraint(NSLayoutConstraint(item: totalLoadsLabel,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1, constant: -k1 * loadValuesFont.pointSize))
            self.addConstraint(NSLayoutConstraint(item: totalLoadsLabel,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1, constant: self.bounds.height - height))
            self.addConstraint(NSLayoutConstraint(item: totalLoadsLabel,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.Height,
                multiplier: 1, constant: height))
            
            loadedValueLabel = UILabel()
            loadedValueLabel.text = "%"
            loadedValueLabel.textColor = lineColor
            loadedValueLabel.textAlignment = .Right
            loadedValueLabel.font = loadValuesFont
            loadedValueLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(loadedValueLabel)
            self.addConstraint(NSLayoutConstraint(item: loadedValueLabel,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: totalLoadsLabel,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: loadedValueLabel,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: totalLoadsLabel,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: loadedValueLabel,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: totalLoadsLabel,
                attribute: NSLayoutAttribute.Height,
                multiplier: 1, constant: 0))
        }
        updateLoadsValues(loadedValue, totalLoads: totalLoadsValue)
        totalLoadsLabel.frame = frame
        loadedValueLabel.frame = frameLoadedValue
    }
    
    /**
    Layout line
    */
    func layoutLine() {
        let frame = CGRectMake(lineMargins.width, self.bounds.height / 2 + lineMargins.height,
            self.bounds.width - lineMargins.width * 2, 0.5)
        if lineView == nil {
            lineView = UIView(frame: frame)
            lineView.backgroundColor = UIColor(white: 0.84, alpha: 1)
            self.addSubview(lineView)
        }
        lineView.frame = frame
    }
    
    /**
    Layout complete icon
    */
    func layoutCompleteIcon() {
        let iconHeight: CGFloat = 49
        let frame = CGRectMake(0, self.bounds.height - iconHeight, self.bounds.width, iconHeight)
        if completeIcon == nil {
            completeIcon = UIImageView(frame: frame)
            completeIcon.contentMode = .Center
            completeIcon.image = UIImage(named: "completeIcon")
            self.addSubview(completeIcon)
            completeIcon.hidden = true
        }
        completeIcon.frame = frame
    }
    
    /**
    Update percent label
    
    - parameter percent:  the percent value
    - parameter animated: the animation flag
    */
    public func updatePercent(percent: Float, animated: Bool = false) {
        self.percent = percent
        if animated {
            if let circleLayer = circleLayer {
                CATransaction.begin()
                CATransaction.setCompletionBlock({ () -> Void in
                    
                })
                circleLayer.removeAllAnimations()
                circleLayer.strokeEnd = strokeEndFromPercent(percent)
                CATransaction.commit()
            }
        }
        else {
            circleLayer?.strokeEnd = strokeEndFromPercent(percent)
        }
        percentLabel?.text = Int(percent * 100).description // sample value
        percentLabel?.setNeedsLayout()
        completeIcon?.hidden = percent < 1
        self.layoutIfNeeded()
    }
    
    /**
    Update load values
    
    - parameter currentValue: the current number of completed loads
    - parameter totalLoads:   the total number of loads
    */
    public func updateLoadsValues(currentValue: Int, totalLoads: Int) {
        self.loadedValue = currentValue
        self.totalLoadsValue = totalLoads
        loadedValueLabel?.text = "\(currentValue)"
        totalLoadsLabel?.text = "/\(totalLoads) " + (totalLoads == 1 ? "Load" : "Loads")
        
        let needToHide = OPTION_HIDE_LOADS_LABEL_WHEN_RESET
            && currentValue == 0 && totalLoads == 0
        loadedValueLabel?.hidden = needToHide
        totalLoadsLabel?.hidden = needToHide
        lineView?.hidden = needToHide
    }
    
    /**
    Facade method that sets load values and percent to zero
    */
    public func resetValuesToZero() {
        updatePercentAndLoadValues(0, totalLoads: 0)
    }
    
    /**
    Facade method that invokes updatePercentText and updateLoadsValues.
    
    - parameter value:      the current number of completed loads
    - parameter totalLoads: the total number of loads
    - parameter animated:   the animation flag
    */
    public func updatePercentAndLoadValues(value: Int, totalLoads: Int, animated: Bool = false) {
        updateLoadsValues(value, totalLoads: totalLoads)
        var percent: Float = 0
        if totalLoads > 0 {
            percent = min(Float(value) / Float(totalLoads), 1)
        }
        updatePercent(percent, animated: animated)
    }
}

