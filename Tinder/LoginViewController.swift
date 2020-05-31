//
//  LoginViewController.swift
//  Tinder
//
//  Created by Partha Sarathy on 5/31/20.
//  Copyright © 2020 Partha Sarathy. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    var signupMode: Bool = false
    
   
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginSignupButton: UIButton!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var changeloginSignupButton: UIButton!
    
    @IBAction func loginSignupTapped(_ sender: Any) {
        if signupMode {
            let user = PFUser()
            
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            
            user.signUpInBackground { (success, error) in
                if error != nil {
                    var errorMessage = "Signup failed"
                    if let safeError = error {
                        if let newerror = safeError as? NSError {
                            if let detailError = newerror.userInfo["error"] as? String {
                                errorMessage = detailError
                            }
                        }
                         self.errorLabel.textColor = .red
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = errorMessage
                    }
                } else {
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = "Successfully Created User"
                    self.errorLabel.textColor = .green
                    self.performSegue(withIdentifier: "updateSegue", sender: self)
                }
            }
        } else {
            if let username = usernameTextField.text, let password = passwordTextField.text {
                PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
                    if error != nil {
                              var errorMessage = "Login failed"
                              if let safeError = error {
                                  if let newerror = safeError as? NSError {
                                      if let detailError = newerror.userInfo["error"] as? String {
                                          errorMessage = detailError
                                      }
                                  }
                                self.errorLabel.textColor = .red
                                  self.errorLabel.isHidden = false
                                  self.errorLabel.text = errorMessage
                              }
                          } else {
                              self.errorLabel.isHidden = false
                              self.errorLabel.text = "Login Succesfull"
                              self.errorLabel.textColor = .green
                        if user?["isFemale"] != nil {
                                        self.performSegue(withIdentifier: "loginToSwipingSegue", sender: nil)
                                    } else {
                                        self.performSegue(withIdentifier: "updateSegue", sender: nil)
                                    }
                          }
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            if PFUser.current()?["isFemale"] != nil {
                self.performSegue(withIdentifier: "loginToSwipingSegue", sender: nil)
            } else {
                self.performSegue(withIdentifier: "updateSegue", sender: nil)
            }
        }
    }
    
    
    @IBAction func changeLoginSignupTapped(_ sender: Any) {
        
        if signupMode {
            loginSignupButton.setTitle("Login", for: .normal)
            changeloginSignupButton.setTitle("Signup", for: .normal)
            signupMode = false
        } else {
            loginSignupButton.setTitle("Signup", for: .normal)
            changeloginSignupButton.setTitle("Login", for: .normal)
            signupMode = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
}
