/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit
import MBProgressHUD

class LoginVC: UIViewController {
    
    var skipToRegister = false
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var emailTextField: VMFloatLabelTextField!
    @IBOutlet weak var passwordTextField: VMFloatLabelTextField!
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tf: UITextField in [emailTextField,
                                passwordTextField] {
                                    tf.showBottomBorder()
        }
        
        if skipToRegister {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC {
                vc.openedFromLogin = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        Event.shared.onCloseRegistration { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                print("onCloseRegistration skipToRegister = \(self.skipToRegister)")
                if self.skipToRegister {
                    Event.shared.openMain()
                } else {
                    // pop to self
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        Event.shared.onRegistered { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                // pop to self
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Action Methods
    
    private func isValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let match = emailTest.evaluate(with: email)
        
        return match
    }
    
    @IBAction func login() {
        var errorString: String?
        
        if emailTextField.text == "" {
            errorString = "Please enter your e-mail"
        } else if !isValid(email: emailTextField.text!) {
            errorString = "Please enter valid e-mail"
        } else if (emailTextField.text?.characters.count)! > 254 {
            errorString = "Too long e-mail address"
        } else if passwordTextField.text == "" {
            errorString = "Please enter your password"
        } else if (passwordTextField.text?.characters.count)! > 15 {
            errorString = "Password shouldn't be longer than 15 digits"
        } else if (passwordTextField.text?.characters.count)! < 6 {
            errorString = "Password should be minimum 6 digits long"
        }
        
        if let errorString = errorString {
            UIAlertController.show(okAlertIn: self,
                                   withTitle: "Warning",
                                   message: errorString)
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        Api.shared.login(email: emailTextField.text!, password: passwordTextField.text!) {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let errorString = $1 {
                // failed to log in
                UIAlertController.show(okAlertIn: self, withTitle: "Warning", message: errorString)
            } else {
                // logged in
                Event.shared.login()
            }
        }
    }
    
    @IBAction func openMenu() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "MenuVC") {
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func register() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func restorePassword() {
        let alert = UIAlertController(title: "Restore password",
                                      message: "We will send you restoration link to your e-mail address",
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "E-mail" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
            if let email = alert.textFields?[0].text {
                
                if email == "" || !self.isValid(email: email) {
                    UIAlertController.show(okAlertIn: self, withTitle: "Warning", message: "Enter valid e-mail") {
                        self.restorePassword()
                    }
                    return
                }
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                Api.shared.resetPassword(for: email, callback: {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if let errorString = $1 {
                        // failed to restore password
                        UIAlertController.show(okAlertIn: self, withTitle: "Warning", message: errorString)
                    } else {
                        // successfully sent email
                        UIAlertController.show(okAlertIn: self,
                                               withTitle: "Congratulations",
                                               message: "An URL to restore your password was just sent to your e-mail address")
                    }
                })
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
