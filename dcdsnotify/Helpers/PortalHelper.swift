//
//  PortalHelper.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 9/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
class PortalHelper {
	static func checkLoggedIn(htmlString: String) -> Bool {
		let loginCheck = try? (htmlString.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit"))
		if loginCheck == "Member Login" {
			return false
		}
		else if loginCheck == "STUDENT PORTAL" {
			//TODO: check for parents too
			return true
		}
		return false
	}
}