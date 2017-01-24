//
//  DatePickerViewController.swift
//  dcdsnotify
//
//  Created by Justin Laptop Lee on 1/17/17.
//  Copyright © 2017 orctech. All rights reserved.
//

import UIKit
class DatePickerViewController: UIViewController {
    var date: NSDate! = NSDate()
    var sendingVC: UIViewController!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    override func viewDidLoad() {
        confirmButton.titleLabel?.text = "Go To Date"
        datePicker.datePickerMode = UIDatePickerMode.Date
        navigationController?.title = "Change Date"
        
        datePicker.date = date
        datePickerChanged(datePicker)
        datePicker.addTarget(self, action: #selector(datePickerChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    @IBAction func confirmButtonTapped(sender: AnyObject) {
        returnToVC(datePicker.date)
//        let HWVC = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count-2] as? HomeworkViewController
//        HWVC?.changeDate(datePicker.date)
//        self.navigationController?.popViewControllerAnimated(true)
        
    }
    func returnToVC(date: NSDate) {
        if let HWVC = sendingVC as? HomeworkViewController {
            HWVC.changeDate(date)
        }
        else if let ScheduleVC = sendingVC as? ScheduleViewController {
            ScheduleVC.date = date
            ScheduleVC.viewDidLoad()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func todayButtonTapped(sender: AnyObject) {
        let today = NSDate()
        self.datePicker.date = today
        datePickerChanged(datePicker)
    }
    
    func datePickerChanged(datePicker: UIDatePicker) {
        let dateFormatter = NSDate.dateFormatterSlashedAndDay()
        dateLabel.text = dateFormatter.stringFromDate(datePicker.date)
    }
}
