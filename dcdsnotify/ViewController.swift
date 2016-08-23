//
//  ViewController.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/21/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
	let userLoginURL = NSURL(string: "https://www.dcds.edu/userlogin.cfm")
	let invalidLoginURL = NSURL(string: "https://www.dcds.edu/userlogin.cfm?do=login&p=413")
	let homeURL = NSURL(string: "https://www.dcds.edu")
	let homeworkWeekURL = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&period=week")
	let homeworkDayURLWithLinks = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256")
	let homeworkDay = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=05/25/2013&period=week")
	let homeworkYear = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=01/21/2013&period=year")
	let homeworkYearWithLinks = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=01/21/2014&period=year")
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let url = userLoginURL
		
		
		let request = NSMutableURLRequest(URL: url!)
		request.HTTPMethod = "POST"
		let postString = "do=login&p=413&username=lee1801&password=aaruurayhh%60&submit=login"
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			guard error == nil && data != nil else {                                                          // check for fundamental networking error
				print("error=\(error)")
				return
			}
			
			if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(response)")
			}
			
//			let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
//			print("responseString:\n\(responseString)")

			let atask = NSURLSession.sharedSession().dataTaskWithURL(self.homeworkYearWithLinks!, completionHandler: { (data, response, error) -> Void in
				
				guard error == nil && data != nil else {                                                          // check for fundamental networking error
					print("error=\(error)")
					return
				}
				
				if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
					print("statusCode should be 200, but is \(httpStatus.statusCode)")
					print("response = \(response)")
				}
					
				let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
				
				//MARK: Login Check
				let loginCheck = try? (urlContent.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit"))
				guard loginCheck == "Academics Individual Classes Calendar" else {
					print("Failed Login")
					return
					//TODO: insert error handler
					//can differ invalid and not reached with "Member Login"
				}
				//Note to self: caldata in year divides months
				
				
				//MARK: Class Divider
				//TODO: get class for calendar4790
				let classStartString = "<ul class=\"eventobj calendar3500"
				let classEndString = "<!-- end eventobj -->"
				let cropped = try? (urlContent.crop(classStartString, end: classEndString))
				print(cropped ?? "")
				
				//MARK: Find activity title and desc
				let activityString = try! cropped!.crop("etitle")
				let activityTitle = try! activityString.cropExclusive("title=").cropExclusive(">", end: "<")
				var activityDescData = try! activityString.cropExclusive("</span")
				
				while(activityDescData.containsString("<span")) {
					activityDescData = try! activityDescData.cropExclusive("<span").cropExclusive(">", end: "</span")
				}
					
				
				print(activityTitle)
				
//				let range = urlContent.rangeOfString("<li class=\"caldata\"").location
////				guard range
//				
//				let classStartIndex = urlContent.rangeOfString(classDivider).location
//				let classStartedString = urlContent.substringFromIndex(classStartIndex)
//				let nextClassStartIndex = (classStartedString.rangeOfString()?.first)!
//				print("\(classStartIndex)::\(nextClassStartIndex)")
//
//				let classString = classStartedString.substringToIndex(nextClassStartIndex)
//				print(classString)
//				let cutoff = urlContent.substringFromIndex(range)
//				let calData = cutoff.substringToIndex((cutoff.rangeOfString("</div>")?.first)!)
//				print(calData)
//				let calLines = calData.lines
//				print(calLines)
			})
			atask.resume()


		}
		task.resume()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
