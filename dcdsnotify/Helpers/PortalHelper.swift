//
//  PortalHelper.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 9/8/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit
class PortalHelper {

    //returns true if logged in, false if not, nil if unknown page
	static func checkLoggedIn(htmlString: String) -> Bool? {
		let tempLoginCheck = htmlString.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit")
        guard tempLoginCheck != nil else {
            return nil
        }
        let loginCheck = tempLoginCheck!
		if loginCheck == "Member Login" {
			return false
		}
		else if loginCheck == "STUDENT PORTAL" {
			//TODO: check for parents too
			return true
		}
        else if loginCheck == "Academics Individual Classes Calendar" {
            return true
        }
		return nil
	}
    static func checkResponse(data: NSData?, response: NSURLResponse?, error: NSError?, sender: UIViewController) -> String?
    {
        guard error?.code != -999 else {
            //cancelled task
            return nil
        }
        guard error == nil && data != nil else {// check for fundamental networking error
            if error?.code == -1009 {
                print("no internet")//dealing with offline

                ErrorHandling.defaultError(error!, sender: sender)

                return nil
            }
            print("\(error)")
            ErrorHandling.defaultError("Network Error", desc: (error?.localizedDescription)!, sender: sender)
            return nil
        }

        if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            if httpStatus.statusCode == 404{
                print("response = \(response)")
                ErrorHandling.defaultError("Network Error", desc: "Page not found", sender: sender)
                return nil
            }
            else if httpStatus.statusCode == 403 {
                print("response = \(response)")
                ErrorHandling.defaultError("Network Error", desc: "Unauthorized Access", sender: sender)
                return nil
            }
        }
        
        return NSString(data: data!, encoding: NSUTF8StringEncoding) as String!

    }
}
