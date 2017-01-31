//
//  SettingsViewController.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 9/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
typealias SettingsCategory = (category: String, list: [SettingsAction])
typealias SettingsAction = (title: String, action: ClosureVoid )
typealias Closure = ()
typealias ClosureVoid = () -> Void

class SettingsViewController: UIViewController {
    var settingsList: [SettingsCategory]! = nil
    //TODO: set current date action

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var titleBar: UINavigationItem!
	
	
	override func viewDidLoad() {
        configureSettingsList()
		titleBar.title = "Settings"
        topConstraint.constant = -(self.navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.size.height
	}

    func configureSettingsList() {
        let logoutClosure: ClosureVoid = {() -> Void in
            AppState.sharedInstance.logout(self)
        }
        let clearCacheClosure: ClosureVoid = { ClosureVoid in
            CacheHelper.clearUserCache(self)
        }
        
        let scheduleClosure: ClosureVoid = { ClosureVoid in
            self.showSchedule()
        }
        let userCategory: SettingsCategory
        userCategory.category = "User Settings"

        let clearCacheSetting: SettingsAction = ("Clear Cache", clearCacheClosure)
        let logoutAction: SettingsAction = ("Logout", logoutClosure)
        userCategory.list = [clearCacheSetting, logoutAction]


        let scheduleCategory: SettingsCategory
        scheduleCategory.category = "Schedule"

        let scheduleAction: SettingsAction = ("Block Schedule", scheduleClosure)
        scheduleCategory.list = [scheduleAction]
        
        settingsList = [userCategory, scheduleCategory]
        //,("Notifications", ["Set Notification Time"])]
        //TODO: view in week, month
        //TODO: add note taking
        //TODO: add search, blcok numbers, class order

    }
    func showSchedule() {
        self.performSegue(withIdentifier: Constants.Segues.SettingsToSchedule, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == Constants.Segues.SettingsToSchedule {
                let scheduleVC = segue.destination as! ScheduleViewController
                if let hVC = self.navigationController?.viewControllers[0] as? HomeworkViewController {

                    let currentDateOfHVC = hVC.activitiesDay.date
                    scheduleVC.date = currentDateOfHVC
                    
                }
            }
        }
    }
}
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
	// MARK: TableView Data Source
	func numberOfSections(in tableView: UITableView) -> Int {
		return settingsList.count
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
		let titleView = UITextView(frame: headerView.frame)
		titleView.text = settingsList[section].category
		titleView.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
		let gradient: CAGradientLayer = CAGradientLayer.init(layer: titleView)
		gradient.frame = headerView.bounds
		gradient.colors = [(UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.00).cgColor as AnyObject), (UIColor(red: 0.82, green: 0.82, blue: 0.85, alpha: 1.00).cgColor as AnyObject)]
		titleView.layer.insertSublayer(gradient, at: 0)
		
		headerView.addSubview(titleView)
		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return settingsList[section].category
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingsList[section].list.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
		//TODO: change cells to constants
        let setting = settingsList[indexPath.section].list[indexPath.row]
		cell.textLabel?.text = setting.title
        cell.action = setting.action
		cell.backgroundColor = UIColor(colorLiteralRed: 230/256, green: 230/256, blue: 230/256, alpha: 1)
		return cell
	}
	
}
