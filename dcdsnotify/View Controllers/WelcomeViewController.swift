//
//  WelcomeViewController.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import UIKit


typealias Credentials = (username: String?, password: String?)
class WelcomeViewController: UIViewController {
	var login: Credentials
	override func viewDidLoad() {
		
	}
	override func viewDidAppear(animated: Bool) {
		login = CacheHelper.retrieveLogin()
		if login.username != nil {
			performSegueWithIdentifier("WelcomeToLogin", sender: nil)
		}            
	}
	@IBAction func onWelcomeButtonTap(sender: AnyObject) {
		performSegueWithIdentifier("WelcomeToLogin", sender: nil)
	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "WelcomeToLogin" {
			self.loadViewIfNeeded()
			let vc = segue.destinationViewController as! LoginViewController
			vc.login = login
		}
	}
}
