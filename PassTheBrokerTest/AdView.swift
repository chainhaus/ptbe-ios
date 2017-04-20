/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit
import ImageLoader

class AdView: UIButton {

    @IBOutlet weak var height: NSLayoutConstraint?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        imageView?.contentMode = .scaleToFill
        addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    
    private func hide() {
        if let height = height {
            height.constant = 0
        } else {
            isHidden = true
        }
    }
    
    public func load() {
        // Hide ad if premium purchased
        if Test.of(kind: Test.premiumKinds.first!).purchased {
            hide()
            return
        }
        
        // Load from cache if exists
        var loader: Loader?
        var oldAdImageUrlString: String?
        if let adImageUrlString = Settings.shared.adImageUrlString {
            loader = apply(adImageUrlString: adImageUrlString)
            oldAdImageUrlString = adImageUrlString
        }
        
        // Ask for actual URL
        Api.shared.receiveAd {
            if let adImageUrlString = Settings.shared.adImageUrlString {
                if let loader = loader,
                    oldAdImageUrlString != adImageUrlString &&
                    loader.state != .completed {
                    
                    // URL changed, cancel loader
                    loader.cancel()
                } else {
                    // 1. No cached ad
                    // 2. Same URL
                    // 3. Cached ad even with another URL already loaded, check it
                    if oldAdImageUrlString == nil || oldAdImageUrlString != adImageUrlString {
                        _ = self.apply(adImageUrlString: adImageUrlString)
                    }
                }
            } else {
                self.hide()
            }
        }
    }
    
    private func apply(adImageUrlString: String) -> Loader {
        return ImageLoader.request(with: adImageUrlString, onCompletion: {
            if let image = $0.0 {
                OperationQueue.main.addOperation {
                    self.setImage(image, for: .normal)
                }
            } else {
                OperationQueue.main.addOperation {
                    self.hide()
                }
            }
        })
    }
    
    @objc private func clicked() {
        if let adClickUrlString = Settings.shared.adClickUrlString {
            UIApplication.shared.openURL(URL(string: adClickUrlString)!)
        }
    }
}
