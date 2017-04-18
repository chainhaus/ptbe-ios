//
//  AdView.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 19/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import UIKit

class AdView: UIButton {

    @IBOutlet weak var height: NSLayoutConstraint?
    
    public func load() {
        // TODO: if premium purchased, force height to 0
        Api.shared.receiveAd {
            if let adImageUrlString = Settings.shared.adImageUrlString {
                self.imageView?.load.request(with: URL(string: adImageUrlString)!)
            } else if let height = self.height {
                height.constant = 0
            }
        }
    }
}
