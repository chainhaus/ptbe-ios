/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit

class SettingVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    let app = (UIApplication.shared.delegate as? AppDelegate)
    
//    MARK: - Variable
    var arrTitle:NSMutableArray = ["Change Password","Restore Purchase"]
    var arrSubTitle:NSMutableArray = ["Untill not change password","Get back your parchase"]
    var arrImg:NSMutableArray = ["change-passwrd.png","restore.png"]
    
//    MARK: - IBOutlet
    @IBOutlet weak var tblSetting: UITableView!
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func resetPsw() {
        
//        let rechability = Reachability()
        
//        if rechability?.isReachable == true {
            print("rechable")
            let strURL = "\((app?.strService)! as String)resetPassword"
            
            let url:NSURL = NSURL(string: strURL)!
            let session = URLSession.shared
            let urlReq = NSMutableURLRequest(url: url as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
            urlReq.httpMethod = "GET"
            
            urlReq.setValue("abc123", forHTTPHeaderField: "API_KEY")
            urlReq.setValue("\(UserDefaults.standard.value(forKey: "userEmail") as! String)", forHTTPHeaderField: "EMAIL_KEY")
            urlReq.setValue("\(UserDefaults.standard.value(forKey: "sessionKey") as! String)", forHTTPHeaderField: "SESSION_KEY")
            
            // make the request
            let task = session.dataTask(with: urlReq as URLRequest, completionHandler: { (data, response, error) in
                // do stuff with response, data & error here
                print(error ?? "")
                print(response ?? "NO Response")
                
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSMutableDictionary
                    
                    print("Response : \(jsonDict)")
                    if jsonDict.isEqual(nil) {
                        print("Error :\(error?.localizedDescription ?? "none")")
                    }
                    else {
                        DispatchQueue.main.async {
                            if  (jsonDict["errorCode"] as! NSInteger) < 0 {
                                UIAlertController.show(okAlertIn: self,
                                                       withTitle: "Warning",
                                                       message: "Failed to sent email")
                            }
                            else {
                                UIAlertController.show(okAlertIn: self,
                                                       withTitle: "Warning",
                                                       message: (jsonDict["status"] as? String?)!)
                            }
                            
                        }
                    }
                }
                catch {
                    return
                }
            })
            task.resume()
            
//        }
//        else {
//            print("not rechable")
//            UIAlertController.show(okAlertIn: self,
//                                   withTitle: "Warning",
//                                   message: "Make sure your device is connected to the internet.")
//        }
    }

    
//    MARK: - Action Methods
    
    @IBAction func btnMenu(_ sender: Any) {
        let mvc = storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        navigationController?.pushViewController(mvc, animated: false)
    }
    
    @IBAction func btnLogOut(_ sender: Any) {
        Event.shared.logout()
    }
    
//    MARK: - Table View Delegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingCell
        
        cell.BGView.layer.cornerRadius = 10
        cell.BGView.layer.borderColor = UIColor.gray.cgColor
        cell.BGView.layer.borderWidth = 1
        
        cell.lblTitle.text = arrTitle[indexPath.row] as? String
        cell.lblSubTitle.text = arrSubTitle[indexPath.row] as? String
        
        cell.imgTitle.image = UIImage(named: (arrImg[indexPath.row] as? String)!)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            resetPsw()
        }
    }
}

class SettingCell : UITableViewCell {
    
    @IBOutlet weak var BGView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var imgTitle: UIImageView!
}
