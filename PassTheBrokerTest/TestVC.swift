/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import Foundation
import UIKit
import MBProgressHUD

class TestVC: UIViewController {
    
    var test: Test!
    var questionIndex = -1 {
        didSet {
            if questionIndex >= 0 && questionIndex < test.questionsCount {
                showQuestion()
            } else if questionIndex == test.questionsCount {
                finish()
            }
        }
    }
    var choiceIndex = -1 {
        didSet {
            for (i, choiceButton) in [choice1Button, choice2Button, choice3Button, choice4Button, choice5Button].enumerated() {
                choiceButton?.isSelected = i == choiceIndex
            }
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var testTitleLabel: UILabel!
    @IBOutlet weak var questionHeaderLabel: UILabel!
    @IBOutlet weak var topicNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var choice1Button: UIButton!
    @IBOutlet weak var choice2Button: UIButton!
    @IBOutlet weak var choice3Button: UIButton!
    @IBOutlet weak var choice4Button: UIButton!
    @IBOutlet weak var choice5Button: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var adView: AdView!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prepare views
        for choiceButton: UIButton in [choice1Button, choice2Button, choice3Button, choice4Button, choice5Button] {
            choiceButton.layer.cornerRadius = 7
            choiceButton.titleLabel?.numberOfLines = 0
            choiceButton.titleLabel?.textAlignment = .center
        }
        
        // init test and first question
        testTitleLabel.text = test.kind.textRepresentation()
        questionIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adView.load()
    }
    
    func showQuestion() {
        // set question
        questionHeaderLabel.text = "Question \(questionIndex+1)/\(test.questionsCount)"
        
        let question = test.questions[questionIndex]
        topicNameLabel.text = question.topic.name
        questionLabel.text = question.question
        choice1Button.setTitle(question.choice1, for: .normal)
        choice2Button.setTitle(question.choice2, for: .normal)
        choice3Button.setTitle(question.choice3, for: .normal)
        choice4Button.setTitle(question.choice4, for: .normal)
        choice5Button.setTitle(question.choice5, for: .normal)
                
        choiceIndex = test.answer(for: question) // this will select answer if were previously made, otherwise clear all
        
        // toggle back and forward buttons
        previousButton.isEnabled = questionIndex > 0
        nextButton.setTitle(questionIndex == test.questions.count - 1 ? "Finish" : "Next", for: .normal)
    }
    
    func finish() {
        if !Settings.shared.loggedIn {
            openResult()
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        Api.shared.submitResult(of: test) { submitted in
            if submitted {
                Api.shared.receiveTestHistory { _ in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.openResult()
                }
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
                
                UIAlertController.show(in: self,
                                       withTitle: "Warning",
                                       message: "Failed to submit your test result.\nDo you want to retry? Otherwise, your result will be lost.",
                                       actions: [
                                        UIAlertAction(title: "Retry", style: .default, handler: { _ in
                                            self.finish()
                                        }),
                                        UIAlertAction(title: "Continue", style: .destructive, handler: { _ in
                                            self.openResult()
                                        })])
            }
        }
    }
    
    func openResult() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TestResultVC") as! TestResultVC
        vc.test = test
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Action Methods
    
    @IBAction func choiceButtonClicked(_ sender: UIButton) {
        for (i, choiceButton) in [choice1Button, choice2Button, choice3Button, choice4Button, choice5Button].enumerated() {
            if choiceButton == sender {
                choiceIndex = i
                test.answer(question: test.questions[questionIndex], choice: i)
            }
        }
    }
    
    @IBAction func back() {
        UIAlertController.show(in: self,
                               withTitle: "Warning",
                               message: "Are you sure you want to cancel this test? All your results will be lost.",
                               actions: [UIAlertAction(title: "No", style: .cancel, handler: nil),
                                         UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                                            Event.shared.openMain()
                               })])
    }
    
    @IBAction func showPrevious() {
        questionIndex -= 1
    }
    
    @IBAction func showNext() {
        if choiceIndex == -1 {
            UIAlertController.show(okAlertIn: self,
                                   withTitle: "Warning",
                                   message: "Choose your answer before going to next question")
            return
        }
        
        questionIndex += 1
    }
}
