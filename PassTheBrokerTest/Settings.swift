/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit

class Settings {

    public static let shared = Settings()
    private let ud = UserDefaults.standard
    
    var loggedIn: Bool {
        get {
            return sessionKey != nil && userEmail != nil
        }
    }
    
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
    
    // MARK: - App Version
    private let kAppMajorVersion = "Settings_appMajorVersion"
    var appMajorVersion: Int {
        get {
            return ud.integer(forKey: kAppMajorVersion)
        } set {
            ud.set(newValue, forKey: kAppMajorVersion)
            ud.synchronize()
        }
    }
    
    private let kAppMinorVersion = "Settings_appMinorVersion"
    var appMinorVersion: Int {
        get {
            return ud.integer(forKey: kAppMinorVersion)
        } set {
            ud.set(newValue, forKey: kAppMinorVersion)
            ud.synchronize()
        }
    }
    
    // MARK: - Questions last updated
    private let kVersionLastChecked = "Settings_versionLastChecked"
    var versionShouldUpdate: Bool {
        get {
            let now = Date().timeIntervalSince1970
            let save = {
                self.ud.set(now, forKey: self.kVersionLastChecked)
                self.ud.synchronize()
            }
            
            if appMajorVersion == 0 {
                save()
                return true
            }
            
            if ud.object(forKey: kVersionLastChecked) == nil {
                save()
                return true
            }
            
            let versionLastChecked = ud.double(forKey: kVersionLastChecked)
            print("versionLastChecked: \(versionLastChecked), now = \(now)")
            if now - versionLastChecked > 86400.0 {
                save()
                return true
            }
            
            return false
        }
    }
}
