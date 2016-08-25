//
//  LoginViewController.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet weak var UsernameTextField: UITextField!
	@IBOutlet weak var PasswordTextField: UITextField!

	override func viewDidLoad() {
		UsernameTextField.text = Keys.username
		PasswordTextField.text = Keys.password
		onLoginButtonTap(self)
	}
	@IBAction func onLoginButtonTap(sender: AnyObject) {
		// Do any additional setup after loading the view, typically from a nib.
		//TODO: make login image a loading thingy
		guard UsernameTextField.text != "" || PasswordTextField.text != "" else {
			print("empty textbox")
			ErrorHandling.defaultErrorHandler("Invalid Username/Password", desc: "Please enter a valid username and password combination")
			return
		}
		
		let url = Constants.userLoginURL
		
		
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		let postString = "do=login&p=413&username=\(UsernameTextField.text!)&password=\(PasswordTextField.text!)&submit=login"
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
			
			//MARK: Login Check
			
			let urlContentString = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
			let loginCheck = try? (urlContentString.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit"))
			guard loginCheck == "STUDENT PORTAL" else {
				print("Failed Login")
				ErrorHandling.defaultErrorHandler("Invalid Username/Password", desc: "Please enter a valid username and password combination")
				return
				
			}
			NSOperationQueue.mainQueue().addOperationWithBlock {
				
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
			vc.currentDay = NSDate()
		}
	}
}

