/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import RealmSwift

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
    
    // MARK: - Purchase
    private let kPurchase = NSNotification.Name(rawValue: "Event_Purchase")
    
    public func onPurchase(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kPurchase, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    public func purchased() {
        nc.post(name: kPurchase, object: nil)
    }
    
    // MARK: - Open MainVC
    private let kOpenMain = NSNotification.Name(rawValue: "Event_OpenMain")
    
    public func onOpenMain(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kOpenMain, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    public func openMain() {
        nc.post(name: kOpenMain, object: nil)
    }
}
