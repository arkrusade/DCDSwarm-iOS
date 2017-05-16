//
//  ViewController.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/21/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
class HomeworkViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var tomorrowButton: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadActivities), for: .valueChanged)
        
        return refreshControl
    }()
    
    var login: Credentials!
    
    var portalTask: URLSessionDataTask?
    var lastLoaded: Date?
    //TODO: separate activities from date
    var currentDate: Date {
        get {
            return AppState.sharedInstance.getDate()
        }
    }
    var activities: ActivitiesDay! {
        didSet {
            if self.isViewLoaded && activities.list != nil {
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeDate(currentDate)
        configureNavigationBar()
        configureArrowButtons()
        loadActivities()
        self.tableView.reloadData()
        
        configureRefresh()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(HomeworkViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(HomeworkViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.activities = ActivitiesDay.emptyDay()
        
        // Dispose of any resources that can be recreated.
    }
    
    func changeDate(_ date: Date?) {//asdf:
        if let date = date {
            titleBar.title = Date.dateFormatterSlashedAndDay().string(from: date)//TODO: shorten for iphone 5
            AppState.sharedInstance.changeDate(date: date)
            loadActivities()
        }
        
    }
    func nextPeriod(_ sender: AnyObject?) {
        let tomorrow = currentDate.tomorrow()
        changeDate(tomorrow)
    }
    
    func prevPeriod(_ sender: AnyObject?) {
        let yesterday = currentDate.yesterday()
        changeDate(yesterday)
    }
    
    func segueToDatePicker(_ sender: AnyObject?) {//TODO: make ids constants
        
        let pickerVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.Date) as! DatePickerViewController
        pickerVC.date = currentDate
        pickerVC.sendingVC = self
        self.navigationController?.pushViewController(pickerVC, animated: true)
        
    }
    
    func segueToSettings(_ sender: AnyObject?){
        self.performSegue(withIdentifier: Constants.Segues.HomeworkToSettings, sender: self)
    }
    
    func segueToSchedule(_ sender: AnyObject?) {
        let scheduleVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.Schedule) as! ScheduleViewController
        self.navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    
    
    func configureArrowButtons() {
        self.view.bringSubview(toFront: yesterdayButton)
        self.view.bringSubview(toFront: tomorrowButton)
        
        let left = Constants.Images.leftCarat.alpha(0.5)
        yesterdayButton.setBackgroundImage(left, for: UIControlState())
        let right = Constants.Images.rightCarat.alpha(0.5)
        tomorrowButton.setBackgroundImage(right, for: UIControlState())
        
        yesterdayButton.addTarget(self, action: #selector(prevPeriod(_:)), for: .touchUpInside)
        tomorrowButton.addTarget(self, action: #selector(nextPeriod(_:)), for: .touchUpInside)
    }
    func configureNavigationBar() {
        let settingsButton = UIBarButtonItem(image: Constants.Images.settings, style: .plain, target: self, action: #selector(segueToSettings(_: )))
        self.navigationItem.rightBarButtonItem = settingsButton
        
        let datePickerButton = UIBarButtonItem(image: Constants.Images.calendar, style: .plain, target: self, action: #selector(segueToDatePicker(_: )))
        
        
        self.navigationItem.rightBarButtonItems = [settingsButton, datePickerButton]
        
        let scheduleButton = UIBarButtonItem(title: "Blocks", style: .plain, target: self, action: #selector(segueToSchedule(_: )))
        
        self.navigationItem.leftBarButtonItem = scheduleButton
        
        
        topConstraint.constant = -(self.navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.size.height
    }
    
    
    
    //TODO: maybe stuff
    /*
     search hw
     filter by class
     set due dates on calendar
     notifs
     make notes or write text on block schedule
     */
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                prevPeriod(self)
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                nextPeriod(self)
                //				let toViewController = yesteractivitiesDay
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
                
                
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
        
    }
}

