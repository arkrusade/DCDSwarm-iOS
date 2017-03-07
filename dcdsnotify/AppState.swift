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
    var date: Date = Date()
    func login(login:Credentials, sender: UIViewController)
	{
        if UserDefaults.standard.bool(forKey: LOGIN_STATUS_KEY)
        {
            //TODO: crash detected
            let alert = UIAlertController(title: "Crash Detected", message: "Send report to developer?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) -> Void in
                let main = UIStoryboard(name: "Main", bundle: nil)
            
                if let nav = sender.navigationController ?? sender as? UINavigationController {
                    let RVC = main.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.Report) as! ReportViewController
                    nav.pushViewController(RVC, animated: true)
                    RVC.title = "Send Report"
                    RVC.loadView()
                    RVC.sendReport(withLogs: true)
                }
                
                else {//TODO: fix to make sure RVC can go back
                    let RVC = main.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.Report) as! ReportViewController

                    sender.present(RVC, animated: true, completion: ({
                    RVC.sendReport(withLogs: true)
                }))
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            sender.present(alert, animated: true)
        }
        CacheHelper.sharedInstance.storeLogin(login)
        credentials = login
        loggedIn = true
        date = Date()
  }

	func logout(_ sender: UIViewController?) {
		OperationQueue.main.addOperation({
			CacheHelper.clearAll()
		})
        //TODO: constants
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateInitialViewController() as! LoginViewController
		let window = UIApplication.shared.windows[0]
		sender?.dismiss(animated: false, completion: nil)
		window.rootViewController = loginVC
        
        loggedIn = false
	}
    func enter() {
        loggedIn = true
    }
    func exit(withLogout: Bool, sender: UIViewController?) {
        if withLogout {
            logout(sender)
        }
        loggedIn = false
        
    }
}
