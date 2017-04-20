//
//  TopicFilterVC.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 21/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import UIKit
import MBProgressHUD

class TopicFilterVC: UIViewController {
    
    var topics: [Topic] = [] {
        didSet {
            if let tableView = tableView {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adView: AdView!
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load from cache
        topics = Topic.cachedList()
        
        MBProgressHUD.showAdded(to: view, animated: true)
        Api.shared.receiveTopics {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let topics = $0.0 {
                self.topics = topics
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adView.load()
    }
    
    // MARK: - Action Methods
    
    @IBAction func openMenu(_ sender: Any) {
        if topics.count > 0 {
            var haveTopicsAvailable = false
            
            for topic in topics {
                if topic.available {
                    haveTopicsAvailable = true
                    break
                }
            }
            
            if !haveTopicsAvailable {
                UIAlertController.show(okAlertIn: self,
                                       withTitle: "Warning",
                                       message: "You should choose at least one topic")
                return
            }
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "MenuVC")
        present(vc!, animated: true, completion: nil)
    }
}


// MARK: - UITableViewDelegate

extension TopicFilterVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - UITableViewDataSource

extension TopicFilterVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("topics count \(topics.count)")
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath) as! TopicFilterTVC
        cell.topic = topics[indexPath.row]
        
        return cell
    }
}
