//
//  Settings.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 18/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import UIKit

class Settings {

    public static let shared = Settings()
    private let ud = UserDefaults.standard
    
    // MARK: - Session Key
    private let kSessionKey = "Settings_sessionKey"
    var sessionKey: String? {
        get {
            return ud.string(forKey: kSessionKey)
        } set {
            ud.set(newValue, forKey: kSessionKey)
            ud.synchronize()
        }
    }
    
    // MARK: - User Email
    private let kUserEmail = "Settings_userEmail"
    var userEmail: String? {
        get {
            return ud.string(forKey: kUserEmail)
        } set {
            ud.set(newValue, forKey: kUserEmail)
            ud.synchronize()
        }
    }
    
    // MARK: - Ad Image URL
    private let kAdImageUrlString = "Settings_adImageUrlString"
    var adImageUrlString: String? {
        get {
            return ud.string(forKey: kAdImageUrlString)
        } set {
            ud.set(newValue, forKey: kAdImageUrlString)
            ud.synchronize()
        }
    }
    
    // MARK: - Ad Click URL
    private let kAdClickUrlString = "Settings_adClickUrlString"
    var adClickUrlString: String? {
        get {
            return ud.string(forKey: kAdClickUrlString)
        } set {
            ud.set(newValue, forKey: kAdClickUrlString)
            ud.synchronize()
        }
    }
    
    // MARK: - App Version
    private let kAppVersion = "Settings_appVersion"
    var appVersion: Int {
        get {
            return ud.integer(forKey: kAppVersion)
        } set {
            ud.set(newValue, forKey: kAppVersion)
            ud.synchronize()
        }
    }
    
    // MARK: - Questions Last updated
    private let kVersionLastChecked = "Settings_versionLastChecked"
    var versionShouldUpdate: Bool {
        get {
            if ud.object(forKey: kVersionLastChecked) == nil {
                return true
            }
            
            let now = Date().timeIntervalSince1970
            let versionLastChecked = ud.double(forKey: kVersionLastChecked)
            
            if now - versionLastChecked > 86400.0 {
                ud.set(now, forKey: kVersionLastChecked)
                ud.synchronize()
                
                return true
            }
            
            return false
        }
    }
}
