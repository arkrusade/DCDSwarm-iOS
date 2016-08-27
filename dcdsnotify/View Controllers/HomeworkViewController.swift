//
//  ViewController.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/21/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Foundation

class HomeworkViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var titleBar: UINavigationItem!
	
	var currentDay: Day? {
		didSet {
			titleBar.title = NSDate.dateFormatterSlashedAndDay().stringFromDate(currentDay!.date)
//			if tableView != nil {
//				tableView.reloadSections()
//			}
		}
	}
	
	
		override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
			self.currentDay = nil
			//TODO: is this right??
		// Dispose of any resources that can be recreated.
	}
	
	func nextPeriod(sender: AnyObject?) {
		let tomorrow = currentDay?.date.tomorrow()
		currentDay = Day(date: tomorrow)
		loadActivities()
	}
	
	func prevPeriod(sender: AnyObject?) {
		let yesterday = currentDay?.date.yesterday()
		currentDay = Day(date: yesterday)
		loadActivities()
	}
	
	func configureNavigation()
	{
		let nextPeriodItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(nextPeriod(_: )))
		let prevPeriodItem = UIBarButtonItem(title: "Previous", style: .Plain, target: self, action: #selector(prevPeriod(_: )))
		//TODO: settings
		self.navigationItem.rightBarButtonItem = nextPeriodItem
		self.navigationItem.leftBarButtonItem = prevPeriodItem

	}
	
	func loadActivities() {
		self.tableView.reloadData()
		let homeworkURL = (currentDay?.date ?? NSDate()).toDCDSURL()
		let atask = NSURLSession.sharedSession().dataTaskWithURL(homeworkURL!, completionHandler: { (data, response, error) -> Void in
			
			guard error == nil && data != nil else {                                                          // check for fundamental networking error
				print("\(error)")
				ErrorHandling.defaultErrorHandler((error?.description)!)
				return
			}
			
			if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				if httpStatus.statusCode == 404 || httpStatus.statusCode == 403 {
					return
				}
				print("response = \(response)")
			}
			
			let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
			
			self.currentDay = CalendarHelper.processCalendarStringDay(urlContent)
			self.tableView.reloadData()
			
		})
		atask.resume()
	}

	override func viewDidLoad() {
		
		configureNavigation()
		loadActivities()
	}
}
