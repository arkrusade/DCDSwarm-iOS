//
//  ErrorHandling.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
import ConvenienceKit

struct ErrorHandling {
	
	static let ErrorTitle           = "Error"
	static let ErrorOKButtonTitle   = "Ok"
	static let ErrorDefaultMessage  = "Something unexpected happened, sorry for that!"
	
	static let DelayedFeatureTitle		= "Delayed Feature"
	static let DelayedFeatureMessage	= "Sorry, this feature is not yet available"
	
	/**
	This default error handler presents an Alert View on the topmost View Controller
	*/
	static func delayedFeatureAlert()
	{
		let alert = UIAlertController(title: DelayedFeatureTitle, message: DelayedFeatureMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
		
		let window = UIApplication.sharedApplication().windows[0]
		window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
	}
	static func defaultErrorHandler(error: NSError) {
		let alert = UIAlertController(title: ErrorTitle, message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
		
		let window = UIApplication.sharedApplication().windows[0]
		window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
	}
	static func defaultErrorHandler(desc: String) {
		let alert = UIAlertController(title: ErrorTitle, message: desc, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
		
		let window = UIApplication.sharedApplication().windows[0]
		window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
	}
	static func defaultErrorHandler(title: String, desc: String) {
		let alert = UIAlertController(title: title, message: desc, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
		
		let window = UIApplication.sharedApplication().windows[0]
		window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
	}
}

	