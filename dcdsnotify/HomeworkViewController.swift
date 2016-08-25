//
//  ViewController.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/21/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Foundation
extension NSDate {
	func dayOfTheWeek() -> String? {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEEE"
		return dateFormatter.stringFromDate(self)
	}
}
class HomeworkViewController: UIViewController {
	
	@IBOutlet weak var titleBar: UINavigationItem!
	
	var currentDay: NSDate! {
		didSet {
			titleBar.title = currentDay.dayOfTheWeek()!
		}
	}
	//TODO: set date with page load
	
	
		override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidLoad() {
		let atask = NSURLSession.sharedSession().dataTaskWithURL(Constants.homeworkDay, completionHandler: { (data, response, error) -> Void in
			//TODO: change to self.currentDay
			
			guard error == nil && data != nil else {                                                          // check for fundamental networking error
				print("error=\(error)")
				return
			}
			
			if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				if httpStatus.statusCode == 404 || httpStatus.statusCode == 403 {
					return
				}
				print("response = \(response)")
			}
			
			let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
			
			
			self.currentDay = NSDate()
			//NOTE: caldata in year divides months
			//every day divided by class="listcap"
			//every class divided by eventobj
			
			
			
			
		})
		atask.resume()
		
	}
}
extension String {
	var lines:[String] {
		var result:[String] = []
		enumerateLines{ result.append($0.line) }
		return result
	}
	func indexOf(target: String) -> Int
	{
		let range = self.rangeOfString(target)
		if let range = range {
			return self.startIndex.distanceTo(range.startIndex)
		} else {
			return -1
		}
	}
	
	func indexOf(target: String, startIndex: Int) -> Int
	{
		let startRange = self.startIndex.advancedBy(startIndex)
		
		let range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: startRange ..< endIndex)
		
		if let range = range {
			return self.startIndex.distanceTo(range.startIndex)
		} else {
			return -1
		}
	}
	
}
extension NSString {
	enum CropError: ErrorType {
		case StartNotContained
		case EndNotContained
		
	}
	func crop(start: String) throws -> NSString
	{
		let startRange = (self as NSString).rangeOfString(start)
		guard startRange.location < self.description.characters.count else
		{
			throw CropError.StartNotContained
		}
		
		return (self as NSString).substringFromIndex(startRange.location)
	}
	func cropExclusive(start: String) throws -> NSString
	{
		let startRange = (self as NSString).rangeOfString(start)
		guard startRange.location < self.description.characters.count else
		{
			throw CropError.StartNotContained
		}
		
		return (self as NSString).substringFromIndex(startRange.location + startRange.length)
	}
	
	func cropEnd(suffix: String) throws -> NSString
	{
		let endRange = (self as NSString).rangeOfString(suffix)
		guard endRange.location < self.description.characters.count else
		{
			throw CropError.EndNotContained
		}
		
		return (self as NSString).substringToIndex(endRange.location + endRange.length)
	}
	func cropEndExclusive(suffix: String) throws -> NSString
	{
		let endRange = (self as NSString).rangeOfString(suffix)
		guard endRange.location < self.description.characters.count else
		{
			throw CropError.EndNotContained
		}
		
		return (self as NSString).substringToIndex(endRange.location)
	}
	
	func crop(start: String, end: String) throws -> NSString
	{
		let startRange = (self as NSString).rangeOfString(start)
		guard startRange.location < self.description.characters.count else
		{
			throw CropError.StartNotContained
		}
		
		let startCut = (self as NSString).substringFromIndex(startRange.location)
		
		let endRange = (startCut as NSString).rangeOfString(end)
		guard endRange.location < startCut.characters.count else
		{
			throw CropError.EndNotContained
		}
		
		return (startCut as NSString).substringToIndex(endRange.location + endRange.length)
	}
	func cropExclusive(start: String, end: String) throws -> NSString
	{
		let startRange = (self as NSString).rangeOfString(start)
		guard startRange.location < self.description.characters.count else
		{
			throw CropError.StartNotContained
		}
		
		let startCut = (self as NSString).substringFromIndex(startRange.location + startRange.length)
		
		let endRange = (startCut as NSString).rangeOfString(end)
		guard endRange.location < startCut.characters.count else
		{
			throw CropError.EndNotContained
		}
		
		return (startCut as NSString).substringToIndex(endRange.location)
	}
}
