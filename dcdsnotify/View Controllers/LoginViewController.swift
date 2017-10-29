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
            onLoginButtonTap(self)
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
        
        var request = URLRequest(url: Constants.invalidLoginURL as URL)
        request.httpMethod = "POST"
        let postString = "do=login&p=413&username=\(UsernameTextField.text!)&password=\(PasswordTextField.text!)&submit=login"
        request.httpBody = postString.data(using: String.Encoding.utf8)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//       request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("\(postString.characters.count)", forHTTPHeaderField: "Content-Length")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error3: Error?) in
            
            let error = error3 as? NSError
            
            OperationQueue.main.addOperation {
                self.activityIndicator.stopAnimating()
            }
            guard error?.code != -999 else {
                //cancelled task
                return
            }
            guard error == nil || data != nil else 	{// check for fundamental networking error
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
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 302 && httpStatus.statusCode != 200{ // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                return
            }
            
            //MARK: Login Check
            //data has been checked for nil
            let urlContentString = String(data: data!, encoding: String.Encoding.utf8) ?? ""
            if let loginCheck = PortalHelper.checkLoggedIn(urlContentString) {
                guard loginCheck else {
                    print("Failed Login")
                    ErrorHandling.defaultError("Invalid Username/Password", desc: "Please enter a valid username and password combination", sender: self)
                    return
                }
            } else {
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
    func loggedIn(username: String, password: String) {//TODO: figure out how to make hwview present alert
        self.UsernameTextField.text = ""
        self.PasswordTextField.text = ""
        
        
        let login: Credentials = (username, password)
        let main = UIStoryboard.init(name: "Main", bundle: nil)
        if let nav = main.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.Navigation) as? UINavigationController{
            if (nav.topViewController as? HomeworkViewController) != nil{
                
                self.present(nav, animated: true, completion: ({
                    AppState.sharedInstance.login(login: login, sender: nav)
                }))
            }
        }
        else {
            ErrorHandling.defaultError("Bug!", desc: "Improper segue", sender: self)
            return
        }
        
        
    }
    
}

