//
//  CalendarHelper.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation

class CalendarHelper {
	static func processCalendarString(htmlString: NSString) -> Day
		//TODO: add param for diff calendar lengths
	{
		//MARK: set date
		let emptyStart = "<li class=\"listempty\">"
		let emptyEnd = "</li>"
		
		let dayStart = "thisDate: {ts '"
		let dayEnd = "'} start:"
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = dateFormatter.dateFromString(try! htmlString.cropExclusive(dayStart, end: dayEnd) ?? "") ?? NSDate()

		//MARK: check for empty day
		guard (try? htmlString.crop(emptyStart, end: emptyEnd)) == nil else{
						//TODO: remove hotfix
			let emptyDay = Day.emptyDay(date)
			return emptyDay
		}
		
		/*
		NOTE: caldata divides months
		nothing divides weeks
		every day divided by class="listcap"
		every class divided by eventobj
		
		
		<ul class="eventobj calendar3160" id="event_521366_591468">
		^
		this number
		applies to end of this link:
		https://www.dcds.edu/page.cfm?p=
		to get group page
		*/
		
		
		//MARK: Day divider
		
		let dayStartString = "<span class=\"listcap"
		let dayEndString = "</div>"//TODO: will not work on week or greater periods
		var dayString = try? htmlString.cropExclusive(dayStartString, end: dayEndString).cropExclusive(">")
		
		let tempDay = Day(date: date)
		tempDay.activities = []
		
		
		
		//MARK: Activity Divider
		let activityStartString = "<ul class=\"eventobj calendar"
		let activityEndString = "<!-- end eventobj -->"
		
		
		var currentActivity = try? dayString!.cropExclusive(activityStartString, end: activityEndString)//Gets single activity
		let classID = try? dayString!.cropEndExclusive("\\")//for calendar id of class
		let activityID = try? dayString!.cropExclusive("\"event_", end: "\\\"")//gets activity ID
		//TODO: use activity and class ID
		dayString = try? dayString!.cropExclusive(activityStartString)//removes currActivity by finding next one
		
		
		while let okActivity = currentActivity {
			
			
			var activityTitle = "Title not found"
			let activityClass: String
			var activityDesc = ""
			
			//MARK: parsing Title
			
			let activityString = try! okActivity.crop("etitle")
			if okActivity.hasPrefix("3659") {
				activityTitle = try! activityString.cropExclusive("\">", end: "/span")
				
				var tempClassString = activityTitle
				
				activityTitle = try! activityTitle.cropEndExclusive("(")
				if activityTitle.containsString("<br") {
					tempClassString = try! tempClassString.cropExclusive("<br").cropExclusive("(")
					activityTitle = try! activityTitle.cropEndExclusive("<")
					
				}
				
				activityClass = try! tempClassString.cropExclusive("(", end: ")<")
				
			}
				
				//			else if okActivity.hasPrefix("4790") {
				//				activityTitle = try! activityString.cropExclusive("</span>")
				//				activityClass = try! activityTitle.cropEnd(":")
				//				activityTitle = try! activityTitle.cropExclusive(": ")
				//			}
			else if (okActivity.hasPrefix("3500")) {
				activityTitle = try! activityString.cropExclusive("title=").cropExclusive(">", end: "</span")
				activityClass = try! activityTitle.cropEnd(":")
				activityTitle = try! activityTitle.cropExclusive(": ")
			}
			else {
				//linked
				if okActivity.containsString("title=\"Click here for event details\">") {
					activityTitle = try! activityString.cropExclusive("title=\"Click here for event details\">", end: "</span>")//removes beginning crap in activity
					
					//separates class name from activity title
					var tempClass = try! activityTitle.cropEnd("):")
					tempClass.removeAtIndex(tempClass.endIndex.predecessor())
					activityClass = tempClass
					activityTitle = try! activityTitle.cropExclusive("): ", end: "</")
					
					if activityTitle.containsString("<br") {
						activityTitle = try! activityTitle.cropEndExclusive("<br")
					}
				}
					
					//not linked
				else if okActivity.containsString("<span class=\"eventcon\">")//find event content
				{
					let tempActivity = try! okActivity.cropExclusive("id=\"e_")
					let activityID = try! tempActivity.cropEndExclusive("\">")
					//TODO: organize activities by class and use id
					activityClass = try! (tempActivity.cropExclusive("\">", end: "): ") + ")" ?? "Failed Activity")
					activityTitle = try! (tempActivity.cropExclusive("): ", end: "</span>") ?? "Failed Title")
					
					
					if activityTitle.containsString("<br") {
						activityTitle = try! activityTitle.cropEndExclusive("<br")
					}
					
				}
				else {
					activityClass = "Could not find activity"
				}
				
			}
			
			//MARK: parsing Desc
			var activityDescData = try! activityString.cropExclusive("</span>")
			while(activityDescData.containsString("<span")) {
				activityDescData = try! activityDescData.cropExclusive("<span")
				activityDescData = try! activityDescData.cropExclusive(">", end: "</span") as String
				
				if activityDescData.containsString("<") && activityDescData.containsString(">"){//if carats found
					//find carats and make range
					let startIndex = activityDescData.rangeOfString("<")!.startIndex
					let endIndex = activityDescData.rangeOfString(">")!.endIndex
					let asdf = startIndex..<endIndex
					//assert break in carats
					guard activityDescData.substringWithRange(asdf).containsString("br") || activityDescData.substringWithRange(asdf).containsString("BR") else {
						print("carats found, but no break")
						break
					}
					//bye carats
					activityDescData.removeRange(asdf)
					//replace with newline
					//					activityDescData.insertContentsOf("\n".characters, at: startIndex)
				}
				activityDesc += (activityDescData) + "\n"
			}
			
			tempDay.activities!.append(Activity(classString: activityClass, title: activityTitle, subtitle: activityDesc))
			
			//while loop logic
			//gets the next activity
			currentActivity = try? (dayString!.cropExclusive(activityStartString, end: activityEndString))
			dayString = try? dayString!.cropExclusive(activityStartString)
			
			
		}
		
		return tempDay
	}
}

