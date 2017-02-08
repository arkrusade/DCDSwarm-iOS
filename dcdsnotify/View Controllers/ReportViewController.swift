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
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet var tapGestureReconizer: UITapGestureRecognizer!
    @IBAction func sendReportButtonTapped(sender: AnyObject) {
        sendMail(subject: "test", message: "desc")
    }
    
    @IBOutlet weak var logSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        reportButton.bringSubview(toFront: reportButton)
    }
    @IBAction func onViewTapped(sender: AnyObject) {
        messageTextField.resignFirstResponder()
    }
    
    func sendReport(withLogs: Bool) {
        let subjectString = "[Self sent] Username: \(AppState.sharedInstance.credentials?.username)"
        var message = (messageTextField.text ?? "") + "\n"
        if withLogs {
            if let logs = CacheHelper.sharedInstance.retrieveAllLogs()
            {
                for log in logs {
                    message += "\(log.date) \t-\t\(log.htmlData)\n"
                }
            }
        }
        sendMail(subject: subjectString, message: message)
        
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
        let mailVC = getMailController(subject: subject, message: message)
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailVC, animated: true, completion: nil)
        }
        else {
            showSendMailErrorAlert()
        }
    }
    func showSendMailErrorAlert() {
        ErrorHandling.defaultError("Could not send email", desc: "Please check e-mail configuration", sender: self)
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: false, completion: nil)
    }
}
