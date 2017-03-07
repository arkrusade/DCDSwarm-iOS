//
//  CalendarHelper.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation

class CalendarHelper {
	static func processCalendarString(_ htmlString: String) -> ActivitiesDay
		//TODO: add param for diff calendar lengths
	{
		//MARK: set date
		let emptyStart = "<li class=\"listempty\">"
		let emptyEnd = "</li>"
		
		let dayStart = "thisDate: {ts '"
		let dayEnd = "'} start:"
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = dateFormatter.date( from: htmlString.cropExclusive(dayStart, end: dayEnd) ?? "") ?? Date()

		//MARK: check for empty day
		guard (htmlString.crop(emptyStart, end: emptyEnd)) == nil else{
						//TODO: remove hotfix
			let emptyDay = ActivitiesDay.emptyDay()
			return emptyDay
		}
        let log: HTMLLog = HTMLLog(date: date, log: htmlString)
        CacheHelper.sharedInstance.addLog(log: log)
		/*
		NOTE: caldata divides months
		nothing divides weeks
		every day divided by class="listcap"
		every class divided by eventobj
		
		
		<ul class="eventobj calendar3160" id="event_521366_591468">
		^ (after calendar)
		this number
		applies to end of this link:
		https://www.dcds.edu/page.cfm?p=
		to get group page
		*/
		
		
		//MARK: activitiesDay divider
		
		let dayStartString = "<span class=\"listcap"
		let dayEndString = "</div>"//TODO: will not work on week or greater periods
        let tempDayString: String? = htmlString.cropExclusive(dayStartString, end: dayEndString)?.cropExclusive(">")
        guard tempDayString != nil else {
            return ActivitiesDay.emptyDay()
        }
        var dayString: String? = tempDayString
		let tempDay = ActivitiesDay(list: [])
		
		
		//MARK: Activity Divider
		let activityStartString = "<ul class=\"eventobj calendar"
		let activityEndString = "<!-- end eventobj -->"
		
		
		var currentActivity = dayString!.cropExclusive(activityStartString, end: activityEndString)//Gets single activity
		let classID = dayString!.cropEndExclusive("\\")//for calendar id of class
		let activityID = dayString!.cropExclusive("\"event_", end: "\\\"")//gets activity ID
		//TODO: use activity and class ID
		dayString = dayString!.cropExclusive(activityStartString)//removes currActivity by finding next one
		
		while let okActivity = currentActivity {
			
			
            var activityTitle: String! = "Title not found"
			var activityClass: String? = nil
            var activityDesc: String? = nil
			
			//MARK: parsing Title
            if let activityString =  okActivity.crop("etitle") {
			if okActivity.hasPrefix("3659") {
				activityTitle =  activityString.cropExclusive("\">", end: "/span")
				
				var tempClassString = activityTitle
				
				activityTitle =  activityTitle.cropEndExclusive("(")
				if activityTitle.contains("<br") {
					tempClassString =  tempClassString?.cropExclusive("<br")!.cropExclusive("(")!
					activityTitle =  activityTitle.cropEndExclusive("<")
					
				}
				
				activityClass =  tempClassString?.cropExclusive("(", end: ")<") ?? "Failed to find class"
				
			}
				
				//			else if okActivity.hasPrefix("4790") {
				//				activityTitle =  activityString.cropExclusive("</span>")
				//				activityClass =  activityTitle.cropEnd(":")
				//				activityTitle =  activityTitle.cropExclusive(": ")
				//			}
			else if (okActivity.hasPrefix("3500")) {
				activityTitle =  activityString.cropExclusive("title=")?.cropExclusive(">", end: "</span") ?? "No title: code 3500"
                activityClass =  activityTitle.cropEnd(":") ?? "No class: code 3500"
				activityTitle =  activityTitle.cropExclusive(": ") ?? "No title: code 3500"
			}
			else {
				//linked
				if okActivity.contains("title=\"Click here for event details\">") {
					activityTitle =  activityString.cropExclusive("title=\"Click here for event details\">", end: "</span>")//removes beginning crap in activity
					
					//separates class name from activity title
                    if let tempClass =  activityTitle.cropEnd("):") {
                        activityClass = tempClass
                        activityClass!.remove(at: tempClass.characters.index(before: tempClass.endIndex))
                    }
                    else {
                        //Activity not found
                        activityTitle =  activityString.cropExclusive("title=")?.cropExclusive(">", end: "</span") ?? "No title: code 3500"
                        activityClass =  activityTitle.cropEnd(":") ?? "No class: code 3500"
                        activityTitle =  activityTitle.cropExclusive(": ") ?? "No title: code 3500"
                    }
                    
                    if let tempTitle = activityTitle.cropExclusive("): ", end: "</") {
                        activityTitle = tempTitle
                    }
                    if activityTitle.contains("<br") {
                        activityTitle =  activityTitle.cropEndExclusive("<br")
                    }
//                    activityTitle =  activityTitle.cropExclusive("): ", end: "</")
//                    
//                    if activityTitle.containsString("<br") {
//                        activityTitle =  activityTitle.cropEndExclusive("<br")
//                    }
				}
					
					//not linked
				else if okActivity.contains("<span class=\"eventcon\">")//find event content
				{
                    if let tempActivity =  okActivity.cropExclusive("id=\"e_") {
					let activityID =  tempActivity.cropEndExclusive("\">")
					//TODO: organize activities by class and use id
					activityClass =  (tempActivity.cropExclusive("\">", end: "): ")! + ")" )
					activityTitle =  (tempActivity.cropExclusive("): ", end: "</span>") ?? "Failed Title")
					
					
					if activityTitle.contains("<br") {
						activityTitle =  activityTitle.cropEndExclusive("<br")
					}
                    }
                    else {
                        activityTitle = "Failed title: code eventcon"
                    }
					
				}
				else {
					activityClass = "Could not find activity"
				}
				
			}
			
			//MARK: parsing Desc
                if var activityDescData =  activityString.cropExclusive("</span>") {
                    activityDesc = ""
                    while(activityDescData.contains("<span")) {
                        activityDescData =  activityDescData.cropExclusive("<span")!
                        activityDescData =  activityDescData.cropExclusive(">", end: "</span")!
                        
                        if activityDescData.contains("<") && activityDescData.contains(">"){//if carats found
                            //find carats and make range
                            let startIndex = activityDescData.range(of: "<")!.lowerBound
                            let endIndex = activityDescData.range(of: ">")!.upperBound
                            let asdf = startIndex..<endIndex
                            //assert break in carats
                            guard activityDescData.substring(with: asdf).contains("br") || activityDescData.substring(with: asdf).contains("BR") else {
                                print("carats found, but no break")
                                break
                            }
                            //bye carats
                            activityDescData.removeSubrange(asdf)
                            //replace with newline
                            //					activityDescData.insertContentsOf("\n".characters, at: startIndex)
                        }
                        activityDesc? += (activityDescData) + "\n"
                    }
                }
            
			tempDay.list!.append(Activity(classString: activityClass ?? "No Title Found", title: activityTitle ?? "Title not found", subtitle: activityDesc ?? "Description not found"))
			
			//while loop logic
			//gets the next activity
			currentActivity = (dayString!.cropExclusive(activityStartString, end: activityEndString))
			dayString = dayString!.cropExclusive(activityStartString)
            }
			
		}
		return tempDay
	}
}

