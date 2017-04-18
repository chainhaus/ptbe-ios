//
//  TextFieldExtension.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 18/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import UIKit

extension UITextField {
    
    public func showBottomBorder() {
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
