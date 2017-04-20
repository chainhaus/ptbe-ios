/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */
import UIKit

class SettingsTVC: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var wrapper: UIView! {
        didSet {
            wrapper.layer.cornerRadius = 10
            wrapper.layer.borderColor = UIColor.gray.cgColor
            wrapper.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}
