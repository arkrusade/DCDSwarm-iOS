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
    @IBOutlet weak var logSwitch: UISwitch!
    @IBOutlet var tapGestureReconizer: UITapGestureRecognizer!
    
    @IBAction func sendReportButtonTapped(_ sender: Any) {
        sendReport(withLogs: logSwitch.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Send Feedback"
        reportButton.bringSubview(toFront: reportButton)
    }
    
    @IBAction func onViewTapped(_ sender: Any) {
        messageTextField.resignFirstResponder()
    }
    
    func sendReport(withLogs: Bool) {
        let subjectString = "[User sent] Username: \(AppState.sharedInstance.credentials?.username ?? "not found")"
        let message = (messageTextField.text ?? "")
        //TODO: change to attatchment
        var dataString = ""
        if withLogs {
            if let logs = CacheHelper.sharedInstance.retrieveAllLogs()
            {
                for log in logs {
                    dataString += "\(log.date) \t-\t\(log.htmlData)\n"
                }
            }
        }
        let data = dataString.data(using: .utf8)!
        
        sendMail(subject: subjectString, message: message, data: data)
        
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
    func sendMail(subject: String?, message: String?, data: Data?) {
        let mailVC = getMailController(subject: subject ?? "", message: message ?? "")
        if let data = data {
            mailVC.addAttachmentData(data, mimeType: ".txt", fileName: "logs")
        }
        
        
        if MFMailComposeViewController.canSendMail()
        {
            present(mailVC, animated: true, completion: nil)
        }
        else {
            showSendMailErrorAlert()
        }
    }
    func showSendMailErrorAlert() {
        ErrorHandling.defaultError("Could not send email", desc: "Please check e-mail configuration", sender: self)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if(error == nil)
        {
            if(result == .cancelled) {
                controller.dismiss(animated: true, completion: nil)
                
            }
            else if (result == .sent) {
                controller.dismiss(animated: true, completion: nil)
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
