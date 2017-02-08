//
//  HTMLLog.swift
//  dcdsnotify
//
//  Created by Justin Laptop Lee on 2/2/17.
//  Copyright © 2017 orctech. All rights reserved.
//

class HTMLLog {
    var date: Date = Date()
    var htmlData: String = ""
    init(date: Date, log: String) {
        self.date = date
        self.htmlData = log
    }
}
