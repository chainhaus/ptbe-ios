/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.

 */

import UIKit
import IQKeyboardManager
import RealmSwift
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().isEnabled = true
        
        // Apple recommends to register a transaction observer as soon as the app starts:
        //
        // - Adding your app's observer at launch ensures that it will persist during all launches of your app, 
        //   thus allowing your app to receive all the payment queue notifications.
        SwiftyStoreKit.completeTransactions(atomically: true) { products in
            for product in products {
                if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                    
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                }
            }
        }
      
        // Make Realm encrypt all data
        autoreleasepool {
            let configuration = Realm.Configuration(
                encryptionKey: getKey() as Data,
                
                schemaVersion: RealmMigrations.schemaVersion,
                migrationBlock: RealmMigrations.migrationHandler)
            
            
            do {
                _ = try Realm(configuration: configuration)
                Realm.Configuration.defaultConfiguration = configuration
            } catch {
                abort()
            }
        }
        
        Test.make()
        
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

