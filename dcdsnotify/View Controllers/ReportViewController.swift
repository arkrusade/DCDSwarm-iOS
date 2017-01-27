//
//  ReportViewController.swift
//  dcdsnotify
//
//  Created by Justin Laptop Lee on 1/26/17.
//  Copyright © 2017 orctech. All rights reserved.
//

import MessageUI
import UIKit
class ReportViewController: UIViewController {
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func sendReportButtonTapped(sender: AnyObject) {
        sendMail("test", message: "desc")
    }
}
extension ReportViewController: MFMailComposeViewControllerDelegate {
    func getMailController(subject: String, message: String) -> MFMailComposeViewController{
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        
        mailVC.setToRecipients(["dcdsnotify@gmail.com"])
        mailVC.setSubject(subject)
        mailVC.setMessageBody(message, isHTML: false)
        
        return mailVC
    }
    func sendMail(subject: String, message: String) {
        let mailVC = getMailController(subject, message: message)
        if MFMailComposeViewController.canSendMail()
        {
            self.presentViewController(mailVC, animated: true, completion: nil)
        }
        else {
            showSendMailErrorAlert()
        }
    }
    func showSendMailErrorAlert() {
        ErrorHandling.defaultError("Could not send email", desc: "Please check e-mail configuration", sender: self)
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(false, completion: nil)
    }
}
