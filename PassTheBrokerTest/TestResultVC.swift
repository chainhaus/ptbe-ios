/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit

class TestResultVC: UIViewController {
    
    let app = (UIApplication.shared.delegate as? AppDelegate)
    
//    MARK: - variable

    var testScore : NSInteger = 0
    var arrUAns: NSMutableArray = []
    
    @IBOutlet weak var imgAd: UIImageView!
    @IBOutlet weak var btnAD: UIButton!
    
    
//    MARK: - IBOutlet
    
    @IBOutlet weak var lblTestScore: UILabel!
    
   
//    MARK: - Methods

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTestScore.text = "\(testScore) %"
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showAdImag), userInfo: nil, repeats: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAdImag() {
        
        print("AD : \((UserDefaults.standard.value(forKey: "adImage") as? String))")
        if (UserDefaults.standard.value(forKey: "adImage") as? String) == nil {
            btnAD.isEnabled = false
        }
        else {
            btnAD.isEnabled = true
            imgAd.load.request(with: URL(string: UserDefaults.standard.value(forKey: "adImage") as! String)!)
        }
    }

    
//    MARK: - Action Methods
    
    @IBAction func btnReviewResult(_ sender: Any) {
        let thvc = storyboard?.instantiateViewController(withIdentifier: "TestHistoryVC") as! TestHistoryVC
        thvc.showReview = 1
        thvc.arrUserAnswer = self.arrUAns
        navigationController?.pushViewController(thvc, animated: true)
    }
    
    @IBAction func btnNewTest(_ sender: Any) {
        let ctvc = storyboard?.instantiateViewController(withIdentifier: "ChoiceTestVC") as! ChoiceTestVC
        navigationController?.pushViewController(ctvc, animated: true)
    }
    
    @IBAction func btnShowAd(_ sender: Any) {
        let strUrl = (UserDefaults.standard.value(forKey: "adURL") as! String)
        UIApplication.shared.openURL(URL(string: strUrl)!)
    }
    
//    func showAlert(msg:String)  {
//        let alert = UIAlertController(title: "PassTheBrokerExam", message: msg, preferredStyle: .alert)
//        
//        let OkAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
//            
//        }
//        alert.addAction(OkAction)
//        self.present(alert, animated: true, completion: nil)
//    }

}
