/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

class TestReviewHeaderTVC: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Test
    
    var test: Test! {
        didSet {
            var text = ""
            for topic in test.topics {
                text.append(topic.name)
                text.append(": ")
                text.append(String(test.score(by: topic)))
                text.append("%\n")
            }
            
            label.text = text
        }
    }
}
