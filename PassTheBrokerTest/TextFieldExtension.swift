/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

extension UITextField {
    
    public func showBottomBorder() {
        layoutIfNeeded()
        
        let width: CGFloat = 2
        
        let border = CALayer()
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0,
                              y: frame.size.height - width,
                              width: frame.size.width,
                              height: frame.size.height)
        border.borderWidth = width
        
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}
