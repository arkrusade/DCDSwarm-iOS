//
//  Temp.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 9/9/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit


class Temp: UIViewController {
	var window: UIWindow?
	
	override func viewDidLoad() {
		
	}
	
	@IBOutlet weak var clearAllButton: UIButton!
	
	@IBAction func onLogoutButtonTap(sender: AnyObject) {
		logout()
	}
	@IBOutlet weak var logoutButton: UIButton!
	
	func logout() {
		self.dismissViewControllerAnimated(false, completion: nil)
		CacheHelper.clearLogin()
		let window = UIApplication.sharedApplication().keyWindow
		let vc = WelcomeViewController()
		vc.login = (nil, nil)
		window?.rootViewController = vc

	}
}