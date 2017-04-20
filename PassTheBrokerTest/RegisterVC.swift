/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import MBProgressHUD

class RegisterVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var firstNameTextField: VMFloatLabelTextField!
    @IBOutlet weak var lastNameTextField: VMFloatLabelTextField!
    @IBOutlet weak var emailTextField: VMFloatLabelTextField!
    @IBOutlet weak var passwordTextField: VMFloatLabelTextField!
    @IBOutlet weak var confirmPasswordTextField: VMFloatLabelTextField!
    
    @IBOutlet weak var btnSignUp: UIButton!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tf: UITextField in [emailTextField,
                                passwordTextField,
                                confirmPasswordTextField,
                                firstNameTextField,
                                lastNameTextField] {
            tf.showBottomBorder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Action Methods

    @IBAction func register() {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let match = emailTest.evaluate(with: emailTextField.text)
        
        var errorString: String?
        
        if emailTextField.text == "" {
            errorString = "Please enter your e-mail"
        } else if !match {
            errorString = "Please enter valid e-mail"
        } else if (emailTextField.text?.characters.count)! > 254 {
            errorString = "Too long e-mail address"
        } else if passwordTextField.text == "" {
            errorString = "Please enter your password"
        } else if (passwordTextField.text?.characters.count)! > 15 {
            errorString = "Password shouldn't be longer than 15 digits"
        } else if (passwordTextField.text?.characters.count)! < 6 {
            errorString = "Password should be minimum 6 digits long"
        } else if passwordTextField.text != confirmPasswordTextField.text {
            errorString = "Passwords do not match"
        } else if firstNameTextField.text == "" {
            errorString = "Please enter your first name"
        } else if lastNameTextField.text == "" {
            errorString = "Please enter your last name"
        }
        
        if let errorString = errorString {
            UIAlertController.show(okAlertIn: self,
                                   withTitle: "Warning",
                                   message: errorString)
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        Api.shared.register(email: emailTextField.text!, password: confirmPasswordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let errorString = $1 {
                UIAlertController.show(okAlertIn: self,
                                       withTitle: "Warning",
                                       message: errorString)
            } else {
                UIAlertController.show(okAlertIn: self,
                                       withTitle: "Congratulations",
                                       message: "Signed up successfully",
                                       callback: {
                                        self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension RegisterVC: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
