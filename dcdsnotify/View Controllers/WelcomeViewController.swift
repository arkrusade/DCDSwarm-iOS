//
//  WelcomeViewController.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation
import UIKit


typealias Credentials = (username: String, password: String)
class WelcomeViewController: UIViewController {
	var login: Credentials?
	override func viewDidLoad() {
		
	}
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		login = ("", "")
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override func viewDidAppear(animated: Bool) {
		login = CacheHelper.retrieveLogin()
		if login != nil {
			performSegueWithIdentifier(Constants.Segues.SkipWelcome, sender: nil)
		}            
	}
	@IBAction func onWelcomeButtonTap(sender: AnyObject) {
		performSegueWithIdentifier(Constants.Segues.SkipWelcome, sender: nil)
	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == Constants.Segues.SkipWelcome {
			let vc = segue.destinationViewController as! LoginViewController
			vc.login = login
		}
	}
}
