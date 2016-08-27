//
//  Day.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
class Day: CustomStringConvertible {
	var activities: [Activity]? = nil
	let date: NSDate!
	init(date: NSDate?)
	{
		if let date = date {
			let calendar = NSCalendar.currentCalendar()
			let components = calendar.components(.Hour, fromDate: date)
			components.setValue(15, forComponent: .Hour)
			components.setValue(40, forComponent: .Minute)
			components.setValue(0, forComponent: .Second)
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
	
	var description: String {
		get {
			return "date: \(date.description)\nactivities: \(activities?.description ?? "")"
		}
	}
}