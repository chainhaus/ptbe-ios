/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

class TestReviewQuestionTVC: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var topicNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var chosenAnswerLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    
    // MARK: - Question
    
    public func setQuestion(_ question: Question, test: Test) {
        topicNameLabel.text = question.topic.name
        questionLabel.text = question.question
        
        if let chosenAnswer = question.value(forKeyPath: "choice\(test.answer(for: question) + 1)") as? String {
            chosenAnswerLabel.text = "Chosen: ".appending(chosenAnswer)
        }
        
        if let correctAnswer = question.value(forKeyPath: "choice\(question.answer)") as? String {
            correctAnswerLabel.text = "Answer: ".appending(correctAnswer)
        }
    }
}
