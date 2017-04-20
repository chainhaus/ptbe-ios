/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit

class MenuVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = "Version: \(Settings.shared.appVersion)"
    }
    
    // MARK: - Action Methods
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takeATest() {
        close()
        Event.shared.openMain()
    }
    
    @IBAction func showTestHistory() {
        close()
//        let vc = storyboard?.instantiateViewController(withIdentifier: "TestHistoryVC")
//        navigationController?.pushViewController(vc!, animated: false)
    }
    
    @IBAction func showTopicFilter() {
        close()
//        let vc = storyboard?.instantiateViewController(withIdentifier: "TopicFilterVC")
//        navigationController?.pushViewController(vc!, animated: false)
    }
    
    @IBAction func openSettings() {
        close()
        let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsVC")
        navigationController?.pushViewController(vc!, animated: false)
    }
    
    @IBAction func logout() {
        UIAlertController.show(in: self,
                               withTitle: "Warning",
                               message: "Are you sure you want to log out?",
                               actions: [
                                UIAlertAction(title: "No", style: .cancel, handler: nil),
                                UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                                    self.close()
                                    Event.shared.logout()
                                })])
    }
    
}
