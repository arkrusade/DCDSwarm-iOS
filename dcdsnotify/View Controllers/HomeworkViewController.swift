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
    //TODO: separate activities from date
    var currentDate: NSDate {
        get {
            return activitiesDay.date
        }
    }
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
        configureArrowButtons()
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

        //TODO: is this right?? p sure im supposed to separate NSDate from activities array, so that changing date from elsewhere is ez
        // Dispose of any resources that can be recreated.
    }

    func changeDate(date: NSDate?) {
        if date != nil{
            activitiesDay = Day(date: date)
            loadActivities()
        }
        
    }
    func nextPeriod(sender: AnyObject?) {
        let tomorrow = activitiesDay?.date.tomorrow()
        changeDate(tomorrow)
    }

    func prevPeriod(sender: AnyObject?) {
        let yesterday = activitiesDay?.date.yesterday()
        changeDate(yesterday)
    }

    func segueToDatePicker(sender: AnyObject?) {//TODO: make ids constants
        
        let pickerVC = self.storyboard?.instantiateViewControllerWithIdentifier("datePicker") as! DatePickerViewController
        pickerVC.date = currentDate
        pickerVC.sendingVC = self
        self.navigationController?.pushViewController(pickerVC, animated: true)
        
    }

    func segueToSettings(sender: AnyObject?){
        self.performSegueWithIdentifier(Constants.Segues.HomeworkToSettings, sender: self)
    }

    func segueToSchedule(sender: AnyObject?) {
        let scheduleVC = self.storyboard?.instantiateViewControllerWithIdentifier("schedule") as! ScheduleViewController
        scheduleVC.date = self.activitiesDay.date
        scheduleVC.daySchedule = ExcelHelper.sharedInstance.getSchedule(activitiesDay.date, sender: self)
        self.navigationController?.pushViewController(scheduleVC, animated: true)
    }



    func configureArrowButtons() {
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
        let settingsButton = UIBarButtonItem(image: Constants.Images.settings, style: .Plain, target: self, action: #selector(segueToSettings(_: )))
        self.navigationItem.rightBarButtonItem = settingsButton

        let datePickerButton = UIBarButtonItem(image: Constants.Images.calendar, style: .Plain, target: self, action: #selector(segueToDatePicker(_: )))


        self.navigationItem.rightBarButtonItems = [settingsButton, datePickerButton]
        
        let scheduleButton = UIBarButtonItem(title: "Blocks", style: .Plain, target: self, action: #selector(segueToSchedule(_: )))

        self.navigationItem.leftBarButtonItem = scheduleButton

        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.stopAnimating()

        topConstraint.constant = -(self.navigationController?.navigationBar.frame.height)! - UIApplication.sharedApplication().statusBarFrame.size.height
    }

    

    //TODO: maybe stuff
    /*
     search hw
     filter by class
     set due dates on calendar
     notifs
     make notes or write text on block schedule
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

