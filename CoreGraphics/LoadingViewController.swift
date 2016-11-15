//
//  LoadingViewController.swift
//  dodo
//
//  Created by Volkov Alexander on 02.03.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit

/**
 * Loading screen
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class LoadingViewController: UIViewController {

    /// the width of the logo gradient
    let GRADIENT_WIDTH: CGFloat = 61
    
    /// the duration of loading simulation
    let LOADING_SIMULATION_DURATION: NSTimeInterval = 3
    
    /// outlets
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var colorLogo: UIImageView!
    @IBOutlet weak var maskLeftMargin: NSLayoutConstraint!
    
    /// mask gradient layer
    private var gradientLayer: CAGradientLayer!
    
    /**
     Setup UI
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        maskLeftMargin.constant = -GRADIENT_WIDTH
        gradientLayer = addMask()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    /**
     Add mask and return the used gradient layer
     
     - returns: gradient layer
     */
    func addMask() -> CAGradientLayer {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: colorLogo.bounds.width, height: colorLogo.bounds.height)
        let gradient: CAGradientLayer = CAGradientLayer()
        let width = 2 * colorLogo.bounds.width + GRADIENT_WIDTH
        let leftWidth = colorLogo.bounds.width
        gradient.frame = CGRect(x: 0, y: 0,
            width: width,
            height: colorLogo.bounds.height)
        gradient.colors = [UIColor.redColor().CGColor, UIColor.clearColor().CGColor]
        gradient.startPoint = CGPoint(x: leftWidth/width, y: 0)
        gradient.endPoint = CGPoint(x: (leftWidth + GRADIENT_WIDTH)/width, y: 0)
        gradient.anchorPoint = CGPointZero
        layer.insertSublayer(gradient, atIndex: 0)
        
        colorLogo.layer.mask = layer
        return gradient
    }
    
    /**
     Load data
     
     - parameter animated: the animation flag
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }
    
    /**
     Simulate loading data
     */
    func loadData() {
        CATransaction.begin()
        // Set final position
        gradientLayer.position = CGPointZero
        
        // Add animation to that final position
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = NSNumber(float: Float(-1 * (colorLogo.bounds.width + GRADIENT_WIDTH)))
        animation.toValue = 0
        animation.duration = LOADING_SIMULATION_DURATION
        animation.removedOnCompletion = true
        self.gradientLayer.addAnimation(animation, forKey: "position.x")
        CATransaction.commit()
    }
    
    /**
     Open first screen after loading
     */
    func openFirstScreen() {
        // dodo
    }
    
    /**
     Hide status bar
     
     - returns: true
     */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

