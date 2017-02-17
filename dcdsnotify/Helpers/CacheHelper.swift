//
//  CacheHelper.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/27/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import UIKit
class CacheHelper {
    static let sharedInstance = CacheHelper()
    let MyKeychainWrapper = KeychainWrapper()
       static func clearAll() {
        clearDays()
        clearLogin()
        clearLogs()
        clearNotifs()
    }
    static func clearUserCache(_ sender: UIViewController) {
        clearDays()
        clearNotifs()
        ErrorHandling.displayAlert("Cache Cleared!", desc: "", sender: sender, completion: nil)
    }


    static func clearNotifs() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
}
//MARK: crash log (html storage)
extension CacheHelper {
    static func clearLogs() {
        UserDefaults.standard.removeObject(forKey: LOGS_KEY)
    }
    func hasLogs() -> Bool {
        return UserDefaults.standard.dictionary(forKey: LOGS_KEY) != nil
    }
    func retrieveLogDates() -> [Date]? {
        if hasLogs()
        {
            var dates: [Date] = []
            let dateDict = UserDefaults.standard.dictionary(forKey: LOGS_KEY)
            
                for key in dateDict!.keys 
                {
                    if let dateK = Date.dateFormatterSlashed().date(from: key) {
                        dates.append(dateK)
                    }
                }
                return dates
            
            
        }
        return nil
    }
    func addLog(log: HTMLLog?) {
        
        if let log = log {
            var todoDictionary = UserDefaults.standard.dictionary(forKey: LOGS_KEY) ?? Dictionary()
            todoDictionary[log.date.asSlashedDate()] = log.htmlData
            UserDefaults.standard.set(todoDictionary, forKey: LOGS_KEY) // save/overwrite todo item list
            }
    }
    func retrieveLog(date: Date) -> HTMLLog? {
        let todoDictionary = UserDefaults.standard.dictionary(forKey: LOGS_KEY) as? [String:String] ?? [:]
        if let log: String = todoDictionary[date.asSlashedDate()] {
                return HTMLLog(date: date, log: log)
        	}
        else {
            return nil
        }
    }
    func retrieveAllLogs() -> [HTMLLog]? {
        if let dates = retrieveLogDates()
        {
            var logs: [HTMLLog] = []
            for date in dates {
                if let log = retrieveLog(date: date)
                {
                    logs.append(log)
                }
            }
            return logs
        }
        return nil
    }

}
//MARK: Login storage
extension CacheHelper {
    static func clearLogin() {
        sharedInstance.MyKeychainWrapper.mySetObject("password", forKey: kSecValueData)
        sharedInstance.MyKeychainWrapper.writeToKeychain()
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.set(false, forKey: "hasLoginKey")
    }
    func retrieveLogin() -> Credentials?
    {
        if let username = UserDefaults.standard.string(forKey: "username"), let pass = MyKeychainWrapper.myObject(forKey: kSecValueData) as? String
        {
            return (username, pass)
        }

        else {
            return nil
        }
    }
    func storeLogin(_ login: Credentials) {
        storeLogin(login.username, password: login.password)
    }
    func storeLogin(_ username: String, password: String) {
        if !UserDefaults.standard.bool(forKey: "hasLoginKey") {//TODO: beware, will not overwrite
            UserDefaults.standard.setValue(username, forKey: "username")
        }

        MyKeychainWrapper.mySetObject(password, forKey: kSecValueData)
        MyKeychainWrapper.writeToKeychain()
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
        UserDefaults.standard.synchronize()
    }
}
//MARK: days storage
extension CacheHelper {
    static func clearDays() {
        UserDefaults.standard.removeObject(forKey: DAYS_KEY)
    }
    func hasDays() -> Bool {
        return UserDefaults.standard.dictionary(forKey: DAYS_KEY) != nil
    }

    func addDay(_ day: Day?) {

        if let day = day {
            // persist a representation of this todo item in NSUserDefaults
            var todoDictionary = UserDefaults.standard.dictionary(forKey: DAYS_KEY) ?? Dictionary() // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
            todoDictionary[day.date.asSlashedDate()] = day.activitiesArray // store NSData representation of todo item in dictionary with UUID as key

            UserDefaults.standard.set(todoDictionary, forKey: DAYS_KEY) 

          let notification = UILocalNotification()
            notification.alertBody = "Homework for \(day.date.asSlashedDate()):\n\(day.activitiesDescription)" // text that will be displayed in the notification
            notification.alertAction = "view" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = Day(date: Date()).date // todo item due date (when notification will be fired)
            //TODO: set notif time with input time
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["slashedDate": day.date.asSlashedDate()] // assign a unique identifier to the notification so that we can retrieve it later
            //TODO: notifs
            //			UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    func retrieveDay(_ date: Date) -> Day? {
        let todoDictionary = UserDefaults.standard.dictionary(forKey: DAYS_KEY) as? [String:[[String]]] ?? [:]
        //		let keys = Array(todoDictionary.keys)
        if let dayString = todoDictionary[date.asSlashedDate()] {
            var activities: [Activity] = []
            for values in dayString {
                activities.append(Activity(fromValues: values))
            }
            return Day(activities: activities, date: date)
        }
        else {
            return nil
        }
    }
    //TODO: remove date from hwschedule
    //    static func storeSchedule(schedule: [DaySchedule]) {
    //
    //    }
    //
    //    static func storeDaySchedule(daySchedule: DaySchedule) {
    //
    //        var scheduleDict = UserDefaults.standard.dictionaryForKey(SCHEDULE_KEY) ?? Dictionary()
    //        if let day = daySchedule.date {
    //            let dayDict: [Block] = daySchedule.blocks
    //
    //
    //            scheduleDict[day.asSlashedDate()] = dayDict as? AnyObject
    //        }
    //        UserDefaults.standard.synchronize()
    //
    //    }
    //    static func retrieveSchedule(forDay: NSDate) -> DaySchedule?
    //    {
    //        let scheduleDict = UserDefaults.standard.dictionaryForKey(SCHEDULE_KEY) ?? [:]
    //        if let dayString = scheduleDict[forDay.asSlashedDate()] as? [[String]] {
    //            var activities: [Activity] = []
    //            for values in dayString {
    //                activities.append(Activity(fromValues: values))
    //            }
    //            return Day(activities: activities, date: forDay)
    //        }
    //
    //        else {
    //            return nil
    //        }
    //    }

}
