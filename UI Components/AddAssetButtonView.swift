//
//  AddAssetButtonView.swift
//  dodo
//
//  Created by TCASSEMBLER on 18.02.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit
import MobileCoreServices

/**
 * Delegate protocol for AddAssetButtonView
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
public protocol AddAssetButtonViewDelegate {
    
    /**
     User has tapped on the view
     
     - parameter view: the view with button
     */
    func addAssetButtonTapped(view: AddAssetButtonView)
    
    /**
     Notify about selected image.
     WARNING! The method is invoked twice with different modalDismissed values
     
     - parameter image:          the image
     - parameter modalDismissed: true if modal was dismissed, false - if not yet.
     */
    func addAssetImageChanged(image: UIImage, modalDismissed: Bool)
    
    /**
     Video has selected
     
     - parameter url: the NSURL to local file
     */
    func addAssetVideoSelected(url: NSURL)
    
    func addAssetRemoved()
}


/**
 * View that contains a button that allows to add a photo
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
public class AddAssetButtonView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
AddAssetButtonViewDelegate {
    
    /// the maximum size of the image
    let MAX_IMAGE_SIZE: CGSize = CGSizeMake(400, 400)
    
    /// the delegate
    public var delegate: AddAssetButtonViewDelegate? = nil
    
    /// added subviews
    internal var button: UIButton!
    internal var imageView: UIImageView?
    internal var removeButton: UIButton!
    
    /// the attached image
    public var image: UIImage?
    public var videoURL: NSURL?
    
    /// supported media types
    
    internal var mediaTypes: [String] {
        return [kUTTypeImage as String, kUTTypeMovie as String]
    }
    
    /**
     Layout subviews
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutImage()
        layoutButton()
    }
    
    /**
     Update selected image
     
     - parameter image: the image
     */
    public func setSelectedImage(image: UIImage?) {
        imageView?.layer.masksToBounds = true
        imageView?.contentMode = .ScaleAspectFill
        imageView?.image = image
        self.image = image
    }
    
    /**
     Layout button and specify action handler method
     */
    internal func layoutButton() {
        if button == nil {
            button = UIButton(frame: self.bounds)
            button.addTarget(self, action: "buttonActionHandler", forControlEvents: .TouchUpInside)
            self.addSubview(button)
            removeButton.superview?.bringSubviewToFront(removeButton)
            removeButton.hidden = true
        }
        button.frame = self.bounds
    }
    
    /**
     Layout image view
     */
    internal func layoutImage() {
        let buttonSize: CGFloat = 30
        let buttonFrame = CGRectMake(self.bounds.width - buttonSize, self.bounds.height - buttonSize,
            buttonSize, buttonSize)
        
        if imageView == nil {
            imageView = UIImageView(frame: self.bounds)
            imageView?.image = self.image
            imageView?.contentMode = .ScaleAspectFill
            self.addSubview(imageView!)
            
            // Remove photo button
            
            removeButton = UIButton(frame: buttonFrame)
            removeButton.setImage(UIImage(named: "removePhoto"), forState: .Normal)
            removeButton.addTarget(self, action: "removePhoto", forControlEvents: .TouchUpInside)
            self.addSubview(removeButton)
        }
        removeButton.frame = buttonFrame
        imageView?.frame = self.bounds
    }
    
    // MARK: Image selection
    
    /**
    Button action handler
    */
    func buttonActionHandler() {
        UIViewController.getCurrentViewController()?.view.endEditing(true)
        (delegate ?? self).addAssetButtonTapped(self)
    }
    
    /**
     Check if can change photo
     
     - returns: true - if tapping on the view will show the dialog, false - will do nothing
     */
    func canChangePhoto() -> Bool {
        return true
    }
    
    /**
     Remove button action handler
     */
    func removePhoto() {
        UIViewController.getCurrentViewController()?.view.endEditing(true)
        let alert = UIAlertController(title: nil, message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete " + (videoURL == nil ? "Photo" : "Video"),
            style: UIAlertActionStyle.Destructive,
            handler: { (action: UIAlertAction!) in
                self.setSelectedImage(nil)
                self.videoURL = nil
                self.delegate?.addAssetRemoved()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        UIViewController.getCurrentViewController()?.presentViewController(alert, animated: animationEnabled, completion: nil)
    }
    
    /**
     Show camera capture screen
     */
    func showCameraPicker() {
        self.showPickerWithSourceType(UIImagePickerControllerSourceType.Camera)
    }
    
    /**
     Show photo picker
     */
    func showPhotoLibraryPicker() {
        showPickerWithSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    /**
     Show image picker
     
     - parameter sourceType: the type of the source
     */
    func showPickerWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.mediaTypes = self.mediaTypes
            imagePicker.sourceType = sourceType
            (UIApplication.sharedApplication().delegate as? AppDelegate)?.allowAllOrientations = true // dodo for iPad landscape
            imagePicker.videoQuality = UIImagePickerControllerQualityType.TypeMedium
            UIViewController.getCurrentViewController()?.presentViewController(imagePicker, animated: animationEnabled,
                completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "This feature is supported on real devices only",
                preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            UIViewController.getCurrentViewController()?.presentViewController(alert,
                animated: animationEnabled, completion: nil)
        }
    }
    
    /**
     Image selected/captured
     
     - parameter picker: the picker
     - parameter info:   the info
     */
    public func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            var resizedImage: UIImage?
            (UIApplication.sharedApplication().delegate as? AppDelegate)?.allowAllOrientations = false // dodo for iPad landscape
            if let mediaType: AnyObject = info[UIImagePickerControllerMediaType] {
                if mediaType.description == kUTTypeMovie as String {
                    if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL {
                        self.videoURL = videoURL
                        self.setSelectedImage(UIImage(named: "videoAsset"))
                        self.delegate?.addAssetVideoSelected(videoURL)
                    }
                    else if let videoURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
                        self.videoURL = videoURL
                        self.setSelectedImage(UIImage(named: "videoAsset"))
                        self.delegate?.addAssetVideoSelected(videoURL)
                    }
                }
                else if mediaType.description == kUTTypeImage as String {
                    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                        let newWidth = MAX_IMAGE_SIZE.width
                        let newHeight = newWidth * image.size.height / image.size.width
                        resizedImage = imageResize(image, sizeChange: CGSize(width: newWidth, height: newHeight))
                        self.videoURL = nil
                        self.setSelectedImage(resizedImage!)
                        self.delegate?.addAssetImageChanged(resizedImage!, modalDismissed: false)
                    }
                }
            }
            if let resizedImage = resizedImage {
                picker.dismissViewControllerAnimated(animationEnabled, completion: {
                    self.delegate?.addAssetImageChanged(resizedImage, modalDismissed: true)
                })
            }
            else {
                picker.dismissViewControllerAnimated(animationEnabled, completion: nil)
            }
    }
    
    /**
     Resize the image
     
     - parameter imageObj:   the image
     - parameter sizeChange: the new size
     
     - returns: resized image
     */
    func imageResize(imageObj:UIImage, sizeChange:CGSize)-> UIImage {
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    /**
     Image selection canceled
     
     - parameter picker: the picker
     */
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(animationEnabled, completion: nil)
    }
    
    // MARK: AddAssetButtonViewDelegate
    
    /**
    User has tapped on the view
    
    - parameter view: the view with button
    */
    public func addAssetButtonTapped(view: AddAssetButtonView) {
        // Open action sheet only if photo is not selected
        if canChangePhoto() {
            let alert = UIAlertController(title: nil, message: nil,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default,
                handler: { (action: UIAlertAction!) in
                    self.showCameraPicker()
            }))
            
            alert.addAction(UIAlertAction(title: "Choose Photo", style: .Default,
                handler: { (action: UIAlertAction!) in
                    self.showPhotoLibraryPicker()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            UIViewController.getCurrentViewController()?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /**
     Nothing to do. Only external delegate can implement this method to process the image
     
     - parameter image:          the image
     - parameter modalDismissed: true if modal was dismissed, false - if not yet.
     */
    public func addAssetImageChanged(image: UIImage, modalDismissed: Bool) {
    }
    
    /**
     Nothing to do. Only external delegate can implement this method to process the video
     
     - parameter url: the NSURL to local file
     */
    public func addAssetVideoSelected(url: NSURL) {
    }
    
    /**
     Nothing to do
     */
    public func addAssetRemoved() {
    }
}
