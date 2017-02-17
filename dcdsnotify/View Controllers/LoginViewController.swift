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

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()

        PasswordTextField.returnKeyType = .go

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if UsernameTextField.isFirstResponder
        {
            PasswordTextField.becomeFirstResponder()
            return true
        }
        else if PasswordTextField.isFirstResponder
        {
            PasswordTextField.resignFirstResponder()
            onLoginButtonTap(self)
            return true
        }
        return false
    }


    override func viewDidAppear(_ animated: Bool) {
        if let login = CacheHelper.sharedInstance.retrieveLogin() {
            UsernameTextField.text = login.username
            PasswordTextField.text = login.password
            hwLogin()
        }

    }

    @IBAction func viewTapped(_ sender: AnyObject) {

        self.UsernameTextField.resignFirstResponder()
        self.PasswordTextField.resignFirstResponder()

    }

    override func didReceiveMemoryWarning() {
        self.UsernameTextField.text = ""
        self.PasswordTextField.text = ""
    }

    @IBAction func onLoginButtonTap(_ sender: AnyObject) {

        guard UsernameTextField.text != "" || PasswordTextField.text != "" else {
            print("empty text")
            ErrorHandling.defaultError("Invalid Username/Password", desc: "You must enter a username/password", sender: self)
            return

        }
        hwLogin()
    }
    func loggedIn(username: String, password: String) {
        let creds = (username, password)
        AppState.sharedInstance.credentials = creds
        CacheHelper.sharedInstance.storeLogin(creds)
        self.performSegue(withIdentifier: Constants.Segues.LoginToHomeworkView, sender: self)
        
    }
    func hwLogin()
    {
        let login: Credentials = (self.UsernameTextField.text!, self.PasswordTextField.text!)
        //login if cache exists
        if let cacheLogin = CacheHelper.sharedInstance.retrieveLogin(), cacheLogin == login {
            //if cache data matches entered, 'login' and show data

            OperationQueue.main.addOperation {
                self.loggedIn(username: login.username, password: login.password)
            }
            return
        }
        activityIndicator.startAnimating()

        var request = URLRequest(url: Constants.userLoginURL as URL)
        request.httpMethod = "POST"
        let postString = "do=login&p=413&username=\(UsernameTextField.text!)&password=\(PasswordTextField.text!)&submit=login"
        request.httpBody = postString.data(using: String.Encoding.utf8)

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error3: Error?) in
            
            let error = error3 as? NSError
            
            OperationQueue.main.addOperation {
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
                    ErrorHandling.defaultError(error!, sender: self)
                    return
                }
                else {
                    ErrorHandling.defaultError(error!, sender: self)
                    return
                }
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                return
            }

            //MARK: Login Check
            //data has been checked for nil
            let urlContentString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) ?? "" as NSString
            let loginCheck = urlContentString.cropExclusive("<meta name=\"description\" content=\"", end: " - Detroit")
            guard loginCheck == "STUDENT PORTAL" else {
                //TODO: check for parents too
                print("Failed Login")
                ErrorHandling.defaultError("Invalid Username/Password", desc: "Please enter a valid username and password combination", sender: self)
                return
            }
            OperationQueue.main.addOperation {
                self.loggedIn(username: login.username, password: login.password)
            }
        }) 
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.UsernameTextField.text = ""
        self.PasswordTextField.text = ""

        if segue.identifier == Constants.Segues.LoginToHomeworkView
        {
            print("seguing to HomeworkViewController")
            let nav = segue.destination as? UINavigationController
            let vc = nav?.topViewController as? HomeworkViewController
            guard vc != nil else {
                ErrorHandling.defaultError("Bug!", desc: "Improper segue - \(segue.identifier)", sender: self)
                return
            }


            vc!.activitiesDay = Day(date: Date())

        }
        
    }
}

