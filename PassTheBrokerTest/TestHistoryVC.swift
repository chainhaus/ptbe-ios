/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import MBProgressHUD

class TestHistoryVC: UIViewController {
    
    var testResults: [TestResult] = [] {
        didSet {
            if let tableView = tableView, let noDataLabel = noDataLabel {
                tableView.isHidden = testResults.count == 0
                noDataLabel.isHidden = testResults.count > 0
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var adView: AdView!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load from cache
        testResults = TestResult.cachedList()
        
        MBProgressHUD.showAdded(to: view, animated: true)
        Api.shared.receiveTestHistory {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let testResults = $0.0 {
                self.testResults = testResults
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adView.load()
    }
    
    // MARK: - Action Methods
    
    @IBAction func openMenu(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MenuVC")
        present(vc!, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension TestHistoryVC: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension TestHistoryVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath) as! TestHistoryTVC
        cell.testResult = testResults[indexPath.row]
        
        return cell
    }
}
