/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import StoreKit
import ImageLoader
import MBProgressHUD
import RealmSwift
import SwiftyStoreKit

class MainVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var dabbleButton: TestButton!
    @IBOutlet weak var playButton: TestButton!
    @IBOutlet weak var grindButton: TestButton!
    @IBOutlet weak var adView: AdView!
    
    // MARK: - Methods
    
    private func updateVersion() {
        Api.shared.receiveVersion(callback: { versionChanged in
            if versionChanged {
                self.loadQuestions(callback: nil)
            }
        })
    }
    
    private func updateAds() {
        let hasNoCachedAdsOnLaunch = Ad.cachedList().count == 0
        
        // Ask for ads only if premium isn't yet activated
        if !Test.of(kind: Test.premiumKinds.first!).purchased {
            Api.shared.receiveAd {
                if hasNoCachedAdsOnLaunch {
                    // force first launch ads
                    self.adView.load()
                }
            }
        }
    }
    
    private func loggedInOrLoggedOut() {
        Event.shared.openMain()
        
        // Force clearing questions
        Question.clearCache()
        
        // Load no-auth questions
        loadQuestions(callback: nil)
        
        if Settings.shared.loggedIn {
            // Get most recent test history
            Api.shared.receiveTestHistory(callback: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check whether we need to update local database
        if Settings.shared.versionShouldUpdate {
            updateVersion()
            updateAds()
        } else {
            if Question.cachedList().count == 0 {
                updateVersion()
            }
            
            if Ad.cachedList().count == 0 {
                updateAds()
            }
        }
        
        if Settings.shared.loggedIn {
            // Get most recent test history
            Api.shared.receiveTestHistory(callback: nil)
        }
        
        // Sign for log in and log out action
        Event.shared.onLogout(execute: loggedInOrLoggedOut)
        Event.shared.onLogin(execute: loggedInOrLoggedOut)
        
        // Sign for log in action
        Event.shared.onLogin(execute: loggedInOrLoggedOut)
        
        // Sign for open loginVC
        Event.shared.onOpenLogin { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                vc.skipToRegister = false
                
                self.navigationController?.popToViewController(self, animated: false)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        
        // Sign for open registerVC
        Event.shared.onOpenRegister { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                vc.skipToRegister = true
                
                self.navigationController?.popToViewController(self, animated: false)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        
        // Sign for open mainVC
        Event.shared.onOpenMain { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                self.navigationController?.popToViewController(self, animated: true)
            }
        }
        
        // Sign for open testHistoryVC
        Event.shared.onOpenTestHistory { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                self.openViewController(with: "TestHistoryVC")
            }
        }
        
        // Sign for open topicFilterVC
        Event.shared.onOpenTopicFilter { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                self.openViewController(with: "TopicFilterVC")
            }
        }
        
        // Sign for open settingsVC
        Event.shared.onOpenSettings { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                self.openViewController(with: "SettingsVC")
            }
        }
        
        // Delete cached questions on purchase
        Event.shared.onPurchase {
            let realm = try! Realm()
            try! realm.write {
                realm.delete(Question.cachedList())
            }
        }
    }
    
    private func openViewController(with identifier: String) {
        navigationController?.popToViewController(self, animated: false)
        navigationController?
            .pushViewController((storyboard?
                .instantiateViewController(withIdentifier: identifier))!,
                                animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adView.load()
    }
    
    private func loadQuestions(callback: (() -> Void)?) {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        Api.shared.receiveQuestions {
            if $0.0 == nil {
                MBProgressHUD.hide(for: self.view, animated: true)
                UIAlertController.show(in: self,
                                       withTitle: "Warning",
                                       message: "Couldn't load questions bank. Would you like to retry?",
                                       actions: [
                                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
                                        UIAlertAction(title: "Retry", style: .default, handler: { _ in
                                            self.loadQuestions(callback: callback)
                                        })])
            } else {
                Api.shared.receiveTopics {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if $0.0 == nil {
                        UIAlertController.show(in: self,
                                               withTitle: "Warning",
                                               message: "Couldn't load topics. Would you like to retry?",
                                               actions: [
                                                UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
                                                UIAlertAction(title: "Retry", style: .default, handler: { _ in
                                                    self.loadQuestions(callback: callback)
                                                })])
                    } else if let callback = callback {
                        callback()
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Action Methods
    
    func paymentSuccessful(testButton: TestButton, kind: Test.Kind) {
        UIAlertController.show(okAlertIn: self,
                               withTitle: "Congratulations",
                               message: "Payment has been placed successfully. Now, you will be redirected to the test.",
                               callback: {
                                // Tests will be updated, and questions will be loaded
                                Event.shared.purchased()
                                // Also, all questions must be deleted, and await full list download
                                self.openTest(testButton: testButton, kind: kind)
        })
    }
    
    func purchase(testButton: TestButton, kind: Test.Kind) {
        SwiftyStoreKit.purchaseProduct(Settings.kIAPProductId, atomically: true) { result in
            switch result {
            case .success:
                // store purchased state
                let realm = try! Realm()
                for kind in Test.premiumKinds {
                    try! realm.write {
                        Test.of(kind: kind).purchased = true
                    }
                }
                
                self.paymentSuccessful(testButton: testButton, kind: kind)
            case .error(let error):
                var errorString: String!
                
                switch error {
                case .failed(let error): errorString = error.localizedDescription
                case .invalidProductId: errorString = "Product doesn't exist"
                case .paymentNotAllowed: errorString = "Payment not allowed"
                }
                
                UIAlertController.show(okAlertIn: self, withTitle: "Warning", message: "Payment failed. Reason:\n\"\(errorString!)\"")
            }
        }
    }
    
    var product: SKProduct?
    
    func loadProduct(callback: @escaping () -> Void) {
        if let _ = product {
            callback()
        } else {
            SwiftyStoreKit.retrieveProductsInfo([Settings.kIAPProductId], completion: {
                for product in $0.retrievedProducts {
                    if product.productIdentifier == Settings.kIAPProductId {
                        self.product = product
                    }
                }
                
                callback()
            })
        }
    }
    
    func openTest(testButton: TestButton, kind: Test.Kind) {
        if Question.cachedList().count == 0 {
            loadQuestions {
                self.openTest(testButton: testButton, kind: kind)
            }
            return
        }
        
        let test = Test.of(kind: kind)
        print("Test of kind \(kind) is purchased = \(test.purchased)")
        if !test.purchased {
            testButton.highlighted = true
            
            var alertMessage = "Get over 1,000+ test questions and the Dabble and Grind tests"
            
            MBProgressHUD.showAdded(to: view, animated: true)
            loadProduct {
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let product = self.product, let price = product.localizedPrice {
                    alertMessage.append(" for ")
                    alertMessage.append(price)
                }
                
                UIAlertController.show(in: self,
                                       withTitle: "Premium access",
                                       message: alertMessage,
                                       actions: [
                                        UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                                            testButton.highlighted = false
                                        }),
                                        UIAlertAction(title: "Buy", style: .default, handler: { _ in
                                            self.purchase(testButton: testButton, kind: kind)
                                        })])
            }
            
            return
        }
        
        if !test.hasEnoughAvailableTopics {
            UIAlertController.show(in: self,
                                   withTitle: "Warning",
                                   message: "Topics you selected don't have enough questions to populate test. Please, select more.",
                                   actions: [
                                    UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
                                    UIAlertAction(title: "Select", style: .default, handler: { _ in
                                        Event.shared.openTopicFilter()
                                    })])
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TestVC") as! TestVC
        vc.test = test
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openDabble() {
        openTest(testButton: dabbleButton, kind: .dabble)
    }
    
    @IBAction func openPlay() {
        openTest(testButton: playButton, kind: .play)
    }
    
    @IBAction func openGrind() {
        openTest(testButton: grindButton, kind: .grind)
    }
    
    @IBAction func openMenu() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MenuVC")
        present(vc!, animated: true, completion: nil)
    }
}
