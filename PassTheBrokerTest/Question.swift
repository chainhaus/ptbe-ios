/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import RealmSwift

class Question: Object {
    
    // MARK: - Entity declaration
    
    dynamic var id = 0
    
    dynamic var topicId = 0
    dynamic var topicName = ""
    
    dynamic var question = ""
    dynamic var answer = 0
    dynamic var choice1 = ""
    dynamic var choice2 = ""
    dynamic var choice3 = ""
    dynamic var choice4 = ""
    dynamic var choice5 = ""
    
    var topic: Topic! {
        get {
            return Topic.from(id: topicId, name: topicName)
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["topic"]
    }
    
    // MARK: - Caching/Serialization
    
    static func cachedList(realm: Realm) -> [Question] {
        return realm.objects(Question.self).map { $0 }
    }
    
    static func cachedList() -> [Question] {
        let realm = try! Realm()
        return cachedList(realm: realm)
    }
    
    public static func from(jsonObject: [String: Any]) -> Question? {
        guard
            let id = jsonObject["id"] as? Int,
            let topicId = jsonObject["topicId"] as? Int,
            let topicName = jsonObject["topicName"] as? String,
            let questionString = jsonObject["question"] as? String,
            let answer = jsonObject["answer"] as? Int,
            let choice1 = jsonObject["choice1"] as? String,
            let choice2 = jsonObject["choice2"] as? String,
            let choice3 = jsonObject["choice3"] as? String,
            let choice4 = jsonObject["choice4"] as? String,
            let choice5 = jsonObject["choice5"] as? String
        
            else {
                return nil
        }
        
        let question = Question()
        question.id = id
        question.topicId = topicId
        question.topicName = topicName
        question.question = questionString
        question.answer = answer
        question.choice1 = choice1
        question.choice2 = choice2
        question.choice3 = choice3
        question.choice4 = choice4
        question.choice5 = choice5
        
        return question
    }
}
