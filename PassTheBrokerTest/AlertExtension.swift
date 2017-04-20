/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

extension UIAlertController {
    
    static func show(okAlertIn viewController: UIViewController,
                     withTitle title: String?,
                     message: String?) {
        show(okAlertIn: viewController, withTitle: title, message: message, callback: nil)
    }
    
    static func show(okAlertIn viewController: UIViewController,
                     withTitle title: String?,
                     message: String?,
                     callback: (() -> Void)?) {
        
        show(in: viewController,
             withTitle: title,
             message: message,
             actions: [UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let callback = callback {
                    callback()
                }
             })])
    }
    
    static func show(in viewController: UIViewController,
                     withTitle title: String?,
                     message: String?,
                     actions: [UIAlertAction]) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        
        viewController.view.endEditing(true)
        viewController.present(alert, animated: true, completion: nil)
    }
}
