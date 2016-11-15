//
//  BlurredNode.swift
//  dodo
//
//  Created by TCASSEMBLER on 03.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit

/// option: true - will blur central node, false - will blur only parent nodes in background
public let OPTION_BLUR_CENTRAL_NODE = false

/**
 * Category node view
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
public class BlurredNode: NodeView {
    
    /// outlets
    @IBOutlet weak var innerCircleView: UIView!
    @IBOutlet weak var numberOfItemsLabel: UILabel?
    @IBOutlet weak var detailsTextLabel: UILabel?
    @IBOutlet weak var blurredImageView1: UIImageView!
    @IBOutlet weak var blurredImageView2: UIImageView!
    
    /// the cached blurred images of this view
    private var cachedBlurredImages = [CGFloat: UIImage]()
    
    /**
     The collision type represents how the dynamics system will evaluate collisions with
     respect to the dynamic item.
     */
    @available(iOS 9.0, *)
    override public var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }
    
    /**
     Create view for a common category
     
     - returns: the view
     */
    class func createCategoryView() -> CategoryNodeView {
        return UIView.loadFromNibNamed("CategoryNodeView") as! CategoryNodeView
    }
    
    /**
     Create view for a special category
     
     - returns: the view
     */
    class func createSpecialCategoryView() -> CategoryNodeView {
        return UIView.loadFromNibNamed("SpecialCategoryNodeView") as! CategoryNodeView
    }
    
    /**
     Create view for the root node
     
     - returns: the view
     */
    class func createRootNodeView() -> CategoryNodeView {
        return UIView.loadFromNibNamed("RootNodeView") as! CategoryNodeView
    }
    
    /**
     Configure the view with given node
     
     - parameter node: the node
     
     - returns: self
     */
    func configure(node: CategoryNode) -> NodeView {
        self.node = node
        titleLabel.text = node.title.uppercaseString
        
        if let specialNode = node as? SpecialCategoryNode {
            detailsTextLabel?.text = specialNode.text
        }
        else {
            numberOfItemsLabel?.text = "(\(node.getNumberOfChildrenToShow()))"
        }
        updateUI()
        return self
    }
    
    /**
     Setup UI
     */
    override public func awakeFromNib() {
        super.awakeFromNib()
        updateSize(self.mainView.bounds.size)
    }
    
    /**
     Update UI with new size
     
     - parameter size: <#size description#>
     */
    func updateSize(size: CGSize) {
        let innerCircleMargins: CGFloat = 5
        mainView.roundCorners(size.width / 2)
        innerCircleView.roundCorners(size.width / 2 - innerCircleMargins)
        
        updateUI()
    }
    
    /**
     Update UI
     */
    func updateUI() {
        updateBorders()
    }
    
    /**
     Update borders
     */
    func updateBorders() {
        // Change color
        let bubbleColor = ((attributes?.leafFactor ?? 1) > 0.8 ? UIColor.gray() : UIColor.blue())
        let bubbleBorderWidth: CGFloat = 1.5 - 1 * (attributes?.leafFactor ?? 1)
        mainView.addBorder(bubbleColor, borderWidth: bubbleBorderWidth)
        innerCircleView.alpha = (attributes?.innerDetailsFactor ?? 0)
        innerCircleView.addBorder(bubbleColor, borderWidth: bubbleBorderWidth)
    }
    
    /**
     Update shadow offset
     
     - parameter offset:   the offset
     - parameter animated: the animation flag
     */
    func updateShadowOffset(offset: CGSize, animated: Bool = false) {
        if node is RootNode {
            return
        }
        self.layer.shadowColor = UIColor.blackColor().CGColor
        
        if animated {
            CATransaction.begin()
            let wAnimation = CABasicAnimation(keyPath: "shadowOffset.width")
            wAnimation.fromValue = NSNumber(float: Float(self.layer.shadowOffset.width))
            wAnimation.toValue = NSNumber(float: Float(offset.width))
            wAnimation.duration = 0.7
            wAnimation.removedOnCompletion = true
            self.layer.addAnimation(wAnimation, forKey: "shadowOffset.width")
            
            let hAnimation = CABasicAnimation(keyPath: "shadowOffset.height")
            hAnimation.fromValue = NSNumber(float: Float(self.layer.shadowOffset.height))
            hAnimation.toValue = NSNumber(float: Float(offset.height))
            hAnimation.duration = 0.7
            hAnimation.removedOnCompletion = true
            self.layer.addAnimation(hAnimation, forKey: "shadowOffset.height")
            CATransaction.commit()
        }
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPointZero, size: self.frame.size),
            cornerRadius: self.frame.size.width / 2).CGPath
    }
    
    /**
     Update UI with new attributes
     
     - parameter attributes: the attributes
     - parameter animated:   the animation flag
     */
    override func updateWithAttributes(attributes: LayoutAttributes, animated: Bool) {
        super.updateWithAttributes(attributes, animated: animated)
        let size = CGSizeMake(self.frame.size.width,
            self.frame.size.height)
        updateSize(size)
        updateShadowOffset(attributes.shadow, animated: animated)
        applyBlur(attributes.level)
    }
    
    // MARK: Blur
    
    /**
    Apply blur of given radius
    
    - parameter level: the depth level: 0 - leafs, 1 - current node, 2 - first parent, 3 - second parent, etc.
    */
    func applyBlur(level: CGFloat) {
        blurredImageView1.hidden = true
        blurredImageView2.hidden = true
        if level > 0 {
            let settings = getBlurSettings(level)
            
            // apply main image
            if settings.count > 0 {
                blurredImageView1.image = getBlurredImage(settings[0].radius)
                blurredImageView1.alpha = settings[0].alpha
                blurredImageView1.hidden = false
            }
            
            // apply the second image if needed
            if settings.count == 2 {
                blurredImageView2.image = getBlurredImage(settings[1].radius)
                blurredImageView2.alpha = settings[1].alpha
                blurredImageView2.hidden = false
            }
            else {
                blurredImageView2.hidden = true
            }

        }
    }
    
    /**
     Get blur settings for given level.
     Converts level to blur radius:
     level=2 -> radius=2
     level=3 -> radius=3
     level=2.2 -> radius=3, alpha = 0.2
     If alpha is not integer value, then provides a second image settings:
     radius[1]:=radius[0]-1, alpha = 1. This images should be added below the main image.
     These settings define one-two images that emulate continuous blur for float level values from 1 and greater.
     
     - parameter level: the depth level
     
     - returns: the settings
     */
    public func getBlurSettings(level: CGFloat) -> [(radius: CGFloat, alpha: CGFloat)] {
        let centralNodeBlur: CGFloat = OPTION_BLUR_CENTRAL_NODE ? 0 : 1
        let effectiveLevel = level - CGFloat(OPTION_BLUR_CENTRAL_NODE ? 0 : 1)
        let floorLevel = floor(effectiveLevel)
        let ceilLevel = ceil(effectiveLevel)
        if effectiveLevel <= 0 {
            return []
        }
        if floorLevel == ceilLevel {
            return [(radius: centralNodeBlur + floorLevel, 1)]
        }
        else if effectiveLevel < 1 {
            return [(radius: centralNodeBlur + ceilLevel, effectiveLevel - floorLevel)]
        }
        else {
            return [(radius: centralNodeBlur + ceilLevel, effectiveLevel - floorLevel),
                (radius: centralNodeBlur + floorLevel, 1)]
        }
        
    }
    
    /**
     Get blurred image with given blue radius
     
     - parameter radius: the radius
     
     - returns: the image
     */
    private func getBlurredImage(radius: CGFloat) -> UIImage? {
        if let image = cachedBlurredImages[radius] {
            return image
        }
        else {
            // save the states of the images and hide
            let hidden1 = blurredImageView1.hidden
            let hidden2 = blurredImageView2.hidden
            blurredImageView1.hidden = true
            blurredImageView2.hidden = true
            
            // Create blurred snapshort
            let image = mainView.createBlurredImageView(20, blurRadius: radius)
            cachedBlurredImages[radius] = image
            
            // restore the state of the images
            blurredImageView1.hidden = hidden1
            blurredImageView2.hidden = hidden2
            return image
        }
    }
}

