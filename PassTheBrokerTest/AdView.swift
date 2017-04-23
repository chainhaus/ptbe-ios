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
    
    private var ad: Ad? {
        didSet {
            if let ad = ad {
                apply(adImageUrlString: ad.imageUrlString)
            }
        }
    }
    
    public func load() {
        // Hide ad if premium purchased
        if Test.of(kind: Test.premiumKinds.first!).purchased {
            hide()
            return
        }
        
        let ads = Ad.cachedList()
        if ads.count > 0 {
            ad = ads[Int(arc4random_uniform(UInt32(ads.count)))]
        } else {
            // if no ads yet in cache, either there are no from API, 
            // or first call is queued, which will also call this method
        }
    }
    
    private func apply(adImageUrlString: String) {
        ImageLoader.request(with: adImageUrlString, onCompletion: {
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
        if let ad = ad {
            UIApplication.shared.openURL(URL(string: ad.clickUrlString)!)
        }
    }
}
