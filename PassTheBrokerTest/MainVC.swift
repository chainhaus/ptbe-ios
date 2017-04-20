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
    
    @IBOutlet weak var dabbleButton: TestButton!
    @IBOutlet weak var playButton: TestButton!
    @IBOutlet weak var grindButton: TestButton!
    @IBOutlet weak var adView: AdView!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Check whether we need to update local database
        if Settings.shared.versionShouldUpdate || Question.cachedList().count == 0 {
            Api.shared.receiveVersion(callback: { versionChanged in
                if versionChanged {
                    self.loadQuestions(callback: nil)
                }
            })
        }
        
        // Sign for log out action
        Event.shared.onLogout { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        // Sign for open mainVC
        Event.shared.onOpenMain { [weak self] in // cast weak to avoid memory leak
            if let `self` = self {
                self.navigationController?.popToViewController(self, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adView.load()
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
    
    // MARK: - Action Methods
    
    func purchase() {
        
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
            
            UIAlertController.show(in: self,
                                   withTitle: "Premium access",
                                   message: "Get over 1,000+ test questions and the Dabble and Grind tests for $19.99",
                                   actions: [
                                    UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                                        testButton.highlighted = false
                                    }),
                                    UIAlertAction(title: "Buy", style: .default, handler: { _ in
                                        self.purchase()
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
