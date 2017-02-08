//
//  AppState.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 9/2/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
class AppState {
	static var sharedInstance = AppState()
    private var loggedIn = false {
        didSet {
            

            UserDefaults.standard.set(self.loggedIn, forKey: LOGIN_STATUS_KEY)

        }
    }
    var credentials: Credentials? = nil
    
    //TODO: change date for app to appwide, sharedinstance
    func login(login:Credentials)
	{
        if UserDefaults.standard.bool(forKey: LOGIN_STATUS_KEY)
        {
            //TODO: crash detected
        }
	  credentials = login
    loggedIn = true

  }

	func logout(_ sender: UIViewController) {
		OperationQueue.main.addOperation({
			CacheHelper.clearAll()
		})
        //TODO: constants
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateInitialViewController() as! LoginViewController
		let window = UIApplication.shared.windows[0]
		sender.dismiss(animated: false, completion: nil)
		window.rootViewController = loginVC
        
        loggedIn = false
	}
}
