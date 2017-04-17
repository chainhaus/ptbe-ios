/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit

class ShowQuestionVC: UIViewController {
    
    var choice:NSInteger = 0
    var crtQuestion:NSInteger = 0
    var rightAns:NSInteger = 0
    var jsonDict : NSMutableDictionary = [:]
    var arrMainData : NSMutableArray = []
    var arrUserAns : NSMutableArray = []
    var arrRandomQuestion : NSMutableArray = []
    var typeTest : NSInteger = 0
    var strTestName:NSString = ""
    
    let app = (UIApplication.shared.delegate as? AppDelegate)
   
    
//    MARK: - IBOutlet
    
    @IBOutlet weak var imgAd: UIImageView!
    @IBOutlet weak var lblShowNoQust: UILabel!
    @IBOutlet weak var lblShowQuestion: UILabel!
    @IBOutlet weak var actInd_showQst: UIActivityIndicatorView!
    
    @IBOutlet weak var option1Btn: UIButton!
    @IBOutlet weak var lblTestName: UILabel!
    @IBOutlet weak var option2Btn: UIButton!
    @IBOutlet weak var option3Btn: UIButton!
    @IBOutlet weak var option4Btn: UIButton!
    @IBOutlet weak var option5Btn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var btnAD: UIButton!
    
//    @IBOutlet weak var slider: CircularSlider!
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        actInd_showQst.frame = CGRect(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2, width: 70, height: 70)
        actInd_showQst.center = self.view.center
        actInd_showQst.layer.cornerRadius = 10
        actInd_showQst.startAnimating()
        

        
        
//        slider.endPointValue = 5
        
        checkTypeOfTest()
        
        crtQuestion = 0
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showAdImag), userInfo: nil, repeats: false)
        
        if (UserDefaults.standard.value(forKey: "oldData") == nil) {
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(getQuestion), userInfo: nil, repeats: false)
        }
        else {
            actInd_showQst.stopAnimating()
            self.arrMainData = UserDefaults.standard.value(forKey: "oldData") as! NSMutableArray
            getRandomQuestion()
//            self.showQuestion()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if (UserDefaults.standard.value(forKey: "oldData") == nil) {
//            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(getQuestion), userInfo: nil, repeats: false)
//        }
//        else {
//            actInd_showQst.stopAnimating()
//            self.arrMainData = UserDefaults.standard.value(forKey: "oldData") as! NSMutableArray
//            getRandomQuestion()
//            self.showQuestion()
//        }
        
//        actInd_showQst.stopAnimating()
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

    
    func checkTypeOfTest() {
        if typeTest==1 {
            lblShowNoQust.text = "Question \(crtQuestion + 1)/10"
            strTestName = "Sprint Test"
            lblTestName.text = strTestName as String
            
            
        }
        else if typeTest==2 {
            lblShowNoQust.text = "Question \(crtQuestion + 1)/50"
            strTestName = "Dash Test"
            lblTestName.text = strTestName as String
        }
        else if typeTest==3 {
            lblShowNoQust.text = "Question \(crtQuestion + 1)/100"
            strTestName = "Marathone Test"
            lblTestName.text = strTestName as String
        }
    }
    
   
    
    func showQuestion() {
        
        checkTypeOfTest()
        
        lblShowQuestion.text = (self.arrRandomQuestion[crtQuestion] as! NSDictionary)["question"] as? String
        lblShowQuestion.adjustsFontSizeToFitWidth = true
        
        option1Btn.setTitle((self.arrRandomQuestion[crtQuestion] as! NSDictionary)["choice1"] as? String, for: .normal)
        option1Btn.layer.cornerRadius = 7
        option1Btn.titleLabel?.adjustsFontSizeToFitWidth = true
//        option1Btn.titleLabel?.numberOfLines = 0
        
        option2Btn.setTitle((self.arrRandomQuestion[crtQuestion] as! NSDictionary)["choice2"] as? String, for: .normal)
        option2Btn.layer.cornerRadius = 7
        option2Btn.titleLabel?.adjustsFontSizeToFitWidth = true
//        option2Btn.titleLabel?.numberOfLines = 0
        
        option3Btn.setTitle((self.arrRandomQuestion[crtQuestion] as! NSDictionary)["choice3"] as? String, for: .normal)
        option3Btn.layer.cornerRadius = 7
        option3Btn.titleLabel?.adjustsFontSizeToFitWidth = true
//        option3Btn.titleLabel?.numberOfLines = 0
        
        option4Btn.setTitle((self.arrRandomQuestion[crtQuestion] as! NSDictionary)["choice4"] as? String, for: .normal)
        option4Btn.layer.cornerRadius = 7
        option4Btn.titleLabel?.adjustsFontSizeToFitWidth = true
//        option4Btn.titleLabel?.numberOfLines = 0
        
        option5Btn.setTitle((self.arrRandomQuestion[crtQuestion] as! NSDictionary)["choice5"] as? String, for: .normal)
        option5Btn.layer.cornerRadius = 7
        option5Btn.titleLabel?.adjustsFontSizeToFitWidth = true
//        option5Btn.titleLabel?.numberOfLines = 0
        
    }
    
    func repeatQuestion(total:NSInteger) {
        
        var repeatQue:NSInteger = total - arrRandomQuestion.count
        
        var randomIndex = 0
        
        if repeatQue != 0 {
            for var i in 0 ..< repeatQue {
                randomIndex = Int(arc4random_uniform(UInt32(arrMainData.count)))
//                print(arrTest[randomIndex])
                
                if arrRandomQuestion.contains(arrMainData[randomIndex]) {
                    //                randomIndex = Int(arc4random_uniform(UInt32(arrTest.count)))
                    
                }
                else  {
                    arrRandomQuestion.add(arrMainData[randomIndex])
                }
            }
        }
        
        repeatQue = total - arrRandomQuestion.count
        
        if repeatQue != 0 {
            repeatQuestion(total:total)
        }
    }
    
    func getRandomQuestion() {
        
        let arrTest : NSArray = arrMainData
        
        var limit:NSInteger = 0
        
        arrRandomQuestion.removeAllObjects()
        
        if typeTest==1 {
           limit = 10
        }
        else if typeTest==2 {
            limit = 50
        }
        else if typeTest==3 {
            limit = 100
        }
        var randomIndex = 0
        
        for var i in 0 ..< limit {
            randomIndex = Int(arc4random_uniform(UInt32(arrTest.count)))
//            print(arrTest[randomIndex])
            
            if arrRandomQuestion.contains(arrTest[randomIndex]) {
//                randomIndex = Int(arc4random_uniform(UInt32(arrTest.count)))
                i -= 2
            }
            else  {
                arrRandomQuestion.add(arrTest[randomIndex])
            }
        }
        
        repeatQuestion(total:limit)
        
        print("arrCount : \(arrRandomQuestion.count)")
        print("arrRandom : \(arrRandomQuestion)")
        
        self.showQuestion()
        
        
    }
    
    func getQuestion() {
        
        let rechability = Reachability()
        
        if rechability?.isReachable == true {
            print("rechable")
            let strURL = "\((app?.strService)! as String)getQuestionBank"
            
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
                    self.jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSMutableDictionary
                    
                    print("Response : \(self.jsonDict)")
                    if self.jsonDict.isEqual(nil) {
                        print("Error :\(error)")
                    }
                    else {
                        DispatchQueue.main.async {
                            self.actInd_showQst.stopAnimating()
                            self.arrMainData = self.jsonDict["freeQuestions"] as! NSMutableArray
                            print("Response : \(self.arrMainData)")
//                            self.showQuestion()
                            UserDefaults.standard.set(self.arrMainData, forKey: "oldData")
                            self.getRandomQuestion()
                        }
                    }
                    //                self.actInd_showQst.stopAnimating()
                }
                catch {
                    return
                }
            })
            task.resume()

        }
        else {
            print("not rechable")
            self.actInd_showQst.stopAnimating()
            showAlert(msg: "Make sure your device is connected to the internet.")
        }
    }
    
    func clearcolor()  {
        option1Btn.layer.borderColor = UIColor.clear.cgColor
        option2Btn.layer.borderColor = UIColor.clear.cgColor
        option3Btn.layer.borderColor = UIColor.clear.cgColor
        option4Btn.layer.borderColor = UIColor.clear.cgColor
        option5Btn.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setBorder(btn : UIButton) {
        
        clearcolor()
        
        option1Btn.isSelected = false
        option2Btn.isSelected = false
        option3Btn.isSelected = false
        option4Btn.isSelected = false
        option5Btn.isSelected = false

        btn.isSelected = true
        btn.layer.borderColor = UIColor(red:0.04, green:0.82, blue:0.95, alpha:1.0).cgColor
        btn.layer.borderWidth = 2
    }
    
    func showAlert(msg:String)  {
        let alert = UIAlertController(title: "PassTheBrokerExam", message: msg, preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            
        }
        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Action Methods
    
    @IBAction func btnShowAd(_ sender: Any) {
        let strUrl = (UserDefaults.standard.value(forKey: "adURL") as! String)
        UIApplication.shared.openURL(URL(string: strUrl)!)
    }
    
    @IBAction func btnOption1(_ sender: Any) {
        choice=1
        setBorder(btn: option1Btn)
    }
    
    @IBAction func btnOption2(_ sender: Any) {
        choice=2
        setBorder(btn: option2Btn)
    }
    
    @IBAction func btnOption3(_ sender: Any) {
        choice=3
        setBorder(btn: option3Btn)
    }
    
    @IBAction func btnOption4(_ sender: Any) {
        choice=4
        setBorder(btn: option4Btn)
    }
    
    @IBAction func btnOption5(_ sender: Any) {
        choice=5
        setBorder(btn: option5Btn)
    }
    
    @IBAction func btnMenu(_ sender: Any) {
        let mvc = storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        navigationController?.pushViewController(mvc, animated: false)
    }
    
    @IBAction func btnGoBack(_ sender: Any) {
//        let ctvc = storyboard?.instantiateViewController(withIdentifier: "ChoiceTestVC") as! ChoiceTestVC
//        navigationController?.pushViewController(ctvc, animated: true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnPrevious(_ sender: Any) {
        
        clearcolor()
        
        nextBtn.isEnabled = true
        nextBtn.setTitle("Next", for: .normal)
        
        if crtQuestion < 1  {
            previousBtn.isEnabled = false
            showAlert(msg: "You reach at first question")
        }
            
        else {
            
            previousBtn.isEnabled = true
            print("choice \(crtQuestion)")
            print("DictVal : \((self.arrRandomQuestion[crtQuestion] as! NSDictionary)["answer"] as! NSNumber)")
            
            crtQuestion = crtQuestion - 1
            showQuestion()
            
        }
    }
    
    func checkResult() {
        
        for var i in (0..<arrUserAns.count).reversed()
        {
            if (self.arrRandomQuestion[i] as! NSDictionary)["answer"] as! NSInteger == arrUserAns[i] as! NSInteger  {
                rightAns = rightAns + 1
            }
        }
        
    }
    
    @IBAction func btnNext(_ sender: Any) {
        clearcolor()
        previousBtn.isEnabled = true
        print("crnt \(crtQuestion)")
        print("choice \(choice)")
        print("DictVal : \((self.arrRandomQuestion[crtQuestion] as! NSDictionary)["answer"] as! NSNumber)")
        
        nextBtn.isEnabled = true
        
        

        if choice == 0 {
            showAlert(msg: "You must be choice any one from Options.")
        }
            
        else {
            arrUserAns[crtQuestion] = choice
//            if (self.arrRandomQuestion[crtQuestion] as! NSDictionary)["answer"] as! NSInteger == choice   {
//                rightAns = rightAns + 1
//                
//            }
            choice = 0
            print("\(arrRandomQuestion.count)")
            if crtQuestion < arrRandomQuestion.count-1 {
                crtQuestion = crtQuestion + 1
                nextBtn.setTitle("Next", for: .normal)
                
                if crtQuestion==arrRandomQuestion.count-1 {
                    nextBtn.setTitle("Finish", for: .normal)
                }
                showQuestion()
            }
            else {
                
                checkResult()
                
                print("Score : \(rightAns*100/arrRandomQuestion.count) ")
                let scr = rightAns*100/arrRandomQuestion.count
                nextBtn.isEnabled = false
                
                print("\(arrUserAns)")
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMMM h:mm a"
                formatter.amSymbol = "AM"
                formatter.pmSymbol = "PM"
                
                let dateString = formatter.string(from: Date())
                print(dateString)
                
                var arrTestHistory:NSMutableArray = []
                
                
                
                if (UserDefaults.standard.value(forKey: "TestHistory")) == nil {
                    
                }
                else {
                    arrTestHistory = (UserDefaults.standard.value(forKey: "TestHistory") as! NSArray as! NSMutableArray).mutableCopy() as! NSMutableArray
                    
                }
                
                arrTestHistory.add(["Test":"\(strTestName)","Time":"\(dateString)","Score":"\(scr)"])
                UserDefaults.standard.set(arrTestHistory, forKey: "TestHistory")

                let trvc = storyboard?.instantiateViewController(withIdentifier: "TestResultVC") as! TestResultVC
                trvc.testScore = scr
                trvc.arrUAns = self.arrRandomQuestion
                
                navigationController?.pushViewController(trvc, animated: true)
                
            }
        }

        
    }
}
