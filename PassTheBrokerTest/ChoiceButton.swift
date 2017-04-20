/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

class ChoiceButton: UIButton {

    private var borderLayer: CALayer?
    
    private let selectedChoiceBorderColor = UIColor(red:0.04, green:0.82, blue:0.95, alpha:1.0).cgColor
    private let selectedChoiceBorderWidth: CGFloat = 2
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                if borderLayer == nil {
                    clipsToBounds = false
                    
                    let externalBorder = CALayer()
                    externalBorder.frame = CGRect(x: -selectedChoiceBorderWidth,
                                                  y: -selectedChoiceBorderWidth,
                                                  width: frame.size.width + selectedChoiceBorderWidth * 2,
                                                  height: frame.size.height + selectedChoiceBorderWidth * 2)
                    externalBorder.borderColor = selectedChoiceBorderColor
                    externalBorder.borderWidth = selectedChoiceBorderWidth
                    externalBorder.cornerRadius = 7
                    
                    borderLayer = externalBorder
                    layer.addSublayer(externalBorder)
                }
            } else if let borderLayer = borderLayer {
                borderLayer.removeFromSuperlayer()
                self.borderLayer = nil
            }
        }
    }
}
