/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

class TestReviewVC: UIViewController {
    
    var test: Test!
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adView: AdView!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adView.load()
    }
    
    // MARK: - Action Methods
    
    @IBAction func openMenu() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MenuVC")
        present(vc!, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension TestReviewVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 36 : 112
    }
}

// MARK: - UITableViewDataSource
extension TestReviewVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return test.questionsCount + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell",
                                                     for: indexPath) as! TestReviewHeaderTVC
            cell.test = test
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell",
                                                             for: indexPath) as! TestReviewQuestionTVC
            cell.setQuestion(test.questions[indexPath.row - 1], test: test)
            
            return cell
        }
    }
}
