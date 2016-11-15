//
//  CirleDiagram.swift
//  UIComponents
//
//  Created by TCASSEMBLER on 23.02.15.
//  Copyright (c) 2015 seriyvolk83dodo. All rights reserved.
//

import QuartzCore
import UIKit

/**
* Circle diagram with color sectors
*
* @author TCASSEMBLER
* @version 1.0
*/
@IBDesignable
public class CirleDiagram: UIView {

    // colors for different sectors
    let COLORS = [
        UIColor(red: 76/255, green: 188/255, blue: 119/255, alpha: 1.0),
        UIColor(red: 238/255, green: 85/255, blue: 75/255, alpha: 1.0),
        UIColor(red: 238/255, green: 85/255, blue: 75/255, alpha: 1.0),
        UIColor(red: 76/255, green: 188/255, blue: 119/255, alpha: 1.0)
    ]
    
    @IBInspectable public var INNER_CICLE_SIZE: CGFloat = 160
    
    @IBInspectable public var enableCenterShadow: Bool = true
    
    /// values to be shown as sectors
    public var values: [Float] = [10,20,20,10] {
        didSet {
            clearSectors()
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
    Used for initial animation of the circle.
    */
    @IBInspectable public var percentOfShow: CGFloat = 1.0 {
        didSet {
            if percentOfShow > 1 {
                percentOfShow = 1
            }
            updateLayerProperties()
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 45 {
        didSet {
            updateLayerProperties()
        }
    }
    
    var backgroundRingLayer: CAShapeLayer!
    var centerLayer: CAShapeLayer!
    var sectors: [CAShapeLayer]!

    public override func layoutSubviews() {
        
        // Background ring (gray)
        if backgroundRingLayer == nil {
            backgroundRingLayer = CAShapeLayer()
            layer.addSublayer(backgroundRingLayer)
            
            let rect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)
            let path = UIBezierPath(ovalInRect: rect)
            backgroundRingLayer.path = path.CGPath
            backgroundRingLayer.fillColor = nil
            backgroundRingLayer.lineWidth = lineWidth
            backgroundRingLayer.strokeColor = UIColor(white: 0.5, alpha: 0.3).CGColor
            
        }
        backgroundRingLayer.frame = layer.bounds
        
        // Sectors
        if centerLayer == nil {
            centerLayer = CAShapeLayer()
            layer.addSublayer(centerLayer)
            
            var innerRect = CGRectMake(0, 0, INNER_CICLE_SIZE, INNER_CICLE_SIZE)
            let path = UIBezierPath(ovalInRect: innerRect)
            centerLayer.fillColor = UIColor.whiteColor().CGColor
            centerLayer.path = path.CGPath
            
            if enableCenterShadow {
                // Add shadow
                centerLayer.shadowColor = UIColor.blackColor().CGColor
                centerLayer.shadowRadius = 10
                centerLayer.shadowOffset = CGSize(width: 10, height: 10)
                centerLayer.masksToBounds = false
                centerLayer.shadowOpacity = 0.3;
            }
        }
        centerLayer.frame = CGRectMake((layer.bounds.width-INNER_CICLE_SIZE)/2,
            (layer.bounds.height-INNER_CICLE_SIZE)/2, INNER_CICLE_SIZE, INNER_CICLE_SIZE)
        
        if sectors == nil {
            sectors = [CAShapeLayer]()
            var i = 0
            for value in self.values {
                let sector = CAShapeLayer()
                layer.addSublayer(sector)
                sectors.append(sector)
                
                let innerRect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)
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
        for sector in sectors {
            sector.frame = layer.bounds
        }
        updateLayerProperties()
        super.layoutSubviews()
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
    }
    
    func updateLayerProperties() {
        if sectors != nil {
            var i = 0
            var nextStart: CGFloat = 0
            for sector in sectors {
                var value = values[i]
                sector.strokeStart = nextStart
                var nextEnd: CGFloat = nextStart + CGFloat(value / totalValue) * percentOfShow
                sector.strokeEnd = nextEnd
                nextStart = nextEnd
                i++
            }
        }
    }
}
