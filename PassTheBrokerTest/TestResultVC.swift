/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit

class TestResultVC: UIViewController {
    
    var test: Test!
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var adView: AdView!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = String.format(test.score, precision: 2, ignorePrecisionIfRounded: true).appending(" %")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adView.load()
    }

    // MARK: - Action Methods
    
    @IBAction func openResultsReview(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TestReviewVC") as! TestReviewVC
        vc.test = test
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openNewTest() {
        Event.shared.openMain()
    }
}
