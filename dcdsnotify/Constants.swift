//
//  Constants.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import UIKit
class Constants {
	static let userLoginURL = NSURL(string: "https://www.dcds.edu/userlogin.cfm")!
	static let invalidLoginURL = NSURL(string: "https://www.dcds.edu/userlogin.cfm?do=login&p=413")!
	static let homeURL = NSURL(string: "https://www.dcds.edu")!
	static let homeworkWeekURL = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&period=week")!
	static let homeworkDay = NSURL(string: "https://www.dcds.edu/page.cfm?p=8256&start=11/08/2013&period=day")!
	static let homeworkYear = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=01/21/2013&period=year")!
	
	struct Segues {
		static let LoginToHomeworkView = "LoginToHomeworkView"
		static let HomeworkToSettings = "HomeworkToSettings"
        static let WelcomeToLogin = "WelcomeToLogin"
	}
	struct Images {
		static let settings = UIImage(named: "settings")!
		static let rightCarat = UIImage(named: "right_carat")!
		static let leftCarat = UIImage(named: "left_carat")!
	}
	
}
public let DAYS_KEY = "daysKey"
