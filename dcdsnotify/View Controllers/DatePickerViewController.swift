//
//  DatePickerViewController.swift
//  dcdsnotify
//
//  Created by Justin Laptop Lee on 1/17/17.
//  Copyright © 2017 orctech. All rights reserved.
//

import UIKit
class DatePickerViewController: UIViewController {
    var date: Date! = Date()
    var sendingVC: UIViewController!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    override func viewDidLoad() {
        confirmButton.titleLabel?.text = "Go To Date"
        datePicker.datePickerMode = UIDatePickerMode.date
        self.title = "Change Date"
        
        datePicker.date = date
        datePickerChanged(datePicker)
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: UIControlEvents.valueChanged)
    }
    
    @IBAction func confirmButtonTapped(_ sender: AnyObject) {
        returnToVC(datePicker.date)
    }
    func returnToVC(_ date: Date) {
        if let HWVC = sendingVC as? HomeworkViewController {
            HWVC.changeDate(date)
        }
        else if let ScheduleVC = sendingVC as? ScheduleViewController {
            ScheduleVC.date = date
            ScheduleVC.viewDidLoad()
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func todayButtonTapped(_ sender: AnyObject) {
        let today = Date()
        self.datePicker.date = today
        returnToVC(today)
    }
    
    func datePickerChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = Date.dateFormatterSlashedAndDay()
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
}
