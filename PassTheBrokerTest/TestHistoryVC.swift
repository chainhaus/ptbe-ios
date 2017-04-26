/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import MBProgressHUD

class TestHistoryVC: UIViewController {
    
    fileprivate enum Sorter {
        case testNameAsc, testNameDesc, dateAsc, dateDesc, scoreAsc, scoreDesc
    }
    
    fileprivate var sorter: Sorter = .dateDesc {
        didSet {
            if testResults.count > 0 {
                tableView.reloadData()
            }
        }
    }
    
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
    
    @IBAction func chooseSort() {
        let alert = UIAlertController(title: "", message: "Sort by", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Test Name", style: .default, handler: { _ in
            if self.sorter == .testNameDesc {
                self.sorter = .testNameAsc
            } else {
                self.sorter = .testNameDesc
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { _ in
            if self.sorter == .dateDesc {
                self.sorter = .dateAsc
            } else {
                self.sorter = .dateDesc
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Score", style: .default, handler: { _ in
            if self.sorter == .scoreDesc {
                self.sorter = .scoreAsc
            } else {
                self.sorter = .scoreDesc
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension TestHistoryVC: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension TestHistoryVC: UITableViewDataSource {
    
    func sort(lhs: TestResult, rhs: TestResult) -> Bool {
        switch sorter {
        case .testNameAsc:
            return lhs.testName < rhs.testName
        case .testNameDesc:
            return lhs.testName > rhs.testName
        case .dateAsc:
            return lhs.date < rhs.date
        case .dateDesc:
            return lhs.date > rhs.date
        case .scoreAsc:
            return lhs.score < rhs.score
        case .scoreDesc:
            return lhs.score > rhs.score
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath) as! TestHistoryTVC
        cell.testResult = testResults.sorted(by: sort(lhs:rhs:))[indexPath.row]
        
        return cell
    }
}
