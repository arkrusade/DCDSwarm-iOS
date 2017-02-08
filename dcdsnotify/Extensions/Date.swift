//
//  Date.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
extension Date {
//		static let homeworkDay = NSURL(string: "https://www.dcds.edu/page.cfm?p=8256&start=11/08/2013&period=day")!
	func dayOfTheWeek() -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE"
		return dateFormatter.string(from: self)
	}

    static func fromExcelDate(_ num: Int) -> Date?
        
    {
        let excelRefDate = (Calendar.current as NSCalendar)
            .date(
                byAdding: .year,
                value: -101,
                to: Date.init(timeIntervalSinceReferenceDate: 0),
                options: NSCalendar.Options(rawValue: 0)
        )
        let date = (Calendar.current as NSCalendar)
            .date(
                byAdding: .day,
                value: num-1,
                to: excelRefDate!,
                options: NSCalendar.Options(rawValue: 0)
        )
        return date
    }
	func yesterday() -> Date?
	{
		let yesterday = (Calendar.current as NSCalendar)
			.date(
				byAdding: .day,
				value: -1,
				to: self,
				options: NSCalendar.Options(rawValue: 0)
		)
		return yesterday
	}
	func tomorrow() -> Date?
	{
		let tomorrow = (Calendar.current as NSCalendar)
			.date(
				byAdding: .day,
				value: 1,
				to: self,
				options: NSCalendar.Options(rawValue: 0)
		)
		return tomorrow
	}
	func asSlashedDate() -> String {
		return Date.dateFormatterSlashed().string(from: self)
	}
	static func dateFormatterSlashed() -> DateFormatter
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		return dateFormatter
	}
	static func dateFormatterSlashedAndDay() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE '-' M/d/yy"
		return dateFormatter
	}
	static func dateFormatterDashed() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE '-' MMMM d, yyyy"
		return dateFormatter
	}
	static func dateFormatterDashedShort() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE '-' MMM. d, yyyy"
		return dateFormatter
	}
	func toDCDSURL() -> URL?
	{
		let baseURLString = "https://www.dcds.edu/page.cfm?p=8256"
		
		return URL(string: baseURLString + "&start=\(Date.dateFormatterSlashed().string(from: self))")
		//TODO: add period of calendar
		//define as enum
	}
}
