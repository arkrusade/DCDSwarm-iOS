//
//  ExcelHelper.swift
//  dcdsnotify
//
//  Created by Justin Lee on 10/6/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

enum ExcelParsingError: Error	 {
    case failedParse(goalNum: Int)
}

class ExcelHelper {
    static let sharedInstance = ExcelHelper()
    var schedule: [DaySchedule]?
    //TODO: changed to cached schedule (via files maybe) 
    var loaded = false
    
    func getSchedule(_ forDay: Date, sender: UIViewController) -> DaySchedule?{
        if !loaded || schedule == nil {
            do  {
                
                try configureBlockSchedule(sender: sender)
            }
            catch ExcelParsingError.failedParse(let goal) {
                ErrorHandling.defaultError("Failed to parse schedule", desc: "Error with goal \(goal)", sender: sender)
            }
            catch let e as NSError{
                ErrorHandling.defaultError(e, sender: sender)
            }
        }
        if let schedule = schedule {
            for day in schedule {
                if let scheduleDate = day.date
                {
                    if scheduleDate.asSlashedDate() == forDay.asSlashedDate() {
                        return day
                    }
                }
            }
        }
        return nil
    }
    func configureBlockSchedule(sender: UIViewController ) {
        }
    }
    
}
