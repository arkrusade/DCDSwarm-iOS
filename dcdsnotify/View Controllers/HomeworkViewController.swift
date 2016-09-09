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
	var currentDay: NSDate!
	//TODO: separate activities from date
	var activitiesDay: Day? {
		didSet {
			titleBar.title = NSDate.dateFormatterSlashedAndDay().stringFromDate(activitiesDay!.date)
			if self.isViewLoaded() && activitiesDay?.activities != nil {
				NSOperationQueue.mainQueue().addOperationWithBlock {
					self.tableView.reloadData()
				}
			}
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		configureNavigationBar()
		configureButtons()
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
		self.activitiesDay = Day(date: NSDate())
		
		//TODO: is this right??
		// Dispose of any resources that can be recreated.
	}
	
	func nextPeriod(sender: AnyObject?) {
		let tomorrow = activitiesDay?.date.tomorrow()
		activitiesDay = Day(date: tomorrow)
		loadActivities()
	}
	
	func prevPeriod(sender: AnyObject?) {
		let yesterday = activitiesDay?.date.yesterday()
		activitiesDay = Day(date: yesterday)
		loadActivities()
	}
	
	func goToToday(sender: AnyObject?) {
		let today = NSDate()
		activitiesDay = Day(date: today)
		loadActivities()
	}
	func goToSettings(sender: AnyObject?){
//		self.performSegueWithIdentifier(Constants.Segues.HomeworkToSettings, sender: self)
		self.performSegueWithIdentifier("Temp", sender: self)
	}
	
	func configureButtons() {
		self.view.bringSubviewToFront(yesterdayButton)
		self.view.bringSubviewToFront(tomorrowButton)
		let left = Constants.Images.leftCarat.alpha(0.5)
		yesterdayButton.setBackgroundImage(left, forState: .Normal)
		let right = Constants.Images.rightCarat.alpha(0.5)
		tomorrowButton.setBackgroundImage(right, forState: .Normal)
		yesterdayButton.addTarget(self, action: #selector(prevPeriod(_:)), forControlEvents: .TouchUpInside)
		tomorrowButton.addTarget(self, action: #selector(nextPeriod(_:)), forControlEvents: .TouchUpInside)
	}
	func configureNavigationBar()
	{
		
		let settingsButton = UIBarButtonItem(image: Constants.Images.settings, style: .Plain, target: self, action: #selector(goToSettings(_: )))
		self.navigationItem.rightBarButtonItem = settingsButton
		
		let todayButton = UIBarButtonItem(title: "Today", style: .Plain, target: self, action: #selector(goToToday(_: )))
		self.navigationItem.leftBarButtonItem = todayButton
		
		topConstraint.constant = -(self.navigationController?.navigationBar.frame.height)! - UIApplication.sharedApplication().statusBarFrame.size.height

	}
	
	func loadActivities() {
		activityIndicator.stopAnimating()

		if let day = CacheHelper.sharedInstance.retrieveDay(activitiesDay?.date ?? NSDate())//if in cache, use that; else, clear the day to show activity loader
		{
			self.activitiesDay = day
		}
		else {
			self.activitiesDay?.activities = nil
			tableView.reloadData()
		}
		//TODO: also send request after some refresh button
		
		//			self.currentDay = Day.emptyDay(NSDate()
		let homeworkURL = (activitiesDay?.date ?? NSDate()).toDCDSURL()
		portalTask?.cancel()
		portalTask = NSURLSession.sharedSession().dataTaskWithURL(homeworkURL!, completionHandler: { (data, response, error) -> Void in
			self.activityIndicator.stopAnimating()
			guard error?.code != -999 else {
				//cancelled task
				return
			}
			guard error == nil && data != nil else {                                                          // check for fundamental networking error
				print("\(error)")
				ErrorHandling.defaultErrorHandler("Network Error", desc: (error?.localizedDescription)!)
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
			if !PortalHelper.checkLoggedIn(urlContent as String) {
				let login = CacheHelper.retrieveLogin()
				guard login.username != nil else {
					return
				}
				let request = NSMutableURLRequest(URL: Constants.userLoginURL)
				request.HTTPMethod = "POST"
				let postString = "do=login&p=413&username=\(login.username!)&password=\(login.password!)&submit=login"
				request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
				let checkLoginTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
					
					
					guard error == nil && data != nil else {// check for fundamental networking error
						print("error=\(error)")
						
						ErrorHandling.defaultErrorHandler(error!)
						return
					}
					
					if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
						print("statusCode should be 200, but is \(httpStatus.statusCode)")
						print("response = \(response)")
						return
					}
					
					//MARK: Login Check
					
					let urlContentString = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
					let loginCheck = try? (urlContentString.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit"))
					guard loginCheck == "STUDENT PORTAL" else {
						//TODO: check for parents too
						NSOperationQueue.mainQueue().addOperationWithBlock {
							print("Failed Login")
//							ErrorHandling.defaultErrorHandler("Invalid Username/Password", desc: "Please enter a valid username and password combination")
							//TODO: should signout here
							
						}
						return
					}
					
					
				}
				checkLoginTask.resume()
			}
			self.activitiesDay = CalendarHelper.processCalendarString(urlContent)
			self.lastLoaded = NSDate() //TODO: make this didSet of currentDay?
			CacheHelper.sharedInstance.addDay(self.activitiesDay)
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
				prevPeriod(self)
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

