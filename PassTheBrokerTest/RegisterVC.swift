/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit

class RegisterVC: UIViewController,UITextFieldDelegate {
    
    var jsonDict:NSMutableDictionary = [:]
    let app = (UIApplication.shared.delegate as? AppDelegate)
    
//    MARK: - IBOutlet
    
    @IBOutlet weak var txtFieldFirstName: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldConfPsw: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldPsw: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldEmail: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldLastName: VMFloatLabelTextField!
    
    @IBOutlet weak var btnSignUp: UIButton!
    
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showBottomBorder(txtF: txtFieldPsw)
        showBottomBorder(txtF: txtFieldConfPsw)
        showBottomBorder(txtF: txtFieldFirstName)
        showBottomBorder(txtF: txtFieldLastName)
        showBottomBorder(txtF: txtFieldEmail)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showAlert(msg:String)  {
        let alert = UIAlertController(title: "PassTheBrokerExam", message: msg, preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            
        }
        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showBottomBorder(txtF:UITextField) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: txtF.frame.size.height - width, width:  txtF.frame.size.width, height: txtF.frame.size.height)
        
        border.borderWidth = width
        txtF.layer.addSublayer(border)
        txtF.layer.masksToBounds = true
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
    
    
    func service() {
        let headers = [
            "api_key": "abc123",
            "content-type": "application/x-www-form-urlencoded", // this should be moved outside of the view - jamiel
            "cache-control": "no-cache"
        ]
        
        print("Email : \(txtFieldEmail.text)")
        
        let postData = NSMutableData(data: "email=\(txtFieldEmail.text! as String)".data(using: String.Encoding.utf8)!)
        postData.append("&password=\(txtFieldConfPsw.text! as String)".data(using: String.Encoding.utf8)!)
        postData.append("&fname=\(txtFieldFirstName.text! as String)".data(using: String.Encoding.utf8)!)
        postData.append("&lname=\(txtFieldLastName.text! as String)".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: "\((app?.strService)! as String)submitSignUp")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "defult")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "default")
                
                do {
                   self.jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSMutableDictionary
                    
                    
                    if self.jsonDict.isEqual(nil) {
                        print("Error :\(error)")
                    }
                    else {
                        DispatchQueue.main.async {
                            
                            
                            print("Response : \(self.jsonDict)")
                            
                            if self.jsonDict.value(forKey: "errorCode") as! Int == 0 {
                                
                                let sqvc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                self.navigationController?.pushViewController(sqvc, animated: true)
                                
                                self.showAlert(msg: "Sign up successfully")
                            }
                            else {
                                
                                self.showAlert(msg: "\(self.jsonDict.value(forKey: "registrationStatus") as! String)")
                            }
                        }
                    }
                    //                self.actInd_showQst.stopAnimating()
                }
                catch {
                    return
                }
                
            }
        })
        
        dataTask.resume()
    }
    

    
// MARK: - Text Field Methods
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
// MARK: - Action Methods
    

    @IBAction func btnSignUpPress(_ sender: Any) {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let match = emailTest.evaluate(with: txtFieldEmail.text)
        
        if txtFieldPsw.text == "" || txtFieldEmail.text == "" || txtFieldConfPsw.text == "" || txtFieldLastName.text == "" || txtFieldFirstName.text == "" {
            showAlert(msg: "Please enter all fields")
        }
            
        else if match == false {
            showAlert(msg: "Please enter valid email")
        }
            
        else {
            if txtFieldConfPsw.text != txtFieldPsw.text {
                showAlert(msg: "Please enter Currect Password")
            }
            else {

                service()

            }
        }
    }
    
    @IBAction func btnGoToLogIn(_ sender: Any) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//        self.navigationController?.pushViewController(vc, animated: true)
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
}
