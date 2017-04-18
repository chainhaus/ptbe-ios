/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import MBProgressHUD

class RegisterVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var txtFieldFirstName: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldConfPsw: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldPsw: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldEmail: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldLastName: VMFloatLabelTextField!
    
    @IBOutlet weak var btnSignUp: UIButton!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tf: UITextField in [txtFieldEmail,
                                txtFieldPsw,
                                txtFieldConfPsw,
                                txtFieldFirstName,
                                txtFieldLastName] {
            tf.showBottomBorder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardSize.height
//            }
//        }
//    }
    
    
    func register() {
        MBProgressHUD.showAdded(to: view, animated: true)
        Api.shared.register(email: txtFieldEmail.text!, password: txtFieldConfPsw.text!, firstName: txtFieldFirstName.text!, lastName: txtFieldLastName.text!) {
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

    // MARK: - Action Methods

    @IBAction func btnSignUpPress(_ sender: Any) {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let match = emailTest.evaluate(with: txtFieldEmail.text)
        
        var errorString: String?
        
        if txtFieldPsw.text == "" ||
            txtFieldEmail.text == "" ||
            txtFieldConfPsw.text == "" ||
            txtFieldLastName.text == "" ||
            txtFieldFirstName.text == "" {
            
            errorString = "Please enter all fields"
        } else if !match {
            errorString = "Please enter valid email"
        } else if txtFieldPsw.text != txtFieldConfPsw.text {
            errorString = "Please enter Currect Password"
        }
        
        if let errorString = errorString {
            UIAlertController.show(okAlertIn: self,
                                   withTitle: "Warning",
                                   message: errorString)
        } else {
            register()
        }
    }
    
    @IBAction func btnGoToLogIn(_ sender: Any) {
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
