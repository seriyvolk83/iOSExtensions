//
//  CirleDiagram.swift
//  dodo
//
//  Created by Volkov Alexander on 30.03.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import QuartzCore
import UIKit

/**
 * Circle diagram with color sectors
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
@IBDesignable
public class CirleDiagram: UIView {
    
    // colors for different sectors
    public let COLORS = [
        UIColor(red: 1, green: 80/255, blue: 80/255, alpha: 1),
        UIColor(red: 140/255, green: 210/255, blue: 17/255, alpha: 1),
        UIColor(red: 1, green: 120/255, blue: 50/255, alpha: 1),
        UIColor(red: 253/255, green: 214/255, blue: 0, alpha: 1),
        UIColor(red: 11/255, green: 162/255, blue: 195/255, alpha: 1)
    ]
    
    @IBInspectable public var INNER_CICLE_SIZE: CGFloat = 50
    
    @IBInspectable public var enableCenterShadow: Bool = true
    
    /// flag: true - will show percents, false - will show custom labels
    @IBInspectable public var showPercents: Bool = true
    
    /// values to be shown as sectors
    public var values: [Float] = [16,20,25,14, 25] {
        didSet {
            clearSectors()
            if showPercents {
                var newLabels = [String]()
                var totalValue: Float = 0; for value in values { totalValue += value }
                for value in values {
                    let percent = value / totalValue
                    let text = String(Int(round(percent * 100))) + "%"
                    newLabels.append(text)
                }
                labels = newLabels
            }
            self.setNeedsLayout()
        }
    }
    
    /// labels to show near the sectors
    public var labels: [String] = ["1", "2", "3", "4", "5"] {
        didSet {
            clearLabels()
            self.setNeedsLayout()
        }
    }
    
    /// total sum of all values in 'values'
    var totalValue: Float {
        get {
            var totalValue: Float = 0
            for value in values {
                totalValue += value
            }
            return totalValue
        }
    }
    
    /*
    The percent of the circle that all sectors are fit in.
    */
    @IBInspectable public var percentOfShow: CGFloat = 1.0 {
        didSet {
            if percentOfShow > 1 {
                percentOfShow = 1
            }
        }
    }
    
    /// the distance to the circle from bounds
    @IBInspectable var padding: CGFloat = 50 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// the line width
    @IBInspectable var lineWidth: CGFloat = 20 {
        didSet {
            updateLayerProperties()
        }
    }
    
    /// the shadow width
    @IBInspectable var shadowWidth: CGFloat = 5 {
        didSet {
            updateLayerProperties()
        }
    }
    
    /// the distance of the labels
    @IBInspectable var labelDistance: CGFloat = 83 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// added layers
    private var sectors: [CAShapeLayer]!
    private var sectorShadow: CAShapeLayer?
    private var labelViews = [UILabel]()
    
    /**
     Layout subviews
     */
    public override func layoutSubviews() {
        
        layoutLabels()
        if sectors == nil {
            sectors = [CAShapeLayer]()
            var i = 0
            for _ in self.values {
                let sector = CAShapeLayer()
                layer.addSublayer(sector)
                sectors.append(sector)
                
                let inset = padding + lineWidth / 2
                let innerRect = CGRectInset(bounds, inset, inset)
                let path = UIBezierPath(ovalInRect: innerRect)
                sector.path = path.CGPath
                sector.fillColor = nil
                sector.lineWidth = lineWidth
                sector.strokeColor = COLORS[i % COLORS.count].CGColor
                sector.anchorPoint = CGPointMake(0.5, 0.5)
                sector.transform = CATransform3DRotate(sector.transform, CGFloat(-M_PI/2), 0, 0, 1)
                
                i++
            }
        }
        if sectorShadow == nil {
            let sectorShadow = CAShapeLayer()
            layer.addSublayer(sectorShadow)
            
            let shadowInset = padding + lineWidth - shadowWidth / 2
            let shadowInnerRect = CGRectInset(bounds, shadowInset, shadowInset)
            let shadowPath = UIBezierPath(ovalInRect: shadowInnerRect)
            sectorShadow.path = shadowPath.CGPath
            sectorShadow.fillColor = nil
            sectorShadow.lineWidth = shadowWidth
            sectorShadow.strokeColor = UIColor(white: 0, alpha: 0.2).CGColor
            sectorShadow.anchorPoint = CGPointMake(0.5, 0.5)
            self.sectorShadow = sectorShadow
        }
        for sector in sectors {
            sector.frame = layer.bounds
        }
        
        updateLayerProperties()
        super.layoutSubviews()
    }
    
    /**
     Layout labels
     */
    func layoutLabels() {
        if labelViews.isEmpty && !labels.isEmpty {
            let font = UIFont.systemFontOfSize(16)
            let color = UIColor(red: 149/255, green: 159/255, blue: 159/255, alpha: 1)
            for text in labels {
                let label = UILabel(frame: bounds)
                label.textAlignment = .Center
                label.font = font
                label.textColor = color
                label.text = text
                self.addSubview(label)
                labelViews.append(label)
            }
        }
        if labels.count == values.count {
            var nextStart: CGFloat = 0
            for i in 0..<labels.count {
                let value = values[i]
                let nextEnd: CGFloat = nextStart + CGFloat(value / totalValue) * percentOfShow
                let alpha = CGFloat(M_PI) * 2 * ((nextEnd - nextStart) / 2 + nextStart) - CGFloat(M_PI_2)
                let x = self.bounds.width / 2 + cos(alpha) * labelDistance
                let y = self.bounds.height / 2 + sin(alpha) * labelDistance
                let size = CGSize(width: 42, height: 20)
                let rect = CGRect(origin: CGPoint(x: x - size.width / 2, y: y - size.height / 2), size: size)
                labelViews[i].frame = rect
                labelViews[i].text = labels[i]
                nextStart = nextEnd
            }
        }
        else {
            print("labels.count != values.count")
        }
    }
    
    /**
     Remove labels
     */
    func clearLabels() {
        for view in labelViews {
            view.removeFromSuperview()
        }
        labelViews.removeAll()
    }
    
    /**
     Remove existing sectors
     */
    private func clearSectors() {
        if sectors != nil {
            for sector in sectors {
                sector.removeFromSuperlayer()
            }
            sectors = nil
        }
        if let sectorShadow = sectorShadow {
            sectorShadow.removeFromSuperlayer()
            self.sectorShadow = nil
        }
    }
// dodo
//    func updateLayerProperties() {
//        if sectors != nil {
//            var i = 0
//            var nextStart: CGFloat = 0
//            for sector in sectors {
//                let value = values[i]
//                sector.strokeStart = nextStart
//                let nextEnd: CGFloat = nextStart + CGFloat(value / totalValue) * percentOfShow
//                sector.strokeEnd = nextEnd
//                nextStart = nextEnd
//                i++
//            }
//            sectorShadow?.strokeStart = 0
//            sectorShadow?.strokeEnd = percentOfShow
//        }
//    }
    
    /**
     Updates diagram sectors without animation
     */
    func updateLayerProperties() {
        updateLayerPropertiesWithAnimation(false)
    }
    
    /**
     Updates diagram sectors with animation
     
     :param: animate        flag: true - need to animate changes, false - no animation
     :param: timeMultiplier the multiplier for animation duration
     :param: completion     animation completion block
     */
    func updateLayerPropertiesWithAnimation(animate: Bool, _ timeMultiplier: Float = 1,
                                            _ completion: (()->())? = nil) {
        if sectors != nil {
            var i = 0
            var nextStart: CGFloat = 0
            CATransaction.begin()
            if let block = completion {
                CATransaction.setCompletionBlock(completion)
            }
            if animate {
                CATransaction.setAnimationDuration(animationDuration * CFTimeInterval(timeMultiplier))
            }
            else {
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            }
            for sector in sectors {
                var value = values[i]
                var nextEnd: CGFloat = nextStart + CGFloat(value / (totalValue > 0 ? totalValue : 1)) * percentOfShow
                
                sector.strokeStart = nextStart
                sector.strokeEnd = nextEnd
                
                if !animate {
                    sector.removeAllAnimations()
                }
                
                nextStart = nextEnd
                i++
            }
            CATransaction.commit()
        }
    }
    
    // MARK: Animation methods
    
    /**
     Reset diagram to zero (shows only background ring)
     
     :param: completion the animation completion block
     */
    public func resetToZero(completion: (()->())? = nil) {
        self.percentOfShow = 0
        updateLayerPropertiesWithAnimation(false, 1, completion)
    }
    
    /**
     Animate diagram sectors
     
     :param: animateFromStart flag: true - reset diagram to zero without animation, false - do not reset
     :param: timeMultiplier   the multiplier for animation duration. Used when a sequence of animations is applied
     :param: completion       animation completion block
     */
    public func animate(animateFromStart: Bool, timeMultiplier: Float = 1, completion: (()->())? = nil) {
        // Reset diagram to zero
        if animateFromStart {
            resetToZero() {
                dispatch_async(dispatch_get_main_queue(), {
                    self.percentOfShow = 1
                    self.updateLayerPropertiesWithAnimation(true, timeMultiplier, completion)
                })
            }
        }
        else {
            self.percentOfShow = 1
            self.updateLayerPropertiesWithAnimation(true, timeMultiplier, completion)
        }
    }
    
    /**
     Updates diagram without an animation
     */
    public func updateWithoutAnimation() {
        updateLayerPropertiesWithAnimation(false)
    }
}
