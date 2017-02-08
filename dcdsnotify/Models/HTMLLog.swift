//
//  HTMLLog.swift
//  dcdsnotify
//
//  Created by Justin Laptop Lee on 2/2/17.
//  Copyright © 2017 orctech. All rights reserved.
//

class HTMLLog {
    var date: NSDate = NSDate()
    var htmlData: String = ""
    init(date: NSDate, log: String) {
        self.date = date
        self.htmlData = log
    }
}
