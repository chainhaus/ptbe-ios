/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

class TestButton: UIView {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelBackground: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    // toggle background and label's color on highlight state change
    var highlighted = false {
        didSet {
            if let labelBackground = labelBackground,
                let label = label {
                
                label.textColor = highlighted ? UIColor.white : UIColor.black
                labelBackground.isHidden = !highlighted
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        highlighted = false
    }

}
