//
//  ErrorHandling.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

struct ErrorHandling {
	
	static let ErrorTitle           = "Error"
	static let ErrorOKButtonTitle   = "Ok"
	static let ErrorDefaultMessage  = "Something unexpected happened, sorry for that!"
	
	static let DelayedFeatureTitle		= "Delayed Feature"
	static let DelayedFeatureMessage	= "Sorry, this feature is not yet available"
	
	/**
	This default error handler presents an Alert View on the topmost View Controller
	*/
    static func delayedFeatureAlert(sender: UIViewController)
	{
        ErrorHandling.defaultErrorHandler(DelayedFeatureTitle, desc: DelayedFeatureMessage, sender: sender)
	}
    static func defaultErrorHandler(error: NSError, sender: UIViewController) {
		ErrorHandling.defaultErrorHandler(ErrorTitle, desc: error.localizedDescription, sender: sender)
	}
    static func defaultErrorHandler(title: String, desc: String, sender: UIViewController) {
		let alert = UIAlertController(title: title, message: desc, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
		
		NSOperationQueue.mainQueue().addOperationWithBlock {
			sender.presentViewController(alert, animated: true, completion: nil)
		}
	}
}

	
