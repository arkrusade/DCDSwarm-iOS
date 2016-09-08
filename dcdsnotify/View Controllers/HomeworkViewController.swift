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
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var titleBar: UINavigationItem!
	@IBOutlet weak var yesterdayButton: UIButton!
	@IBOutlet weak var tomorrowButton: UIButton!
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	
	var portalTask: NSURLSessionDataTask?
	var lastLoaded: NSDate?
	var tomorrow: HomeworkViewController!
	var yesterday: HomeworkViewController?
	
	var currentDay: Day? {
		didSet {
			titleBar.title = NSDate.dateFormatterSlashedAndDay().stringFromDate(currentDay!.date)
			if self.isViewLoaded() && currentDay?.activities != nil {
				NSOperationQueue.mainQueue().addOperationWithBlock {
					self.tableView.reloadData()
				}
			}
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		configureNavigationBar()
		
		self.view.bringSubviewToFront(yesterdayButton)
		self.view.bringSubviewToFront(tomorrowButton)
		
		activityIndicator.hidesWhenStopped = true
		activityIndicator.stopAnimating()
		loadActivities()
		self.tableView.reloadData()
		
		
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(HomeworkViewController.respondToSwipeGesture(_:)))
		swipeRight.direction = .Right
		self.view.addGestureRecognizer(swipeRight)
		
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(HomeworkViewController.respondToSwipeGesture(_:)))
		swipeLeft.direction = .Left
		self.view.addGestureRecognizer(swipeLeft)
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		self.currentDay = Day(date: NSDate())
		
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
	
	func configureNavigationBar()
	{
		let nextPeriodItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(nextPeriod(_: )))
		let prevPeriodItem = UIBarButtonItem(title: "Previous", style: .Plain, target: self, action: #selector(prevPeriod(_: )))
		//TODO: settings
		
		yesterdayButton.addTarget(self, action: #selector(prevPeriod(_: )), forControlEvents: .TouchUpInside)
		tomorrowButton.addTarget(self, action: #selector(nextPeriod(_: )), forControlEvents: .TouchUpInside)

		self.navigationItem.rightBarButtonItem = nextPeriodItem
		self.navigationItem.leftBarButtonItem = prevPeriodItem
		topConstraint.constant = -(self.navigationController?.navigationBar.frame.height)! - UIApplication.sharedApplication().statusBarFrame.size.height

	}
	
	func loadActivities() {
		activityIndicator.stopAnimating()

		if let day = CacheHelper.sharedInstance.retrieveDay(currentDay?.date ?? NSDate())//if in cache, use that; else, clear the day to show activity loader
		{
			self.currentDay = day
		}
		else {
			self.currentDay?.activities = nil
			tableView.reloadData()
		}
		//TODO: also send request after some refresh button
		
		//			self.currentDay = Day.emptyDay(NSDate()
		let homeworkURL = (currentDay?.date ?? NSDate()).toDCDSURL()
		portalTask = NSURLSession.sharedSession().dataTaskWithURL(homeworkURL!, completionHandler: { (data, response, error) -> Void in
			self.activityIndicator.stopAnimating()
			guard error == nil && data != nil else {                                                          // check for fundamental networking error
				print("\(error)")
				ErrorHandling.defaultErrorHandler("Network Error", desc: "No connection")
				return
			}
			
			if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				if httpStatus.statusCode == 404{
					NSOperationQueue.mainQueue().addOperationWithBlock {
						print("response = \(response)")
						ErrorHandling.defaultErrorHandler("Network Error", desc: "Page not found")
					}
					return
				}
				else if httpStatus.statusCode == 403 {
					NSOperationQueue.mainQueue().addOperationWithBlock {
						print("response = \(response)")
						ErrorHandling.defaultErrorHandler("Network Error", desc: "Unauthorized Access")
					}
					return
				}
			}
			
			let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
			
			self.currentDay = CalendarHelper.processCalendarStringDay(urlContent)
			//				self.tableView.reloadData()
			self.lastLoaded = NSDate() //TODO: make this didSet of currentDay?
			CacheHelper.sharedInstance.addDay(self.currentDay)
		})
		portalTask!.resume()
		
	}
	
	//TODO: maybe stuff
	/*
	search
	set due dates on calendar
	notifs
	
*/
	
	func respondToSwipeGesture(gesture: UIGestureRecognizer) {
		
		if let swipeGesture = gesture as? UISwipeGestureRecognizer {
			
			
			switch swipeGesture.direction {
			case UISwipeGestureRecognizerDirection.Right:
				print("Swiped right")
//				CacheHelper.clearDays()
				
				prevPeriod(self)
				
				tableView.reloadData()
			case UISwipeGestureRecognizerDirection.Down:
				print("Swiped down")
			case UISwipeGestureRecognizerDirection.Left:
				print("Swiped left")
				nextPeriod(self)
//				let toViewController = yesterday
//				let fromViewController = self
//				
//				let containerView = fromViewController.view.superview
//				let screenBounds = UIScreen.mainScreen().bounds
//				
//				let finalToFrame = screenBounds
//				let finalFromFrame = CGRectOffset(finalToFrame, 0, screenBounds.size.height)
//				toViewController!.loadView()
//				toViewController!.view.frame = CGRectOffset(finalToFrame, 0, -screenBounds.size.height)
//				containerView?.addSubview(toViewController!.view)
//				
//				UIView.animateWithDuration(0.5, animations: {
//					toViewController!.view.frame = finalToFrame
//					fromViewController.view.frame = finalFromFrame
//				})
				
				
			case UISwipeGestureRecognizerDirection.Up:
				print("Swiped up")
			default:
				break
			}
		}
		
	}
}

