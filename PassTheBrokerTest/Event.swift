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
    
    // MARK: - Open TestHistoryVC
    private let kOpenTestHistory = NSNotification.Name(rawValue: "Event_TestHistory")
    
    public func onOpenTestHistory(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kOpenTestHistory, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    func openTestHistory() {
        nc.post(name: kOpenTestHistory, object: nil)
    }
    
    // MARK: - Open TopicFilterVC
    private let kOpenTopicFilter = NSNotification.Name(rawValue: "Event_TopicFilter")
    
    public func onOpenTopicFilter(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kOpenTopicFilter, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    func openTopicFilter() {
        nc.post(name: kOpenTopicFilter, object: nil)
    }
    
    // MARK: - Open SettingsVC
    private let kOpenSettings = NSNotification.Name(rawValue: "Event_OpenSettings")
    
    public func onOpenSettings(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kOpenSettings, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    func openSettings() {
        nc.post(name: kOpenSettings, object: nil)
    }
}
