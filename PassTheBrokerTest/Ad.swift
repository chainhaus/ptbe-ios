//
//  Ad.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 24/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import RealmSwift

class Ad: Object {
    
    // MARK: - Entity declaration
    
    dynamic var id = 0
    dynamic var imageUrlString = ""
    dynamic var clickUrlString = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Caching/Serialization
    
    static func cachedList(realm: Realm) -> [Ad] {
        return realm.objects(Ad.self).map { $0 }
    }
    
    static func cachedList() -> [Ad] {
        let realm = try! Realm()
        return realm.objects(Ad.self).map { $0 }
    }
    
    public static func from(jsonObject: [String: Any]) -> Ad? {
        guard
            let id = jsonObject["id"] as? Int,
            let imageUrlString = jsonObject["adImageURL"] as? String,
            let clickUrlString = jsonObject["adClickURL"] as? String
            
            else {
                return nil
        }
        
        let ad = Ad()
        ad.id = id
        ad.imageUrlString = imageUrlString
        ad.clickUrlString = clickUrlString
        
        return ad
    }

}
