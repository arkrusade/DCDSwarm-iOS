//
//  CalendarHelper.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation

func processHTMLString(htmlString: String)
{
	//MARK: Class Divider
	//TODO: get class for calendar4790
	let classStartString = "<ul class=\"eventobj "
	let classEndString = "<!-- end eventobj -->"
	let cropped = try! (htmlString.cropExclusive(classStartString, end: classEndString))
	print(cropped)
	
	
	//TODO: practically the same, except activity title crop "title="
	if (cropped.hasPrefix("calendar3500"))
	{
		
		
		//MARK: Find activity title and desc
		let activityString = try! cropped.crop("etitle")
		let activityTitle = try! activityString.cropExclusive("title=").cropExclusive(">", end: "<")
		var activityDescData = try! activityString.cropExclusive("</span>")
		var activityDesc: [String] = []
		while(activityDescData.containsString("<span")) {
			activityDescData = try! activityDescData.cropExclusive("<span")
			activityDesc.append(try! activityDescData.cropExclusive(">", end: "</span") as String)
		}
		
		print(activityTitle)
	}
	else if cropped.hasPrefix("calendar4790")
	{
		let activityString = try! cropped.crop("etitle")
		let activityTitle = try! activityString.cropExclusive(">", end: "</span")
		var activityDescData = try! activityString.cropExclusive("</span>")
		var activityDesc: [String] = []
		while(activityDescData.containsString("<span")) {
			activityDescData = try! activityDescData.cropExclusive("<span")
			activityDesc.append(try! activityDescData.cropExclusive(">", end: "</span") as String)
		}
		print(activityTitle)
	}

}