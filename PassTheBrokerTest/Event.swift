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
    
    // MARK: - Logging in
    private let kLogin = NSNotification.Name(rawValue: "Event_Login")
    
    public func onLogin(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kLogin, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    public func login() {
        nc.post(name: kLogin, object: nil)
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
    
    // MARK: - Registered
    private let kRegistered = NSNotification.Name(rawValue: "Event_Registered")
    
    public func onRegistered(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kRegistered, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    public func registered() {
        nc.post(name: kRegistered, object: nil)
    }
    
    // MARK: - Close Registration
    private let kCloseRegistration = NSNotification.Name(rawValue: "Event_CloseRegistration")
    
    public func onCloseRegistration(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kCloseRegistration, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    public func closeRegistration() {
        nc.post(name: kCloseRegistration, object: nil)
    }
    
    // MARK: - Open LoginVC
    private let kOpenLogin = NSNotification.Name(rawValue: "Event_OpenLogin")
    
    public func onOpenLogin(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kOpenLogin, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    public func openLogin() {
        nc.post(name: kOpenLogin, object: nil)
    }
    
    // MARK: - Open RegisterVC
    private let kOpenRegister = NSNotification.Name(rawValue: "Event_OpenRegister")
    
    public func onOpenRegister(execute block: @escaping () -> Void) {
        nc.addObserver(forName: kOpenRegister, object: nil, queue: OperationQueue.main) { _ in
            block()
        }
    }
    
    public func openRegister() {
        nc.post(name: kOpenRegister, object: nil)
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
