/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit

class MenuVC: UIViewController {
    
    let app = (UIApplication.shared.delegate as? AppDelegate)
    
//    MARK: - IBOutlet
    
    @IBOutlet weak var lblVersion: UILabel!
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        
        lblVersion.text = "Version : \(UserDefaults.standard.value(forKey: "AppVersion") as! NSInteger)"
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func showAlert(msg:String)  {
        let alert = UIAlertController(title: "PassTheBrokerExam", message: msg, preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            
        }
        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }
    
//    MARK: - Action Methods
    
    @IBAction func btnClose(_ sender: Any) {
        _ = navigationController?.popViewController(animated: false)
    }
    
    @IBAction func btnGoToTestMenu(_ sender: Any) {
        let ctvc = storyboard?.instantiateViewController(withIdentifier: "ChoiceTestVC") as! ChoiceTestVC
        navigationController?.pushViewController(ctvc, animated: false)
        
    }
    
    @IBAction func btnTestHistory(_ sender: Any) {
        let thvc = storyboard?.instantiateViewController(withIdentifier: "TestHistoryVC") as! TestHistoryVC
        navigationController?.pushViewController(thvc, animated: false)
    }
    
    @IBAction func btnSetting(_ sender: Any) {
        let svc = storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        navigationController?.pushViewController(svc, animated: false)
    }
    
    @IBAction func btnLogOut(_ sender: Any) {
        
        UserDefaults.standard.set("", forKey: "sessionKey")
        UserDefaults.standard.set("", forKey: "userEmail")
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        navigationController?.pushViewController(vc, animated: false)
    }
    
}
