/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit
import MBProgressHUD

class LoginVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var txtFieldUsrName: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldPsw: VMFloatLabelTextField!
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tf: UITextField in [txtFieldUsrName,
                                txtFieldPsw] {
                                    tf.showBottomBorder()
        }
        
        if Settings.shared.userEmail != nil && Settings.shared.sessionKey != nil {
            proceedToApp(animated: false)
            return
        }
    }
    
    func proceedToApp(animated: Bool) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChoiceTestVC") {
            self.navigationController?.pushViewController(vc, animated: animated)
        }
    }
    
    func login() {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        Api.shared.login(email: txtFieldUsrName.text!, password: txtFieldPsw.text!) {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let errorString = $1 {
                // failed to log in
                UIAlertController.show(okAlertIn: self, withTitle: "Warning", message: errorString)
            } else {
                // logged in
                self.proceedToApp(animated: true)
            }
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnLogin(_ sender: UIButton) {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let match = emailTest.evaluate(with: txtFieldUsrName.text)
        
        var errorString: String?
        
        if txtFieldUsrName.text == "" || txtFieldPsw.text == "" {
            errorString = "Please enter all fields"
        } else if match == false {
            errorString = "Please enter valid email"
        }
        
        if let errorString = errorString {
            UIAlertController.show(okAlertIn: self,
                                   withTitle: "Warning",
                                   message: errorString)
        } else {
            login()
        }
    }
    
    @IBAction func btnSignUp(_ sender: UIButton) {
        if let rvc = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") {
            navigationController?.pushViewController(rvc, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
