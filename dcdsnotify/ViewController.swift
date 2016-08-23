//
//  ViewController.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/21/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	let userLoginURL = NSURL(string: "https://www.dcds.edu/userlogin.cfm")
	let invalidLoginURL = NSURL(string: "https://www.dcds.edu/userlogin.cfm?do=login&p=413")
	let homeURL = NSURL(string: "https://www.dcds.edu")
	let homeworkWeekURL = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&period=week")
	let homeworkDayURL = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256")
	let homeworkWeekWithDateURL = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=08/28/2016&period=week")
	let homeworkYearWithDateURL = NSURL(string: "http://www.dcds.edu/page.cfm?p=8256&start=01/21/2014&period=year")
	
	
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

			let atask = NSURLSession.sharedSession().dataTaskWithURL(self.homeworkYearWithDateURL!, completionHandler: { (data, response, error) -> Void in
				
				guard error == nil && data != nil else {                                                          // check for fundamental networking error
					print("error=\(error)")
					return
				}
				
				if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
					print("statusCode should be 200, but is \(httpStatus.statusCode)")
					print("response = \(response)")
				}
					
				let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
				//					print(urlContent!)
				//					print(urlContent == responseString)
				
				let range = urlContent.rangeOfString("<class=\"caldata\"").location
				let cutoff = urlContent.substringFromIndex(range)
				let calData = cutoff.substringToIndex((cutoff.rangeOfString("</div>")?.first)!)
				print(calData)
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

