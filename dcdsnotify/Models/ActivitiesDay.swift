//
//  ActivitiesDay.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
class ActivitiesDay: CustomStringConvertible {
    var list: [Activity]? = nil
    //	private let date: Date!
    //
    //
    //	init(date: Date?)
    //	{
    //		if let date = date {
    //			var calendar = Calendar.current
    //			calendar.locale = Locale.current
    //			let components = (calendar as NSCalendar).components([.month, .day, .year], from: date)
    //			let currComponents = (calendar as NSCalendar).components([.hour, .minute, .second], from: Date())
    ////			components.setValue(23, forComponent: .Hour)
    ////			components.setValue(35, forComponent: .Minute)
    ////			components.setValue(0, forComponent: .Second)
    //			//TODO: update with preferred notif time
    //			(components as NSDateComponents).setValue(currComponents.hour!, forComponent: .hour)
    //			(components as NSDateComponents).setValue(currComponents.minute! + 1, forComponent: .minute)
    //			(components as NSDateComponents).setValue(currComponents.second!, forComponent: .second)
    //
    //			self.date = calendar.date(from: components)
    //		}
    //		else
    //		{
    //			self.date = date!
    //		}
    //	}
    //	convenience init(activities: [Activity]?, date: Date?)
    init(list: [Activity]?)
    {
        if let activities = list {
            self.list = activities
        }
        
    }
    var activitiesDescription: String {
        get {
            var combinedTitles = ""
            for act in (list ?? []) {
                combinedTitles += act.title + ": \(act.subtitle)"
                //TODO: make clean
            }
            return combinedTitles
        }
    }
    var activitiesArray: [[String]] {
        get {
            var arrayOfActivities: [[String]] = []
            for act in (list ?? []) {
                arrayOfActivities.append(act.values)
            }
            return arrayOfActivities
        }
    }
    
    var description: String {
        get {
            return /*"date: \(date.description(with: Locale.current))\n*/"activities: \(list?.description ?? "")"
        }
    }
    
    static func emptyDay() -> ActivitiesDay
    {
        return ActivitiesDay(list: [Activity(classString: "", title: "There are no events to display", subtitle: "")])
    }
}
