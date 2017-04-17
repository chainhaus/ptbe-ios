/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit


//import VMFloatLabelTextField

class ViewController: UIViewController,UITextFieldDelegate {
    
    let app = (UIApplication.shared.delegate as? AppDelegate)
    
    
//    MARK: - IBOutlet
    
    @IBOutlet weak var txtFieldUsrName: VMFloatLabelTextField!
    @IBOutlet weak var txtFieldPsw: VMFloatLabelTextField!
    
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showBottomBorder(txtF: txtFieldUsrName)
        showBottomBorder(txtF: txtFieldPsw)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginService() {
        let headers = [
            "api_key": "abc123",
            "content-type": "application/x-www-form-urlencoded",
        ]
        
        let postData = NSMutableData(data: "email=\(txtFieldUsrName.text! as String)".data(using: String.Encoding.utf8)!)
        postData.append("&password=\(txtFieldPsw.text! as String)".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: "\((app?.strService)! as String)authenticateUser") as! URL,
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
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSMutableDictionary
                    
                    
                    if jsonDict.isEqual(nil) {
                        print("Error :\(error)")
                    }
                    else {
                        DispatchQueue.main.async {
                            
                            
                            print("Response : \(jsonDict)")
                            
                            if jsonDict.value(forKey: "errorCode") as! Int == 0 {
                                
                                UserDefaults.standard.set(jsonDict.value(forKey: "sessionUUID"), forKey: "sessionKey")
                                UserDefaults.standard.set(self.txtFieldUsrName.text, forKey: "userEmail")
                                
//                                self.callAdService()
                                
                                let sqvc = self.storyboard?.instantiateViewController(withIdentifier: "ChoiceTestVC") as! ChoiceTestVC
                                self.navigationController?.pushViewController(sqvc, animated: true)
                                
//                                self.showAlert(msg: "Login successfully")
                            }
                            else {
                                
                                self.showAlert(msg: "\(jsonDict.value(forKey: "loginStatus") as! String)")
                        
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
    
//    func callAdService() {
//        let rechability = Reachability()
//        
//        if rechability?.isReachable == true {
//            print("rechable")
//            let strURL = "\((app?.strService)! as String)getAd"
//            
//            let url:NSURL = NSURL(string: strURL)!
//            let session = URLSession.shared
//            let urlReq = NSMutableURLRequest(url: url as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
//            urlReq.httpMethod = "GET"
//            
//            urlReq.setValue("abc123", forHTTPHeaderField: "API_KEY")
//            urlReq.setValue("\(UserDefaults.standard.value(forKey: "userEmail") as! String)", forHTTPHeaderField: "EMAIL_KEY")
//            urlReq.setValue("\(UserDefaults.standard.value(forKey: "sessionKey") as! String)", forHTTPHeaderField: "SESSION_KEY")
//            
//            // make the request
//            let task = session.dataTask(with: urlReq as URLRequest, completionHandler: { (data, response, error) in
//                // do stuff with response, data & error here
//                print(error ?? "")
//                print(response ?? "NO Response")
//                
//                do {
//                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSMutableDictionary
//                    
//                    print("Response : \(jsonDict)")
//                    if jsonDict.isEqual(nil) {
//                        print("Error :\(error)")
//                    }
//                    else {
//                        DispatchQueue.main.async {
//                            
//                        UserDefaults.standard.set(jsonDict.value(forKey: "adImageURL"), forKey: "adImage")
//                        UserDefaults.standard.set(jsonDict.value(forKey: "adClickURL"), forKey: "adURL")
//                            
//                        let sqvc = self.storyboard?.instantiateViewController(withIdentifier: "ChoiceTestVC") as! ChoiceTestVC
//                            self.navigationController?.pushViewController(sqvc, animated: true)
//                        }
//                    }
//                }
//                    
//                catch {
//                    print(error)
//                    return
//                }
//            })
//            
//            task.resume()
//            
//        }
//            
//        else {
//            print("not rechable")
//            showAlert(msg: "Make sure your device is connected to the internet.")
//        }
//
//    }

    
    func showBottomBorder(txtF:UITextField) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: txtF.frame.size.height - width, width:  txtF.frame.size.width, height: txtF.frame.size.height)
        
        border.borderWidth = width
        txtF.layer.addSublayer(border)
        txtF.layer.masksToBounds = true
    }
    
    func showAlert(msg:String)  {
        let alert = UIAlertController(title: "PassTheBrokerExam", message: msg, preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            
        }
        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }
    
// MARK: - Text Field Methods
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

// MARK: - Action Methods

    @IBAction func btnLogin(_ sender: UIButton) {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let match = emailTest.evaluate(with: txtFieldUsrName.text)
        
        if txtFieldUsrName.text == "" || txtFieldPsw.text == "" {
            showAlert(msg: "Please enter all fields")
        }
            
        else if match == false {
            showAlert(msg: "Please enter valid email")
        }
            
        else {
            
            loginService()
            
        }
    }
    
    @IBAction func btnSignUp(_ sender: UIButton) {
        let rvc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
}



