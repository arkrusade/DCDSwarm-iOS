//
//  Activity.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation

struct Activity: CustomStringConvertible {
    let classString: String!
    let title: String!
    let subtitle: String!
    
    init(classString: String, title: String, subtitle: String)
    {
        self.classString = classString
        self.title = title
        self.subtitle = subtitle
    }
    init(fromValues: [String]) {
        self.classString = fromValues[0]
        self.title = fromValues[1]
        self.subtitle = fromValues[2]
    }
    
    var description: String {
        get {
            return "\n\tclass: \(classString)\n\ttitle: \(title)\n\tdesc: \(subtitle)\n"
        }
    }
    //TODO: change to dict instead of array
    var values: [String] {
        return [classString, title, subtitle]
    }
    
}
