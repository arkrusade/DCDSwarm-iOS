//
//  LoginViewController.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    var login: Credentials? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        PasswordTextField.returnKeyType = .Go


    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if UsernameTextField.isFirstResponder()
        {
            PasswordTextField.becomeFirstResponder()
            return true
        }
        else if PasswordTextField.isFirstResponder()
        {
            PasswordTextField.resignFirstResponder()
            onLoginButtonTap(self)
            return true
        }
        return false
    }


    override func viewDidAppear(animated: Bool) {
        if let login = login {
            UsernameTextField.text = login.username
            PasswordTextField.text = login.password
            onLoginButtonTap(self)
        }

    }

    @IBAction func viewTapped(sender: AnyObject) {

        self.UsernameTextField.resignFirstResponder()
        self.PasswordTextField.resignFirstResponder()

    }

    override func didReceiveMemoryWarning() {
        login = nil
        self.UsernameTextField.text = ""
        self.PasswordTextField.text = ""
    }

    @IBAction func onLoginButtonTap(sender: AnyObject) {

        guard UsernameTextField.text != "" || PasswordTextField.text != "" else {
            print("empty text")
            ErrorHandling.defaultError("Invalid Username/Password", desc: "You must enter a username/password", sender: self)
            return

        }

        login = (self.UsernameTextField.text!, self.PasswordTextField.text!)
        //login if cache exists
        if let cacheLogin = CacheHelper.retrieveLogin(), let enteredLogin = login where cacheLogin == enteredLogin {
            //if has data, 'login' and show data
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier(Constants.Segues.LoginToHomeworkView, sender: self)
            }
            return
        }
        let url = Constants.userLoginURL
        activityIndicator.startAnimating()

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let postString = "do=login&p=413&username=\(UsernameTextField.text!)&password=\(PasswordTextField.text!)&submit=login"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in

            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.activityIndicator.stopAnimating()
            }
            guard error?.code != -999 else {
                //cancelled task
                return
            }
            guard error == nil || data != nil else {// check for fundamental networking error
                print("error=\(error == nil ? "\(error)" : "data is nil")")
                if error?.code == -1009 {
                    print("no internet")//dealing with offline

//                    else {
                        ErrorHandling.defaultError(error!, sender: self)

                        return
//                    }
                }
                else {
                    ErrorHandling.defaultError(error!, sender: self)
                    return
                }
            }

            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                return
            }

            //MARK: Login Check
            
            let urlContentString = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
            let loginCheck = try? (urlContentString.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit"))
            guard loginCheck == "STUDENT PORTAL" else {
                //TODO: check for parents too
                print("Failed Login")
                ErrorHandling.defaultError("Invalid Username/Password", desc: "Please enter a valid username and password combination", sender: self)
                return
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                CacheHelper.storeLogin(self.UsernameTextField.text!, password: self.PasswordTextField.text!)
                self.performSegueWithIdentifier(Constants.Segues.LoginToHomeworkView, sender: self)
            }
        }
        task.resume()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.UsernameTextField.text = ""
        self.PasswordTextField.text = ""
        login = nil

        if segue.identifier == Constants.Segues.LoginToHomeworkView
        {
            print("seguing to HomeworkViewController")
            let nav = segue.destinationViewController as? UINavigationController
            let vc = nav?.topViewController as? HomeworkViewController
            guard vc != nil else {
                ErrorHandling.defaultError("Bug!", desc: "Improper segue - \(segue.identifier)", sender: self)
                return
            }

            vc!.activitiesDay = Day(date: NSDate())

        }
        
    }
}

