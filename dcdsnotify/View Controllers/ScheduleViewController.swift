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
    var date: Date! {
        get {
            return AppState.sharedInstance.getDate()
        }
    }
    fileprivate var daySchedule: DaySchedule? = DaySchedule()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nil means no schedule exists for this day, usually weekends
        updateBlocks(nil)
        configureArrows()
        
        configureNavBar()
    }
    func updateBlocks(_ forDate: Date?) {
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
        self.titleBar.title = "Block Schedule"
    }
    func configureArrows() {
        self.view.bringSubview(toFront: yesterdayButton)
        self.view.bringSubview(toFront: tomorrowButton)
        
        let left = Constants.Images.leftCarat.alpha(0.5)
        yesterdayButton.setBackgroundImage(left, for: UIControlState())
        let right = Constants.Images.rightCarat.alpha(0.5)
        tomorrowButton.setBackgroundImage(right, for: UIControlState())
        
        yesterdayButton.addTarget(self, action: #selector(yesterdaySchedule(_:)), for: .touchUpInside)
        tomorrowButton.addTarget(self, action: #selector(tomorrowSchedule(_:)), for: .touchUpInside)
    }
    func yesterdaySchedule(_ sender: AnyObject?) {
        AppState.sharedInstance.changeDate(date: date.yesterday())
        updateBlocks(nil)
    }
    func tomorrowSchedule(_ sender: AnyObject?) {
        AppState.sharedInstance.changeDate(date: date.yesterday())
        updateBlocks(nil)
    }
    func segueToDatePicker(_ sender: AnyObject?)
    {
        let dateVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.Date) as! DatePickerViewController
        dateVC.sendingVC = self
        self.navigationController?.pushViewController(dateVC, animated: true)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let titleView = UITextView(frame: headerView.frame)
        titleView.textAlignment = .center

        if section == 0 {
            titleView.text = "\(date.dayOfTheWeek() ?? "activitiesDay") - \(date.asSlashedDate())"
            titleView.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            let gradient: CAGradientLayer = CAGradientLayer.init(layer: titleView)
            gradient.frame = headerView.bounds
            gradient.colors = [(UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.00).cgColor as AnyObject), (UIColor(red: 0.82, green: 0.82, blue: 0.85, alpha: 1.00).cgColor as AnyObject)]
            titleView.layer.insertSublayer(gradient, at: 0)

        }
        headerView.addSubview(titleView)
        return headerView

    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 1 ? 0 : 40)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 1 ? (daySchedule?.blocks.count ?? 0) : 1)
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCell") as! BlockCell
        cell.backgroundColor = UIColor(colorLiteralRed: 230/256, green: 230/256, blue: 230/256, alpha: 1)

        guard indexPath.section == 1 else {
            cell.block = ("Block", "Time")
            return cell
        }

        cell.block = daySchedule?.blocks[indexPath.row]
        return cell
    }

}
