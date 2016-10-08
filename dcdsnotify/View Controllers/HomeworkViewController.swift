//
//  ViewController.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/21/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Foundation
struct DaySchedule {
    var date: NSDate?
    var blocks: [Block]
    init() {
        blocks = []
    }
}
typealias Block = (name: String, time: String)
class HomeworkViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var tomorrowButton: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    var portalTask: NSURLSessionDataTask?
    var lastLoaded: NSDate?
    var currentDay: NSDate!
    //TODO: separate activities from date
    var activitiesDay: Day! {
        didSet {
            titleBar.title = NSDate.dateFormatterSlashedAndDay().stringFromDate(activitiesDay.date)
            if self.isViewLoaded() && activitiesDay.activities != nil {
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
//        let locale = NSLocale.currentLocale()
        //TODO: use this
        activitiesDay = Day(date: today)
        loadActivities()
    }
    func goToSettings(sender: AnyObject?){
        self.performSegueWithIdentifier(Constants.Segues.HomeworkToSettings, sender: self)
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
    func configureNavigationBar() {
        let settingsButton = UIBarButtonItem(image: Constants.Images.settings, style: .Plain, target: self, action: #selector(goToSettings(_: )))
        self.navigationItem.rightBarButtonItem = settingsButton

        let todayButton = UIBarButtonItem(title: "Today", style: .Plain, target: self, action: #selector(goToToday(_: )))
        self.navigationItem.leftBarButtonItem = todayButton

        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.stopAnimating()

        topConstraint.constant = -(self.navigationController?.navigationBar.frame.height)! - UIApplication.sharedApplication().statusBarFrame.size.height
    }

    func loadActivities() {
        if !activityIndicator.isAnimating() {
            activityIndicator.startAnimating()
        }
        //while loading, if in cache, use that; else, clear the day to show activity loader
        if let day = CacheHelper.sharedInstance.retrieveDay(activitiesDay?.date ?? NSDate()) {
            self.activitiesDay = day
        }
        //until task is finished, inserts this before everything else
        let loadingActivity = Activity(classString: "", title: "Loading", subtitle: "")
        self.activitiesDay?.activities?.insert(loadingActivity, atIndex: 0)
        tableView.reloadData()

        //TODO: also send request after some refresh button

        let homeworkURL = (activitiesDay?.date ?? NSDate()).toDCDSURL()
        portalTask?.cancel()
        portalTask = NSURLSession.sharedSession().dataTaskWithURL(homeworkURL!, completionHandler: { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.activityIndicator.stopAnimating()
            }
            if let urlContent = PortalHelper.checkResponse(data, response: response, error: error, sender: self)
            {
                let isAPage = PortalHelper.checkLoggedIn(urlContent)
                guard isAPage != nil else{
                    print("unknown page")
                    ErrorHandling.defaultError("Network Error", desc: "Unknown webpage", sender: self)
                    return
                }
                let isProperPage = isAPage!
                //MARK: Login Checking
                //if login fails, expires, or otherwise goes to login page again
                if !isProperPage {

                    let loggingInActivity = Activity(classString: "", title: "Webpage timed out", subtitle: "Logging in again...")
                    self.activitiesDay?.activities = [loggingInActivity]
                    let checkLogin = CacheHelper.retrieveLogin()

                    //logged in without a cached login
                    guard checkLogin != nil else {

                        AppState.sharedInstance.logout(self)
                        return
                    }

                    //else continue logging in; make url request
                    let login = checkLogin!
                    let request = NSMutableURLRequest(URL: Constants.userLoginURL)
                    request.HTTPMethod = "POST"
                    let postString = "do=login&p=413&username=\(login.username)&password=\(login.password)&submit=login"
                    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

                    //start task
                    let checkLoginTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in

                        //check no errors
                        if let checkLoginString = PortalHelper.checkResponse(data, response: response, error: error, sender: self)
                        {
                            //check right page
                            guard PortalHelper.checkLoggedIn(checkLoginString) == true else {
                                print("Failed Login")
                                ErrorHandling.displayAlert("Invalid Username/Password", desc: "Stored login does not suceed", sender: self, completion: {() -> Void in
                                        AppState.sharedInstance.logout(self)
                                    return
                                })
                                return
                            }
                        }
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.loadActivities()
                        })
                    }
                    checkLoginTask.resume()
                }
                else {
                    self.activitiesDay = CalendarHelper.processCalendarString(urlContent)
                    self.lastLoaded = NSDate() //TODO: make this didSet of currentDay?
                    CacheHelper.sharedInstance.addDay(self.activitiesDay)
                }
            }
//            else {
//                if self.activitiesDay?.activities == nil {
//                    let errorActivity = Activity(classString: "Error", title: "No data", subtitle: "")
//                    self.activitiesDay?.activities = [errorActivity]
//
//                }
//            }
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

