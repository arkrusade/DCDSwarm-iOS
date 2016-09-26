//
//  ErrorHandling.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
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
	This default error handler presents an Alert View on the sending View Controller
	*/
    //TODO: add report error ability
    static func delayedFeatureAlert(sender: UIViewController)
    {
        ErrorHandling.defaultError(DelayedFeatureTitle, desc: DelayedFeatureMessage, sender: sender)
    }
    static func defaultError(error: NSError, sender: UIViewController) {
        ErrorHandling.defaultError(ErrorTitle, desc: error.localizedDescription, sender: sender)
    }
    static func defaultError(error: NSError, sender: UIViewController, completion: ClosureVoid?) {
        ErrorHandling.displayAlert(ErrorTitle, desc: error.localizedDescription, sender: sender, completion: completion)
    }
    static func defaultError(title: String, desc: String, sender: UIViewController) {
        displayAlert(title, desc: desc, sender: sender, completion: nil)
    }
    static func displayAlert(title: String, desc: String, sender: UIViewController, completion: ClosureVoid?) {
        let alert = UIAlertController(title: title, message: desc, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))

        NSOperationQueue.mainQueue().addOperationWithBlock {
            sender.presentViewController(alert, animated: true, completion: completion)
        }
    }
}

	
