//
//  CalendarHelper.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation

class CalendarHelper {
	static func processCalendarStringDay(htmlString: NSString) -> Day
	{
		
		let emptyStart = "<li class=\"listempty\">"
		let emptyEnd = "</li>"
		guard (try? htmlString.crop(emptyStart, end: emptyEnd)) == nil else{
			let dayStart = "thisDate: {ts '"
			let dayEnd = "'} start:"
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let date = dateFormatter.dateFromString(try! htmlString.cropExclusive(dayStart, end: dayEnd) ?? "") ?? NSDate()
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
		let dayStartString = "<span class=\"listcap\">"
		let dayEndString = "</div>"//TODO: will not work on week or greater periods
		var croppedDayString = try? htmlString.cropExclusive(dayStartString, end: dayEndString)
		
		
		var dateString: String = try! croppedDayString!.cropExclusive("\n", end: "\n") as String
		while dateString.hasPrefix("\t") {
			dateString = try! dateString.crop("\t")
		}
		let thisDate: NSDate? = NSDate.dateFormatterDashed().dateFromString(dateString)
		let tempDay = Day(date: thisDate)
		tempDay.activities = []
//		htmlString = htmlString.cropExclusive(dayStartString)
		//TODO: for use with parsing week
		
		
		//MARK: Activity Divider
		let activityStartString = "<ul class=\"eventobj "
		let activityEndString = "<!-- end eventobj -->"
		
		
		var croppedActivity = try? (croppedDayString!.cropExclusive(activityStartString, end: activityEndString))
		croppedDayString = try? croppedDayString!.cropExclusive(activityStartString)
		
		
		while let okActivity = croppedActivity {
			
			
			var activityTitle = "Title not found"
			let activityClass: String
			var activityDesc = ""

			//MARK: parsing Title

			let activityString = try! okActivity.crop("etitle")
			if okActivity.containsString("calendar3659") {
				activityTitle = try! activityString.cropExclusive("\">", end: "/span")
				
				var tempClassString = activityTitle
				
				activityTitle = try! activityTitle.cropEndExclusive("(")
				if activityTitle.containsString("<br") {
					tempClassString = try! tempClassString.cropExclusive("<br").cropExclusive("(")
					activityTitle = try! activityTitle.cropEndExclusive("<")

				}
				
				activityClass = try! tempClassString.cropExclusive("(", end: ")<")
				
			}
				
			else {
				if okActivity.hasPrefix("calendar4790") {
					
					activityTitle = try! activityString.cropExclusive("</span>")
					
				}
				else {//if (okActivity.hasPrefix("calendar3500")) {//linked
					activityTitle = try! activityString.cropExclusive("title=").cropExclusive(">", end: "</span")
				}
				activityClass = try! activityTitle.cropEnd(":")
				activityTitle = try! activityTitle.cropExclusive(": ")
			}
		
			//MARK: parsing Desc
			var activityDescData = try! activityString.cropExclusive("</span>")
			while(activityDescData.containsString("<span")) {
				activityDescData = try! activityDescData.cropExclusive("<span")
				activityDesc += (try! activityDescData.cropExclusive(">", end: "</span") as String) + "\n"
			}
			
			tempDay.activities!.append(Activity(classString: activityClass, title: activityTitle, subtitle: activityDesc))
			
			//while loop logic
			croppedActivity = try? (croppedDayString!.cropExclusive(activityStartString, end: activityEndString))
			croppedDayString = try? croppedDayString!.cropExclusive(activityStartString)


		}
		
		return tempDay
	}
}

