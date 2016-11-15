//
//  MailUtil.swift
//  dodo
//
//  Created by Alexander Volkov on 11.03.15.
//  Copyright (c) 2015 seriyvolk83dodo, Inc. All rights reserved.
//

import UIKit
import MessageUI

/**
 * Helpful class for opening Compose Mail dialog. Works similar to ConfirmDialog
 *
 * @author Alexander Volkov
 * @version 1.0
 */
class MailDialog: NSObject, MFMailComposeViewControllerDelegate {
    
    init(toEmails: [String]) {
        super.init()
        openDialog(subject: "", emails: toEmails, text: "")
    }
    
    init(toEmail: String) {
        super.init()
        openDialog(subject: "", emails: [toEmail], text: "")
    }
    
    init(subject: String, text: String) {
        super.init()
        openDialog(subject: subject, emails: [], text: text)
    }
    
    override init() {
        super.init()
    }
    
    /**
     Opens dialog with given data
     
     :param: subject default email subject
     :param: emails  the emails to substitute
     :param: text    the text
     */
    private func openDialog(subject: String, emails: [String], text: String) {
        // Open letter
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setToRecipients(emails)
        vc.setMessageBody(text, isHTML: false)
        vc.mailComposeDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        
        if let top = UIApplication.shared.keyWindow?.rootViewController {
            var host = top
            while host.presentedViewController != nil { host = host.presentedViewController! }
            host.present(vc, animated: true) { () -> Void in }
        }
    }
    
    func openDialog(subject: String, emails: [String], text: String, withPDF localUrl: URL, pdfFilename: String) -> MailDialog? {
        // check availability
        if !MFMailComposeViewController.canSendMail() {
            showAlert("Error", message: "Can't send mail! Ensure you've properly setup your email account in Mail app")
            return nil
        }
        
        // Open letter
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setToRecipients(emails)
        vc.setMessageBody(text, isHTML: false)
        vc.mailComposeDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        
        if let data = NSData(contentsOfFile: localUrl.absoluteString) {
            let fileName = "\(pdfFilename).pdf"
            let mimeType = "application/pdf"
            
            vc.addAttachmentData(data as Data, mimeType: mimeType, fileName: fileName)
            UIViewController.getCurrentViewController()?.present(vc, animated: true, completion: nil)
            return self
        }
        else {
            showAlert("Cannot find the file", message: "Cannot open file \"\(pdfFilename).pdf\"")
        }
        return nil
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
