//
//  ScheduleViewController.swift
//  dcdsnotify
//
//  Created by Justin Lee on 10/7/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
class ScheduleViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var tomorrowButton: UIButton!
    var date: NSDate!
    private var daySchedule: DaySchedule? = DaySchedule()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //means no schedule exists for this day, usually weekends
        updateBlocks(nil)
        configureArrows()
        
        configureNavBar()
    }
    func updateBlocks(forDate: NSDate?) {
        daySchedule = ExcelHelper.sharedInstance.getSchedule(forDate ?? date, sender: self)
        if daySchedule == nil {
            daySchedule = DaySchedule()
            daySchedule?.date = date
            let emptyBlock: Block = ("Could not", "find schedule")
            let checkBlock: Block = ("Have you ", "updated recently?")
            daySchedule?.blocks = [emptyBlock]//, checkBlock]
        }
        tableView.reloadData()


    }
    func configureNavBar() {
        let datePickerButton = UIBarButtonItem(image: Constants.Images.calendar, style: .Plain, target: self, action: #selector(segueToDatePicker(_: )))
        self.navigationItem.rightBarButtonItem = datePickerButton
        
        self.titleBar.title = "Schedule"
    }
    func configureArrows() {
        self.view.bringSubviewToFront(yesterdayButton)
        self.view.bringSubviewToFront(tomorrowButton)
        
        let left = Constants.Images.leftCarat.alpha(0.5)
        yesterdayButton.setBackgroundImage(left, forState: .Normal)
        let right = Constants.Images.rightCarat.alpha(0.5)
        tomorrowButton.setBackgroundImage(right, forState: .Normal)
        
        yesterdayButton.addTarget(self, action: #selector(yesterdaySchedule(_:)), forControlEvents: .TouchUpInside)
        tomorrowButton.addTarget(self, action: #selector(tomorrowSchedule(_:)), forControlEvents: .TouchUpInside)
    }
    func yesterdaySchedule(sender: AnyObject?) {
        date = date?.yesterday()
        updateBlocks(nil)
    }
    func tomorrowSchedule(sender: AnyObject?) {
        date = date?.tomorrow()
        updateBlocks(nil)
    }
    func segueToDatePicker(sender: AnyObject?)
    {
        let dateVC = self.storyboard?.instantiateViewControllerWithIdentifier("datePicker") as! DatePickerViewController
        dateVC.date = self.date
        dateVC.sendingVC = self
        self.navigationController?.pushViewController(dateVC, animated: true)
        
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        let titleView = UITextView(frame: headerView.frame)
        titleView.textAlignment = .Center


        if section == 0 {
            titleView.text = "\(date.dayOfTheWeek() ?? "Day") - \(date.asSlashedDate())"
            titleView.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            let gradient: CAGradientLayer = CAGradientLayer.init(layer: titleView)
            gradient.frame = headerView.bounds
            gradient.colors = [(UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.00).CGColor as AnyObject), (UIColor(red: 0.82, green: 0.82, blue: 0.85, alpha: 1.00).CGColor as AnyObject)]
            titleView.layer.insertSublayer(gradient, atIndex: 0)

        }
        headerView.addSubview(titleView)
        return headerView

    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 1 ? 0 : 40)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 1 ? (daySchedule?.blocks.count ?? 0) : 1)
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("BlockCell") as! BlockCell
        cell.backgroundColor = UIColor(colorLiteralRed: 230/256, green: 230/256, blue: 230/256, alpha: 1)

        guard indexPath.section == 1 else {
            cell.block = ("Block", "Time")
            return cell
        }

        cell.block = daySchedule?.blocks[indexPath.row]
        return cell
    }

}
