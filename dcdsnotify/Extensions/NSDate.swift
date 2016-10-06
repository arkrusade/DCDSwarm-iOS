//
//  NSDate.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
extension NSDate {
//		static let homeworkDay = NSURL(string: "https://www.dcds.edu/page.cfm?p=8256&start=11/08/2013&period=day")!
	func dayOfTheWeek() -> String? {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEE"
		return dateFormatter.stringFromDate(self)
	}

    static func fromExcelDate(num: Int) -> NSDate?
    {
        let excelRefDate = NSCalendar.currentCalendar()
            .dateByAddingUnit(
                .Year,
                value: -101,
                toDate: NSDate.init(timeIntervalSinceReferenceDate: 0),
                options: NSCalendarOptions(rawValue: 0)
        )
        let date = NSCalendar.currentCalendar()
            .dateByAddingUnit(
                .Day,
                value: num-1,
                toDate: excelRefDate!,
                options: NSCalendarOptions(rawValue: 0)
        )
        return date
    }
	func yesterday() -> NSDate?
	{
		let yesterday = NSCalendar.currentCalendar()
			.dateByAddingUnit(
				.Day,
				value: -1,
				toDate: self,
				options: NSCalendarOptions(rawValue: 0)
		)
		return yesterday
	}
	func tomorrow() -> NSDate?
	{
		let tomorrow = NSCalendar.currentCalendar()
			.dateByAddingUnit(
				.Day,
				value: 1,
				toDate: self,
				options: NSCalendarOptions(rawValue: 0)
		)
		return tomorrow
	}
	func asSlashedDate() -> String {
		return NSDate.dateFormatterSlashed().stringFromDate(self)
	}
	static func dateFormatterSlashed() -> NSDateFormatter
	{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		return dateFormatter
	}
	static func dateFormatterSlashedAndDay() -> NSDateFormatter {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEE '-' M/d/yy"
		return dateFormatter
	}
	static func dateFormatterDashed() -> NSDateFormatter {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEE '-' MMMM d, yyyy"
		return dateFormatter
	}
	static func dateFormatterDashedShort() -> NSDateFormatter {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEE '-' MMM. d, yyyy"
		return dateFormatter
	}
	func toDCDSURL() -> NSURL?
	{
		let baseURLString = "https://www.dcds.edu/page.cfm?p=8256"
		
		return NSURL(string: baseURLString + "&start=\(NSDate.dateFormatterSlashed().stringFromDate(self))")
		//TODO: add period of calendar
		//define as enum
	}
}
