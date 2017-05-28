/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import RealmSwift

class Test: Object {
    
    // MARK: - Entity declaration
    
    enum Kind: Int {
        case dabble, play, grind
        
        func textRepresentation() -> String {
            let strings: [Kind: String] = [.dabble: "Dabble",
                                           .play:   "Play",
                                           .grind:  "Grind"]
            
            return strings[self]!
        }
    }
    
    public static let freeKinds: [Kind] = [.dabble]
    public static let premiumKinds: [Kind] = [.play, .grind]
    
    dynamic var kindInt = 0
    dynamic var purchased = false
    
    var kind: Kind! {
        get {
            return Kind(rawValue: kindInt)
        } set {
            kindInt = newValue.rawValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "kindInt"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["kind", "questionsCount", "questions", "answers", "score", "rightAnswersCount"]
    }
    
    // MARK: - Static Getter
    
    public static func of(kind: Kind) -> Test {
        let realm = try! Realm()
        return realm.object(ofType: Test.self, forPrimaryKey: kind.rawValue)!
    }
    
    // MARK: - First launch initialization
    
    public static func make() {
        var tests: [Test] = []
        
        for kind in freeKinds + premiumKinds {
            if of(kind: kind) == nil {
                let test = Test()
                test.kind = kind
                test.purchased = freeKinds.contains(kind)
                tests.append(test)
            }
        }
        
        if tests.count > 0 {
            let realm = try! Realm()
            try! realm.write {
                realm.add(tests)
            }
        }
        
        Event.shared.onPurchase {
            let realm = try! Realm()
            
            for kind in premiumKinds {
                let test: Test = of(kind: kind)
                print("Write purchased test \(test.kind)")
                try! realm.write {
                    test.purchased = true
                }
            }
        }
    }
    
    private static func of(kind: Kind) -> Test? {
        let realm = try! Realm()
        return realm.object(ofType: Test.self, forPrimaryKey: kind.rawValue)
    }
    
    // MARK: - Model
    
    public lazy var questionsCount: Int = {
        let counts: [Kind: Int] = [.dabble: 10,
                                   .play:   50,
                                   .grind:  100]
        return counts[self.kind]!
    }()
    
    public var hasEnoughAvailableTopics: Bool {
        get {
            var availableTopics: [Topic] = []
            
            for topic in Topic.cachedList() {
                if topic.available {
                    availableTopics.append(topic)
                }
            }
            
            var questionsFound = 0
            
            for question in Question.cachedList() {
                if availableTopics.contains(question.topic) {
                    questionsFound += 1
                }
                
                if questionsFound == questionsCount {
                    return true
                }
            }
            
            return false
        }
    }
    
    public lazy var questions: [Question] = {
        var questions: [Question] = []
        var availableTopics: [Topic] = []
        
        for topic in Topic.cachedList() {
            if topic.available {
                availableTopics.append(topic)
            }
        }
        
        var questionsForAvailableTopics: [Question] = []
        for question in Question.cachedList() {
            if availableTopics.contains(question.topic) {
                questionsForAvailableTopics.append(question)
            }
        }
        
        for i in 1...self.questionsCount {
            let question = questionsForAvailableTopics[Int(arc4random_uniform(UInt32(questionsForAvailableTopics.count)))]
            questionsForAvailableTopics.remove(at: questionsForAvailableTopics.index(of: question)!)
            questions.append(question)
        }
        
        return questions
    }()
    
    private var answers: [Question: Int] = [:]
    
    public func answer(question: Question, choice: Int) {
        answers[question] = choice
    }
    
    public func answer(for question: Question) -> Int {
        guard let choice = answers[question] else {
            return -1
        }
        
        return choice
    }
    
    var rightAnswersCount: Int {
        get {
            var rightAnswersCount = 0
            for (question, choice) in answers {
//                print("Question \(question.question) has answer: \(choice), while right is: \(question.answer)")
                if choice == question.answer - 1 { // remove 1 due to starting from 1, not zero
                    rightAnswersCount += 1
                }
            }
            
            return rightAnswersCount
        }
    }
    
    var score: Double {
        get {
//            print("Right answers count: \(rightAnswersCount), questions count: \(questionsCount), score: \(Double(rightAnswersCount) / Double(questionsCount) * 100.0)")
            return Double(rightAnswersCount) / Double(questionsCount) * 100.0
        }
    }
    
    var topics: [Topic] {
        get {
            var topics: [Topic] = []
            for question in questions {
                if !topics.contains(question.topic) {
                    topics.append(question.topic)
                }
            }
            
            return topics
        }
    }
    
    public func score(by topic: Topic) -> Double {
        var rightAnswersCount = 0
        var questionsCount = 0
        for question in questions {
            if question.topic == topic {
                questionsCount += 1
                
                if answer(for: question) == question.answer - 1 { // remove 1 due to starting from 1, not zero
                    rightAnswersCount += 1
                }
            }
        }
//        print("Score by topic. Right answers count: \(rightAnswersCount), questions count: \(questionsCount), score: \(Double(rightAnswersCount) / Double(questionsCount) * 100.0)")
        
        return Double(rightAnswersCount) / Double(questionsCount) * 100.0
    }
}
