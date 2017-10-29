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
    static func delayedFeatureAlert(_ sender: UIViewController)
    {
        ErrorHandling.defaultError(DelayedFeatureTitle, desc: DelayedFeatureMessage, sender: sender)
    }
    static func defaultError(_ error: Error, sender: UIViewController) {
        ErrorHandling.defaultError(ErrorTitle, desc: error.localizedDescription, sender: sender)
    }
    static func defaultError(_ error: NSError, sender: UIViewController) {
        ErrorHandling.defaultError(ErrorTitle, desc: error.localizedDescription, sender: sender)
    }
    static func defaultError(_ error: NSError, sender: UIViewController, completion: ClosureVoid?) {
        _ = ErrorHandling.displayAlert(ErrorTitle, desc: error.localizedDescription, sender: sender, completion: completion)
    }
    static func defaultError(_ title: String, desc: String, sender: UIViewController) {
        _ = displayAlert(title, desc: desc, sender: sender, completion: nil)
    }
    static func displayAlert(_ title: String, desc: String, sender: UIViewController, completion: ClosureVoid?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: desc, preferredStyle: UIAlertControllerStyle.alert)
        var handler: ((UIAlertAction) -> Void)?
        if let completion = completion {
            handler = {(UIAlertAction) -> Void in
                completion()
            }
        }
        else
        {
            handler = nil
        }
        
        alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.default, handler: handler))
        
        
        OperationQueue.main.addOperation {
            sender.present(alert, animated: true, completion: {
                
            })
        }
        return alert
    }
    
}
