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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var settingsList: [SettingsCategory]! = nil
    //TODO: set current date action

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var titleBar: UINavigationItem!
	
	
	override func viewDidLoad() {
        configureSettingsList()
		titleBar.title = "Settings"
        topConstraint.constant = -(self.navigationController?.navigationBar.frame.height)! - UIApplication.sharedApplication().statusBarFrame.size.height
	}

    func configureSettingsList() {
        let logoutClosure: ClosureVoid = {() -> Void in
            AppState.sharedInstance.logout(self)
        }
        let clearCacheClosure: ClosureVoid = {ClosureVoid in
            CacheHelper.clearUserCache()
        }

        let userCategory: SettingsCategory
        let clearCacheSetting: SettingsAction = ("Clear Cache", clearCacheClosure
        )
        let logoutAction: SettingsAction = ("Logout", logoutClosure)
        userCategory.category = "User Settings"
        userCategory.list = [clearCacheSetting, logoutAction]

        settingsList = [userCategory]
        //,("Notifications", ["Set Notification Time"])]


    }
	// MARK: TableView Data Source
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return settingsList.count
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
		let titleView = UITextView(frame: headerView.frame)
		titleView.text = settingsList[section].category
		titleView.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
		let gradient: CAGradientLayer = CAGradientLayer.init(layer: titleView)
		gradient.frame = headerView.bounds
		gradient.colors = [(UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.00).CGColor as AnyObject), (UIColor(red: 0.82, green: 0.82, blue: 0.85, alpha: 1.00).CGColor as AnyObject)]
		titleView.layer.insertSublayer(gradient, atIndex: 0)
		
		headerView.addSubview(titleView)
		return headerView
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return settingsList[section].category
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingsList[section].list.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! SettingsCell
		//TODO: change cells to constants
		cell.textLabel?.text = settingsList[indexPath.section].list[indexPath.row].title
        
		cell.backgroundColor = UIColor(colorLiteralRed: 230/256, green: 230/256, blue: 230/256, alpha: 1)
		return cell
	}
	
}
