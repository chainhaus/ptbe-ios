/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.

 */

import UIKit
import IQKeyboardManager
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let strService = "http://52.206.94.249:5000/api/1/" // This should be moved out of here
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().isEnabled = true
      
        // Make Realm encrypt all data
        autoreleasepool {
            let configuration = Realm.Configuration(encryptionKey: getKey() as Data)
            do {
                _ = try Realm(configuration: configuration)
                Realm.Configuration.defaultConfiguration = configuration
            } catch {
                abort()
            }
        }
        
        return true
    }
    
    private func getKey() -> NSData {
        let keychainIdentifier      = "com.overridelabs.ptbe.ny.sales.Realm"
        let keychainIdentifierData  = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        var query: [NSString: AnyObject] = [
            kSecClass:              kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits:  512 as AnyObject,
            kSecReturnData:         true as AnyObject
        ]
        
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if status == errSecSuccess {
            return dataTypeRef as! NSData
        }
        
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64,
                                        keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")
        
        query = [
            kSecClass:              kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits:  512 as AnyObject,
            kSecValueData:          keyData
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain with status \(status)")
        
        return keyData
    }
}

