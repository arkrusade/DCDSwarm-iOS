//
//  ScheduleViewController.swift
//  dcdsnotify
//
//  Created by Justin Lee on 10/7/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
class ScheduleViewController: UIViewController {
    var date: NSDate!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleBar: UINavigationItem!
    var daySchedule: DaySchedule? = DaySchedule()
    override func viewDidLoad() {
        //means no schedule exists for this day, usually weekends
        if daySchedule == nil {
            daySchedule = DaySchedule()
            daySchedule?.date = date
            let emptyBlock: Block = ("Could not", "find schedule")
            daySchedule?.blocks = [emptyBlock]
        }
        self.titleBar.title = "Schedule"
        self.titleBar.backBarButtonItem?.title = "Assignments"
        tableView.reloadData()
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
