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
        clearNotifs()
    }
    static func clearUserCache(sender: UIViewController) {
        clearDays()
        clearNotifs()
        ErrorHandling.displayAlert("Cache Cleared!", desc: "", sender: sender, completion: nil)
    }
    static func clearDays() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(DAYS_KEY)
    }
    static func clearNotifs() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    static func clearLogin() {
        sharedInstance.MyKeychainWrapper.mySetObject("password", forKey: kSecValueData)
        sharedInstance.MyKeychainWrapper.writeToKeychain()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "hasLoginKey")
    }
    static func retrieveLogin() -> Credentials?
    {
        if let username = NSUserDefaults.standardUserDefaults().stringForKey("username"), let pass = sharedInstance.MyKeychainWrapper.myObjectForKey(kSecValueData) as? String
        {
            return (username, pass)
        }

        else {
            return nil
        }
    }
    static func storeLogin(login: Credentials) {
        storeLogin(login.username, password: login.password)
    }
    static func storeLogin(username: String, password: String) {
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey") {//TODO: beware, will not overwrite
            NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
        }

        sharedInstance.MyKeychainWrapper.mySetObject(password, forKey: kSecValueData)
        sharedInstance.MyKeychainWrapper.writeToKeychain()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    func hasDays() -> Bool {
        return NSUserDefaults.standardUserDefaults().dictionaryForKey(DAYS_KEY) != nil
    }
    func addDay(day: Day?) {

        if let day = day {
            // persist a representation of this todo item in NSUserDefaults
            var todoDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(DAYS_KEY) ?? Dictionary() // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
            todoDictionary[day.date.asSlashedDate()] = day.activitiesArray // store NSData representation of todo item in dictionary with UUID as key
            NSUserDefaults.standardUserDefaults().setObject(todoDictionary, forKey: DAYS_KEY) // save/overwrite todo item list

            // create a corresponding local notification
            let notification = UILocalNotification()
            notification.alertBody = "Homework for \(day.date.asSlashedDate()):\n\(day.activitiesDescription)" // text that will be displayed in the notification
            notification.alertAction = "view" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = Day(date: NSDate()).date // todo item due date (when notification will be fired)
            //TODO: set notif time with input time
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["slashedDate": day.date.asSlashedDate()] // assign a unique identifier to the notification so that we can retrieve it later

            //TODO: notifs
            //			UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    func retrieveDay(date: NSDate) -> Day? {
        let todoDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(DAYS_KEY) as? [String:[[String]]] ?? [:]
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
}
