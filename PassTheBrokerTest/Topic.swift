/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import RealmSwift

class Topic: Object {
    
    public static func ==(lhs: Topic, rhs: Topic) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Entity declaration
    
    dynamic var id = 0
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Factory
    
    public static func from(id: Int, name: String) -> Topic {
        let realm = try! Realm()
        if let topic = realm.object(ofType: Topic.self, forPrimaryKey: id) {
            return topic
        }
        
        let topic = Topic()
        topic.id = id
        topic.name = name
        
        try! realm.write {
            realm.add(topic)
        }
        
        return topic
    }
}
