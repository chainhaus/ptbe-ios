//
//  Event.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 18/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import UIKit

class Event {

    public static let shared = Event()
    private let nc = NotificationCenter.default
    
    // MARK: - Logging out
    private let kLogout = NSNotification.Name(rawValue: "Event_Logout")
    
    public func onLogout(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kLogout, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    public func logout() {
        Settings.shared.sessionKey  = nil
        Settings.shared.userEmail   = nil
        
        nc.post(name: kLogout, object: nil)
    }
}
