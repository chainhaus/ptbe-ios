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
        versionLabel.text = "DB v\(Settings.shared.appMajorVersion).\(Settings.shared.appMinorVersion)"
    }
    
    // MARK: - Action Methods
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takeATest() {
        dismiss(animated: false) {
            Event.shared.openMain()
        }
    }
    
    @IBAction func openTestHistory() {
        dismiss(animated: false) {
            Event.shared.openTestHistory()
        }
    }
    
    @IBAction func openTopicFilter() {
        dismiss(animated: false) {
            Event.shared.openTopicFilter()
        }
    }
    
    @IBAction func openSettings() {
        dismiss(animated: false) {
            Event.shared.openSettings()
        }
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
