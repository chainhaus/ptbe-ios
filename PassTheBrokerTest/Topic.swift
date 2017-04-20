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
    dynamic var available = true
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Caching/Serialization
    
    static func cachedList() -> [Topic] {
        let realm = try! Realm()
        return realm.objects(Topic.self).map { $0 }
    }
    
    public static func from(jsonObject: [String: Any], states: [Int: Bool]) -> Topic? {
        guard
            let id = jsonObject["id"] as? Int,
            let name = jsonObject["topicName"] as? String
            
            else {
                return nil
        }
        
        let topic = Topic()
        topic.id = id
        topic.name = name
        topic.available = states[id] ?? true
        
        return topic
    }
    
    // For backward compability when topics didn't exist
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
