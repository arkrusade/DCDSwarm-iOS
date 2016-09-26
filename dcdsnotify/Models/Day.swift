//
//  Day.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
class Day: CustomStringConvertible {
	var activities: [Activity]? = nil
	let date: NSDate!
	
//	var slashedDate: String {
//		get {
//			return NSDate.dateFormatterSlashed().stringFromDate(date)
//		}
//	}
	
	init(date: NSDate?)
	{
		if let date = date {
			let calendar = NSCalendar.currentCalendar()
			calendar.locale = NSLocale.currentLocale()
			let components = calendar.components([.Month, .Day, .Year], fromDate: date)
			let currComponents = calendar.components([.Hour, .Minute, .Second], fromDate: NSDate())
//			components.setValue(23, forComponent: .Hour)
//			components.setValue(35, forComponent: .Minute)
//			components.setValue(0, forComponent: .Second)
			//TODO: update with preferred notif time
			components.setValue(currComponents.hour, forComponent: .Hour)
			components.setValue(currComponents.minute + 1, forComponent: .Minute)
			components.setValue(currComponents.second, forComponent: .Second)

			self.date = calendar.dateFromComponents(components)
		}
		else
		{
			self.date = date!
		}
	}
	convenience init(activities: [Activity]?, date: NSDate?)
	{
		self.init(date: date)
		if let activities = activities {
			self.activities = activities
		}
		
	}
	var activitiesDescription: String {
		get {
			var combinedTitles = ""
			for act in (activities ?? []) {
				combinedTitles += act.title + ": \(act.subtitle)"
				//TODO: make clean
			}
			return combinedTitles
		}
	}
	var activitiesArray: [[String]] {
		get {
			var arrayOfActivities: [[String]] = []
			for act in (activities ?? []) {
				arrayOfActivities.append(act.values)
			}
			return arrayOfActivities
		}
	}
	
	var description: String {
		get {
			return "date: \(date.descriptionWithLocale(NSLocale.currentLocale()))\nactivities: \(activities?.description ?? "")"
		}
	}
	
	static func emptyDay(date: NSDate) -> Day
	{
		return Day(activities: [Activity(classString: "", title: "There are no events to display", subtitle: "")], date: date)
	}
}
