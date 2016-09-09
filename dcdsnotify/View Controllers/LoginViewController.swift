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
	var login: Credentials!
	@IBOutlet weak var vertStackView: UIStackView!
	override func viewDidLoad() {
		super.viewDidLoad()
		activityIndicator.hidesWhenStopped = true
		activityIndicator.stopAnimating()
		
	}
	override func viewDidAppear(animated: Bool) {
		if login.username != nil {
			UsernameTextField.text = login.username
			PasswordTextField.text = login.password
			onLoginButtonTap(self)
		}
	}
	
	@IBAction func viewTapped(sender: AnyObject) {
		self.UsernameTextField.resignFirstResponder()
		self.PasswordTextField.resignFirstResponder()
	}
	
	
	@IBAction func onLoginButtonTap(sender: AnyObject) {
//		performSegueWithIdentifier(Constants.Segues.LoginToHomeworkView, sender: nil)
//		return

		//TODO: make better offline
		
		guard UsernameTextField.text != "" || PasswordTextField.text != "" else {
			NSOperationQueue.mainQueue().addOperationWithBlock {
				print("empty text")
				ErrorHandling.defaultErrorHandler("Invalid Username/Password", desc: "Please enter a valid username and password combination")
				
			}
			return

		}
		
		
		NSURLSession.sharedSession()
		
		
		
		let url = Constants.userLoginURL
		activityIndicator.startAnimating()
		
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		let postString = "do=login&p=413&username=\(UsernameTextField.text!)&password=\(PasswordTextField.text!)&submit=login"
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in

			NSOperationQueue.mainQueue().addOperationWithBlock {
				self.activityIndicator.stopAnimating()
			}
			guard error?.code != -999 else {
				//cancelled task
				return
			}
			guard error?.code != -1009 else {
				print("no internet")
				NSOperationQueue.mainQueue().addOperationWithBlock {
					ErrorHandling.defaultErrorHandler(error!)
				}
				return
			}
			guard error == nil && data != nil else {// check for fundamental networking error
				print("error=\(error)")

				NSOperationQueue.mainQueue().addOperationWithBlock {
					ErrorHandling.defaultErrorHandler(error!)
				}
				return
			}
			
			if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(response)")
				return
			}
			
			//MARK: Login Check
			
			let urlContentString = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
			let loginCheck = try? (urlContentString.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit"))
			guard loginCheck == "STUDENT PORTAL" else {
				//TODO: check for parents too
				NSOperationQueue.mainQueue().addOperationWithBlock {
					print("Failed Login")
					ErrorHandling.defaultErrorHandler("Invalid Username/Password", desc: "Please enter a valid username and password combination")
					
				}
				return
			}

			NSOperationQueue.mainQueue().addOperationWithBlock {
				CacheHelper.storeLogin(self.UsernameTextField.text!, password: self.PasswordTextField.text!)
				self.UsernameTextField.text = ""
				self.PasswordTextField.text = ""
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
			vc.activitiesDay = Day(date: NSDate())
			vc.currentDay = NSDate()
			//TODO: change from hardcoding
		}
	}
}

