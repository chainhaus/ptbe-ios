/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import StoreKit
import ImageLoader
import MBProgressHUD

class MainVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var DashBtn: UIButton!
    @IBOutlet weak var MarathonBtn: UIButton!
    @IBOutlet weak var sprintBtn: UIButton!
    @IBOutlet weak var imgsprint: UIImageView!
    @IBOutlet weak var lblSprint: UILabel!
    @IBOutlet weak var imgDash: UIImageView!
    @IBOutlet weak var lblDash: UILabel!
    @IBOutlet weak var lblMarathon: UILabel!
    @IBOutlet weak var imageMarathon: UIImageView!
    @IBOutlet weak var imgAD: UIImageView!
    @IBOutlet weak var btnAD: UIButton!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearData()
        
        // Check whether we need to update local database
        if Settings.shared.versionShouldUpdate || Question.cachedList().count == 0 {
            Api.shared.receiveVersion(callback: { versionChanged in
                if versionChanged {
                    self.loadQuestions(callback: nil)
                }
            })
        }
        
        // Sign for log out action
        Event.shared.onLogout {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Api.shared.receiveAd {
            self.showAdImage()
        }
    }
    
    private func loadQuestions(callback: (() -> Void)?) {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        Api.shared.receiveQuestions {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if $0.0 == nil {
                UIAlertController.show(in: self,
                                       withTitle: "Warning",
                                       message: "Couldn't load questions bank. Would you like to retry?",
                                       actions: [
                                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
                                        UIAlertAction(title: "Retry", style: .default, handler: { _ in
                                            self.loadQuestions(callback: callback)
                                        })])
            } else {
                if let callback = callback {
                    callback()
                }
            }
        }
    }
    
    func showAdImage() {
        if let adImageUrlString = Settings.shared.adImageUrlString {
            btnAD.isEnabled = true
            imgAD.load.request(with: URL(string: adImageUrlString)!)
        } else {
            btnAD.isEnabled = false
        }
    }
    
    func clearData()  {
        sprintBtn.isSelected = false
        lblSprint.textColor = UIColor.black
        imgsprint.isHidden = true
        
        DashBtn.isSelected = false
        lblDash.textColor = UIColor.black
        imgDash.isHidden = true
        
        MarathonBtn.isSelected = false
        lblMarathon.textColor = UIColor.black
        imageMarathon.isHidden = true
    }
    
    func GoToTest(testType: NSInteger)  {
        if Question.cachedList().count == 0 {
            loadQuestions {
                self.GoToTest(testType: testType)
            }
            return
        }
        
        let ctvc = storyboard?.instantiateViewController(withIdentifier: "ShowQuestionVC") as! ShowQuestionVC
        if testType==1 {
            ctvc.typeTest = 1
        }
        else if testType == 2 {
            ctvc.typeTest = 2
        }
        else if testType == 3 {
            ctvc.typeTest = 3
        }
        navigationController?.pushViewController(ctvc, animated: true)
    }
    
    //MARK: -Action Method
    
    @IBAction func btnShowAd(_ sender: Any) {
        
        let strUrl = (UserDefaults.standard.value(forKey: "adURL") as! String)
        UIApplication.shared.openURL(URL(string: strUrl)!)
    }
    
    @IBAction func btnMarathonTest(_ sender: UIButton) {
        
        if sender.isSelected==true {
            sender.isSelected = false
            lblMarathon.textColor = UIColor.black
            imageMarathon.isHidden = true
        }
        else {
            clearData()
            sender.isSelected = true
            lblMarathon.textColor = UIColor.white
            imageMarathon.isHidden = false
            //            GoToTest(testType: 3)
            //            showAlertPurchase()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            //            appPurchase()
            
        }
    }
    
    @IBAction func btnDashTest(_ sender: UIButton) {
        
        if sender.isSelected==true {
            sender.isSelected = false
            lblDash.textColor = UIColor.black
            imgDash.isHidden = true
        }
        else {
            clearData()
            sender.isSelected = true
            lblDash.textColor = UIColor.white
            imgDash.isHidden = false
            //            GoToTest(testType: 2)
            //            showAlertPurchase()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            //            appPurchase()
        }
    }
    
    @IBAction func btnSprintTest(_ sender: UIButton) {
        return
        if sender.isSelected==true {
            sender.isSelected = false
            lblSprint.textColor = UIColor.black
            imgsprint.isHidden = true
        }
        else {
            clearData()
            sender.isSelected = true
            lblSprint.textColor = UIColor.white
            imgsprint.isHidden = false
            GoToTest(testType: 1)
        }
    }
    @IBAction func btnMenu(_ sender: Any) {
        let mvc = storyboard?.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        navigationController?.pushViewController(mvc, animated: false)
    }
}
