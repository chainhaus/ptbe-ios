//
//  TestResult.swift
//  PassTheBrokerTest
//
//  Created by Aleksandr Poddubny on 20/04/2017.
//  Copyright © 2017 MitsSoft. All rights reserved.
//

import RealmSwift

class TestResult: Object {
    
    // MARK: - Entity declaration
    
    dynamic var id = ""
    dynamic var testName = ""
    dynamic var dateRaw = 0.0
    dynamic var score = 0.0
    dynamic var email: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["date"]
    }
    
    var date: Date {
        return Date(timeIntervalSince1970: dateRaw)
    }
    
    // MARK: - Caching/Serialization
    
    static func cachedList(realm: Realm) -> [TestResult] {
        return realm.objects(TestResult.self)
            .map { $0 }
            .filter { $0.email == Settings.shared.userEmail }
    }
    
    static func cachedList() -> [TestResult] {
        let realm = try! Realm()
        return cachedList(realm: realm)
    }
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        // Wed Apr 19 22:02:50 EST 2017
        dateFormatter.dateFormat = "E MMM dd HH:mm:ss zzz yyyy"
        
        return dateFormatter
    }()
    
    public static func from(jsonObject: [String: Any]) -> TestResult? {
        guard
            let id = jsonObject["id"] as? Int,
            let dateString = jsonObject["date"] as? String,
            let date = dateFormatter.date(from: dateString)?.timeIntervalSince1970,
            let score = jsonObject["score"] as? Double,
            let testName = jsonObject["testName"] as? String
            
            else {
                return nil
        }
        
        let email = Settings.shared.userEmail!
        
        let testResult = TestResult()
        testResult.id = email.appending("_").appending(String(id))
        testResult.dateRaw = date
        testResult.score = score * 100
        testResult.testName = testName
        testResult.email = email
        
        return testResult
    }
    
    public static func make(from test: Test) {
        let realm = try! Realm()
        
        let testResult = TestResult()
        testResult.id = UUID().uuidString
        testResult.dateRaw = Date().timeIntervalSince1970
        testResult.score = test.score
        testResult.testName = test.kind.textRepresentation()
        testResult.email = nil
        
        try! realm.write {
            realm.add(testResult)
        }
    }
}
