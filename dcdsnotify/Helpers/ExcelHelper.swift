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
        
        let storageRef = Storage.storage()
        let islandRef = storageRef.reference().child("1718").child("1718goal1.json")
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                ErrorHandling.defaultError(error, sender: sender)
            } else {
                if let jsonData = data
                    {
                        do{
                        if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
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
                                
                                var fullSchedule: [DaySchedule] = []
                                
                                for i in 1...fields.keys.count/2 {
                                    daySchedule = DaySchedule()
                                    blocksKey = field + "\(2*i-1)"
                                    timesKey = field + "\(2*i)"
                                    
                                    if let blocks = fields[blocksKey] as? [String] {
                                        if let times = fields[timesKey] as? [String] {
                                            let excelDateString: String = blocks[0]
                                            if let excelNum = Int(excelDateString) {
                                                daySchedule.date = Date.fromExcelDate(excelNum)
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
                                
                                self.schedule = (fullSchedule.count == 0 ? nil : fullSchedule)
                                self.loaded = true
                            }
                        }
                    } catch {
                        ErrorHandling.defaultError("Excel error", desc: "Unknown", sender: sender)
                    }
                }
            }
        }
    }
    
}
