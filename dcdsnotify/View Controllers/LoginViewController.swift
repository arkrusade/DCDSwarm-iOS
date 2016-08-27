//
//  LoginViewController.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var UsernameTextField: UITextField!
	@IBOutlet weak var PasswordTextField: UITextField!

	@IBOutlet weak var vertStackView: UIStackView!
	override func viewDidLoad() {
//		let path = NSBundle.mainBundle().pathForResource("keys", ofType: "txt")
//		let fileText = try? String(contentsOfFile: path?)
//		print(fileText)
		if let username = Keys.username{
			UsernameTextField.text = username
			PasswordTextField.text = Keys.password!
			onLoginButtonTap(self)
		}
		activityIndicator.hidesWhenStopped = true
		activityIndicator.stopAnimating()
	}
	@IBAction func onLoginButtonTap(sender: AnyObject) {
		
		
		// Do any additional setup after loading the view, typically from a nib.
		//TODO: make login image a loading thingy
		guard UsernameTextField.text != "" || PasswordTextField.text != "" else {
			NSOperationQueue.mainQueue().addOperationWithBlock {
				print("empty text")
				ErrorHandling.defaultErrorHandler("Invalid Username/Password", desc: "Please enter a valid username and password combination")
				
			}
			return

		}
		
		let url = Constants.userLoginURL
		activityIndicator.startAnimating()

		
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		let postString = "do=login&p=413&username=\(UsernameTextField.text!)&password=\(PasswordTextField.text!)&submit=login"
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
//			self.activityIndicator.stopAnimating()
			guard error == nil && data != nil else {                                                          // check for fundamental networking error
				print("error=\(error)")
				ErrorHandling.defaultErrorHandler(error!)
				return
			}
			
			if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(response)")
			}
			
			//MARK: Login Check
			
			let urlContentString = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
			let loginCheck = try? (urlContentString.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit"))
			guard loginCheck == "STUDENT PORTAL" else {
				//TODO: check for parents too
				NSOperationQueue.mainQueue().addOperationWithBlock {
					print("Failed Login")
					self.activityIndicator.stopAnimating()
					ErrorHandling.defaultErrorHandler("Invalid Username/Password", desc: "Please enter a valid username and password combination")
					
				}
				return
			}

			NSOperationQueue.mainQueue().addOperationWithBlock {
				self.activityIndicator.stopAnimating()
				self.performSegueWithIdentifier(Constants.Segues.LoginToHomeworkView, sender: self)
			}
			
		}
		task.resume()
		

	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == Constants.Segues.LoginToHomeworkView
		{
			//TODO: set 'Welcome user.id!'
			print("seguing to HomeworkViewController")
			let nav = segue.destinationViewController as! UINavigationController
			let vc = nav.topViewController as! HomeworkViewController
			vc.currentDay = Day(date: NSDate.dateFormatterSlashed().dateFromString("01/28/2013"))
			//TODO: change from hardcoding
		}
	}
}

