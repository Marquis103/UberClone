//
//  ViewController.swift
//  UberClone
//
//  Created by Marquis Dennis on 12/20/15.
//  Copyright © 2015 Marquis Dennis. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var btnSignUpToggle: UIButton!
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var driverSwitch: UISwitch!
    @IBOutlet var lblRider: UILabel!
    @IBOutlet var lblDriver: UILabel!
    
    //signup state
    var signupState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        username.delegate = self
        password.delegate = self
        
        //Looks for single or multiple taps.
        //registers gesture handler to dismiss keyboard on away tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actionToggleSignup(sender: AnyObject) {
        if signupState == true {
            btnSignUp.setTitle("Log In", forState: UIControlState.Normal)
            btnSignUpToggle.setTitle("Switch to Signup", forState: UIControlState.Normal)
            signupState = false
            
            lblRider.alpha = 0
            driverSwitch.alpha = 0
            lblDriver.alpha = 0
            
        } else {
            btnSignUp.setTitle("Sign Up", forState: UIControlState.Normal)
            btnSignUpToggle.setTitle("Switch to login", forState: UIControlState.Normal)
            signupState = true
            
            lblRider.alpha = 1
            driverSwitch.alpha = 1
            lblDriver.alpha = 1
        }
    }

    @IBAction func actionLogin(sender: AnyObject) {
        if username.text == "" || password.text == "" {
            createAlert("Missing Field(s)", message: "Username and password are required")
        } else {
            //sign up user to parse
            
            if signupState == true {
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                
                user["isDriver"] = driverSwitch.on
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if let error = error {
                        if let errorString = error.userInfo["error"] as? NSString {
                            self.createAlert("Signup Failed", message: errorString as String)
                        }
                    } else {
                        if self.driverSwitch.on {
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                        } else {
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        }
                    }
                }
            } else {
                //login user
                
                PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if let user = user {
                        if user["isDriver"]! as! Bool == true {
                            self.performSegueWithIdentifier("loginDriver", sender: self)
                        } else {
                            self.performSegueWithIdentifier("loginRider", sender: self)
                        }
                    } else {
                        if let errorString = error?.userInfo["error"] as? String {
                            self.createAlert("Login Failed", message: errorString)
                        }
                    }
                }
            }
        }
    }
    
    func createAlert(title: String, message: String) {
        //want to display a message to the user
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //segue before the view is loaded
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            if PFUser.currentUser()?["isDriver"]! as! Bool == true {
                performSegueWithIdentifier("loginDriver", sender: self)
            } else {
                performSegueWithIdentifier("loginRider", sender: self)
            }
        }
    }
}

extension ViewController : UITextFieldDelegate {
    
}

