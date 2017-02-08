//
//  Constants.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import UIKit

public let DAYS_KEY = "daysKey"
public let LOGS_KEY = "logsKey"
public let LOGIN_STATUS_KEY = "statusKey"
public let SCHEDULE_KEY = "scheduleKey"
typealias Credentials = (username: String, password: String)
class Constants {
	static let userLoginURL = URL(string: "https://www.dcds.edu/userlogin.cfm")!
	static let invalidLoginURL = URL(string: "https://www.dcds.edu/userlogin.cfm?do=login&p=413")!
	static let homeURL = URL(string: "https://www.dcds.edu")!
	static let homeworkWeek = URL(string: "http://www.dcds.edu/page.cfm?p=8256&period=week")!
	static let homeworkDay = URL(string: "https://www.dcds.edu/page.cfm?p=8256&period=day")!
	static let homeworkYear = URL(string: "http://www.dcds.edu/page.cfm?p=8256&period=year")!
	
	struct Segues {
		static let LoginToHomeworkView = "LoginToHomeworkView"
		static let HomeworkToSettings = "HomeworkToSettings"
        static let SkipWelcome = "SkipWelcome"
        static let SettingsToSchedule = "SettingsToSchedule"
	}
	struct Images {
		static let settings = UIImage(named: "settings")!
		static let rightCarat = UIImage(named: "right_carat")!
		static let leftCarat = UIImage(named: "left_carat")!
        static let calendar = UIImage(named: "calendar")!
	}
	
}
