//
//  Constants.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
class Constants {
	static let userLoginURL = NSURL(string: "https://www.dcds.edu/userlogin.cfm")!
	static let invalidLoginURL = NSURL(string: "https://www.dcds.edu/userlogin.cfm?do=login&p=413")!
	static let homeURL = NSURL(string: "https://www.dcds.edu")!
	static let homeworkWeekURL = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&period=week")!
	static let homeworkDayURLWithLinks = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256")!
	static let homeworkDay = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=05/25/2013&period=week")!
	static let homeworkYear = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=01/21/2013&period=year")!
	static let homeworkYearWithLinks = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=01/21/2014&period=year")!
	
	struct Segues {
		static let LoginToHomeworkView = "LoginToHomeworkView"
	}
}