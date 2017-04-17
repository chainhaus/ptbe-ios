/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit



class TestHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let app = (UIApplication.shared.delegate as? AppDelegate)
    
    @IBOutlet weak var imgAD: UIImageView!
    var arrUserAnswer: NSMutableArray = []
    
    var arrTest:NSMutableArray = []
    let arrDate:NSMutableArray = ["30 March 6:30 PM","24 March 8:30 PM","18 March 10:30 AM"]
    let arrTestScore:NSMutableArray = ["95%","56%","33%"]
    
    @IBOutlet weak var btnAD: UIButton!
    
    var arrMainData:NSMutableArray = []
    var showReview:NSInteger = 0
    
    
//    MARK: - IBOutlet
    
    @IBOutlet weak var tblHistory: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var actInd_THistory: UIActivityIndicatorView!
    
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actInd_THistory.frame = CGRect(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2, width: 70, height: 70)
        actInd_THistory.center = self.view.center
        actInd_THistory.layer.cornerRadius = 10
        actInd_THistory.startAnimating()
        
        
        if showReview == 1 {
            lblTitle.text = "Review Result"
            tblHistory.isHidden = false
            
        }
        else {
            lblTitle.text = "Test History"
            actInd_THistory.stopAnimating()
            if (UserDefaults.standard.value(forKey: "TestHistory")) == nil  {
                tblHistory.isHidden = true
            }
            else {
                arrTest = (UserDefaults.standard.value(forKey: "TestHistory") as! NSArray).mutableCopy() as! NSMutableArray
                
                tblHistory.reloadData()
                
                tblHistory.isHidden = false
                if arrTest.count == 0 {
                    tblHistory.isHidden = true
                }
            }
        }
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showAdImag), userInfo: nil, repeats: false)
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showQuestion), userInfo: nil, repeats: false)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bottomBorder(txtField:UILabel) {
        let border = CALayer()
        let width = CGFloat(2.0)
        
        border.borderColor = UIColor.orange.cgColor

        border.frame = CGRect(x: 0, y: txtField.frame.size.height - width, width:  txtField.frame.size.width, height: txtField.frame.size.height)
        
        border.borderWidth = width
        txtField.layer.addSublayer(border)
        txtField.layer.masksToBounds = true
    }
    
    func showAdImag() {
        
        print("AD : \((UserDefaults.standard.value(forKey: "adImage") as? String))")
        if (UserDefaults.standard.value(forKey: "adImage") as? String) == nil {
            btnAD.isEnabled = false
        }
        else {
            btnAD.isEnabled = true
            imgAD.load.request(with: URL(string: UserDefaults.standard.value(forKey: "adImage") as! String)!)
        }
    }
    
    func showQuestion() {
        self.actInd_THistory.stopAnimating()
//        self.arrMainData = UserDefaults.standard.value(forKey: "oldData") as! NSMutableArray
        print("Response : \(self.arrMainData)")
        self.tblHistory.reloadData()
    }
    
    func showAlert(msg:String)  {
        let alert = UIAlertController(title: "PassTheBrokerExam", message: msg, preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            
        }
        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }

    
//    MARK: - Action Methods
    
    @IBAction func btnMenu(_ sender: Any) {
        let mvc = storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        navigationController?.pushViewController(mvc, animated: false)
    }
    
    @IBAction func btnShowAd(_ sender: Any) {
        let strUrl = (UserDefaults.standard.value(forKey: "adURL") as! String)
        UIApplication.shared.openURL(URL(string: strUrl)!)
    }
//    MARK: - Table View Delegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showReview == 1 {
            return arrUserAnswer.count
        }
        return arrTest.count
    }
    
//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if showReview == 1 {
//            return 100.0
//        }
//        return 68.0
//    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell")! as! HistoryCell

        if showReview == 1 {
            
            if self.arrUserAnswer.count == 0 {
                return cell
            }
            
            let dict:NSDictionary = arrUserAnswer[indexPath.row] as! NSDictionary
            
            cell.historyView.isHidden = true
            cell.answerView.isHidden = false
            
//            cell.answerView.layer.cornerRadius = 10
//            cell.answerView.layer.borderWidth = 1
//            cell.answerView.layer.borderColor = UIColor.black.cgColor
            
            cell.lblQuestion.text = dict.value(forKey: "question") as? String
            cell.lblQuestion.adjustsFontSizeToFitWidth = true
            bottomBorder(txtField: cell.lblQuestion)

            
            let option:Int = dict.value(forKey: "answer") as! Int
            
            cell.lblAnswer.text = "Ans: \((dict.value(forKey: "choice\(option)")) as! String)"
            cell.lblAnswer.adjustsFontSizeToFitWidth = true
            bottomBorder(txtField: cell.lblAnswer)

//            if arrUserAnswer.count == 0 {
//                cell.lblUserAns.text = "Your Ans: \(dict.value(forKey: "choice\(option)") as! String) "
//                cell.lblUserAns.adjustsFontSizeToFitWidth = true
//            }
//            else {
//                if indexPath.row < arrUserAnswer.count {
//                    print("\(indexPath.row)")
//                    print("UserAns : \(arrUserAnswer)")
//                    let userOption:Int = arrUserAnswer[indexPath.row] as! Int
////                    cell.lblUserAns.text = "Your Ans :\(dict.value(forKey: "choice\(userOption)") as! String)"
////                    cell.lblUserAns.adjustsFontSizeToFitWidth = true
//                }
//            }
        }
        
        else {

            cell.historyView.isHidden = false
            cell.answerView.isHidden = true
            
            let dictShow = arrTest[indexPath.row] as! NSDictionary
            
            print("dict : \(dictShow)")
            
            cell.historyView.layer.cornerRadius = 10
            
            cell.lblTestName.text = "\(dictShow["Test"]!)"
            cell.lblDateTime.text = dictShow["Time"] as? String
            cell.lblTestScore.text = "\(dictShow["Score"]!)%"
        }

        return cell
    }

}

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var lblTestName: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblTestScore: UILabel!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var lblUserAns: UILabel!
    
}

