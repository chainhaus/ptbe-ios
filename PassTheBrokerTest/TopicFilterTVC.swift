//
//  TopicFilterTVC.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 21/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import UIKit
import RealmSwift

class TopicFilterTVC: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var availableSwitch: UISwitch! {
        didSet {
            availableSwitch.addTarget(self, action: #selector(switched), for: .valueChanged)
        }
    }
    
    func switched() {
        let realm = try! Realm()
        try! realm.write {
            topic.available = availableSwitch.isOn
        }
    }
    
    // MARK: - Topic

    var topic: Topic! {
        didSet {
            nameLabel.text = topic.name
            availableSwitch.isOn = topic.available
        }
    }
}
