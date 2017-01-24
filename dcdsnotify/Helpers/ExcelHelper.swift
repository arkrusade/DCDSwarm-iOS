//
//  ExcelHelper.swift
//  dcdsnotify
//
//  Created by Justin Lee on 10/6/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

enum ExcelParsingError: ErrorType	 {
    case FailedParse(goalNum: Int)
}

class ExcelHelper {
    static let sharedInstance = ExcelHelper()
    var schedule: [DaySchedule]?
    var loaded = false

    func getSchedule(forDay: NSDate, sender: UIViewController) -> DaySchedule?{
        if !loaded || schedule == nil {
            do  {
                
                try configureBlockSchedule()
            }
            catch ExcelParsingError.FailedParse(let goal) {
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
    func configureBlockSchedule() throws {
        loaded = true
        var fullSchedule: [DaySchedule] = []
        if let path = NSBundle.mainBundle().pathForResource("convertcsvGoal2", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path)
            {
                do {
                    if let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                    {
                        if let fields: Dictionary = jsonResult as? Dictionary<String, AnyObject>
                        {
                            /*
                             odd i is block numbers
                             eve i is times
                             */
                            var blocksKey = ""
                            var timesKey = ""
                            var daySchedule: DaySchedule
                            var block: Block
                            
                            let field = "FIELD"
                            
                            for i in 1...fields.keys.count/2 {
                                daySchedule = DaySchedule()
                                blocksKey = field + "\(2*i-1)"
                                timesKey = field + "\(2*i)"
                                
                                if let blocks = fields[blocksKey] as? [String] {
                                    if let times = fields[timesKey] as? [String] {
                                        let excelDateString: String = blocks[0]
                                        if let excelNum = Int(excelDateString) {
                                            daySchedule.date = NSDate.fromExcelDate(excelNum)
                                        }
                                        
                                        for j in 1..<blocks.count {
                                            block = Block(name: blocks[j], time: times[j])
                                            if block.name == "Note" && block.time == "" {
                                                continue
                                            }
                                            if (block.name != "" || block.time != "")
                                            {
                                                daySchedule.blocks.append(block)
                                            }
                                        }
                                    }
                                }
                                
                                fullSchedule.append(daySchedule)
                            }
                            
                        }
                    }
                }
                catch {
                    throw ExcelParsingError.FailedParse(goalNum: 3)
                }
            }

        }
        if let path = NSBundle.mainBundle().pathForResource("goal3 copy", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path)
            {
                do {
                    if let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                    {
                        if let fields: Dictionary = jsonResult as? Dictionary<String, AnyObject>
                        {
                            /*
                             odd i is block numbers
                             eve i is times
                             */
                            var blocksKey = ""
                            var timesKey = ""
                            var daySchedule: DaySchedule
                            var block: Block
                            
                            let field = "FIELD"
                            
                            for i in 1...fields.keys.count/2 {
                                daySchedule = DaySchedule()
                                blocksKey = field + "\(2*i-1)"
                                timesKey = field + "\(2*i)"
                                
                                if let blocks = fields[blocksKey] as? [String] {
                                    if let times = fields[timesKey] as? [String] {
                                        let excelDateString: String = blocks[0]
                                        if let excelNum = Int(excelDateString) {
                                            daySchedule.date = NSDate.fromExcelDate(excelNum)
                                        }
                                        
                                        for j in 1..<blocks.count {
                                            block = Block(name: blocks[j], time: times[j])
                                            if block.name == "Note" && block.time == "" {
                                                continue
                                            }
                                            if (block.name != "" || block.time != "")
                                            {
                                                daySchedule.blocks.append(block)
                                            }
                                        }
                                    }
                                }
                                
                                fullSchedule.append(daySchedule)
                            }
                            
                        }
                    }
                }
                catch {
                    throw ExcelParsingError.FailedParse(goalNum: 2)
                }
            }
        }
//        for day in fullSchedule {
//            print("Date: \(day.date?.asSlashedDate())")
//            for block in day.blocks {
//                print(block.name + ": " + block.time)
//            }
//        }
        self.schedule = (fullSchedule.count == 0 ? nil : fullSchedule)
    }

}
