//
//  Activity.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation

struct Activity {
	let classString: String?
	let title: String?
	let description: String?
	//TODO: in future, add date, location, etc?
	init(classString: String, title: String, desc: String)
	{
		self.classString = classString
		self.title = title
		self.description = desc
	}
}
