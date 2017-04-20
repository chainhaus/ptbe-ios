/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

class TestHistoryTVC: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var wrapper: UIView! {
        didSet {
            wrapper.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: - TestResult
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        // 16 April 11:45 PM
        dateFormatter.dateFormat = "dd MMMM hh:mm a"
        
        return dateFormatter
    }()
    
    var testResult: TestResult! {
        didSet {
            testNameLabel.text = testResult.testName
            dateLabel.text = TestHistoryTVC.dateFormatter.string(from: testResult.date)
            scoreLabel.text = String.format(testResult.score,
                                            precision: 2,
                                            ignorePrecisionIfRounded: true).appending("%")
        }
    }
}
