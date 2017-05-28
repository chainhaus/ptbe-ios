/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import MBProgressHUD
import SwiftyStoreKit
import RealmSwift

class SettingsVC: UIViewController {
    
    // MARK: - Table Data
    
    fileprivate var titles = ["Change Password",
                              "Restore Purchase"]
    fileprivate var subtitles = ["Request an e-mail",
                                 "For premium access"]
    fileprivate var icons = ["change-passwrd.png",
                             "restore.png"]
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButtonheight: NSLayoutConstraint!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Settings.shared.loggedIn {
            logoutButtonheight.constant = 0
        }
    }
    
    func failedToSendPasswordChange(dueTo reason: String) {
        UIAlertController.show(okAlertIn: self, withTitle: "Warning", message: reason) { 
            self.changePassword()
        }
    }
    
    func changePassword() {
        let alert = UIAlertController(title: "Change password",
                                      message: "",
                                      preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "New password"
            $0.isSecureTextEntry = true
        }
        alert.addTextField {
            $0.placeholder = "Confirm password"
            $0.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { _ in
            if let newPassword = alert.textFields?[0].text,
                let confirmPassword = alert.textFields?[1].text {

                if newPassword.characters.count < 6 {
                    self.failedToSendPasswordChange(dueTo: "Password should be minimum 6 digits long")
                    return
                }
                
                if newPassword.characters.count > 15 {
                    self.failedToSendPasswordChange(dueTo: "Password shouldn't be longer than 15 digits")
                    return
                }
                
                if newPassword != confirmPassword {
                    self.failedToSendPasswordChange(dueTo: "Passwords do not match")
                    return
                }
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                Api.shared.changePassword(to: newPassword, callback: {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if let errorString = $1 {
                        // failed to restore password
                        UIAlertController.show(okAlertIn: self, withTitle: "Warning", message: errorString)
                    } else {
                        // successfully sent email
                        UIAlertController.show(okAlertIn: self,
                                               withTitle: "Congratulations",
                                               message: "Your password has been successfully changed")
                    }
                })
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func paymentSuccessful() {
        UIAlertController.show(okAlertIn: self,
                               withTitle: "Congratulations",
                               message: "Your premium access was successfully restored.",
                               callback: {
                                // Tests will be updated, and questions will be loaded
                                Event.shared.purchased()
        })
    }
    
    func restorePurchase() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            var hasPurchase = false
            for product in results.restoredProducts {
                if product.productId == Settings.kIAPProductId {
                    hasPurchase = true
                    break
                }
            }
            
            if hasPurchase {
                self.paymentSuccessful()
            } else {
                UIAlertController.show(okAlertIn: self,
                                       withTitle: "Warning",
                                       message: "Nothing to restore")
            }
        }
        NSHomeDirectory()
    }
    
    // MARK: - Action Methods
    
    @IBAction func openMenu() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MenuVC")
        present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func logout() {
        UIAlertController.show(in: self,
                               withTitle: "Warning",
                               message: "Are you sure you want to log out?",
                               actions: [
                                UIAlertAction(title: "No", style: .cancel, handler: nil),
                                UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                                    Event.shared.logout()
                                })])
    }
}

// MARK: - UITableViewDelegate

extension SettingsVC: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restoreIndex = Settings.shared.loggedIn ? 1 : 0
        
        if indexPath.row == restoreIndex {
            restorePurchase()
        } else {
            changePassword()
        }
    }
}

// MARK: - UITableViewDataSource

extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count - (Settings.shared.loggedIn ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offset = Settings.shared.loggedIn ? 0 : 1
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath) as! SettingsTVC
        cell.titleLabel.text        = titles[indexPath.row + offset]
        cell.subtitleLabel.text     = subtitles[indexPath.row + offset]
        cell.iconImageView.image    = UIImage.init(named: icons[indexPath.row + offset])
        
        return cell
    }
}
