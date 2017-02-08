//
//  HVCInternetExtension.swift
//  dcdsnotify
//
//  Created by Justin Lee on 10/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
extension HomeworkViewController {
    func loadActivities() {
        if !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
        //while loading, if in cache, use that; else, clear the day to show activity loader
        if let day = CacheHelper.sharedInstance.retrieveDay(activitiesDay?.date ?? Date()) {
            self.activitiesDay = day
        }
        //until task is finished, inserts this before everything else
        let loadingActivity = Activity(classString: "", title: "Loading", subtitle: "")
        self.activitiesDay?.activities?.insert(loadingActivity, at: 0)
        tableView.reloadData()

        //TODO: also send request after some refresh button

        let homeworkURL = (activitiesDay?.date ?? Date()).toDCDSURL()
        portalTask?.cancel()
        portalTask = URLSession.shared.dataTask(with: homeworkURL!, completionHandler: { (data, response, error) -> Void in
            OperationQueue.main.addOperation() {
                self.activityIndicator.stopAnimating()
            }
            if let urlContent = PortalHelper.checkResponse(data, response: response, error: error as NSError?, sender: self)
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
                    let checkLogin = CacheHelper.sharedInstance.retrieveLogin()

                    //logged in without a cached login
                    guard checkLogin != nil else {

                        AppState.sharedInstance.logout(self)
                        return
                    }

                    //else continue logging in; make url request
                    let login = checkLogin!
                    var request = URLRequest(url: Constants.userLoginURL)
                    request.httpMethod = "POST"
                    let postString = "do=login&p=413&username=\(login.username)&password=\(login.password)&submit=login"
                    request.httpBody = postString.data(using: String.Encoding.utf8)

                    //start task
                    let checkLoginTask = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error3: Error?) in
                        let error = error3 as? NSError
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
                        //everythings ok, so start again
                        OperationQueue.main.addOperation({
                            self.loadActivities()
                        })
                    }) 
                    checkLoginTask.resume()
                }
                else {
                    self.activitiesDay = CalendarHelper.processCalendarString(urlContent as NSString)
                    self.lastLoaded = Date() //TODO: make this didSet of currentDate? and also use this (15 minutes, then refresh automatically)
                    CacheHelper.sharedInstance.addDay(self.activitiesDay)
                }
            }
            
        })
        portalTask!.resume()
        
    }
}
