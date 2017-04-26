/*
 
 Copyright © 2017 Override Labs. All Rights Reserved.
 
 */

import UIKit
import Alamofire
import RealmSwift

fileprivate let kStatusCode = "statusCode"
fileprivate let kStatus = "status"

class Api {
    
    // MARK: - Static
    
    public static let shared = Api()
    private let kBaseUrlString = "https://api.passthebrokerexam.com/api/1/"
    
    // MARK: - Default Call
    private lazy var manager: SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = ["api.passthebrokerexam.com": .disableEvaluation]
        
        return SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    fileprivate func request(_ path: String,
                             method: HTTPMethod,
                             body: Parameters?,
                      callback: @escaping (Any?) -> Void) {
        
        let urlString = kBaseUrlString.appending(path)
        
        var headers: HTTPHeaders = ["API_KEY": "abc123",
                                    "APP_ID" : "1",
                                    "CONTENT-TYPE": "application/x-www-form-urlencoded",
                                    "CACHE-CONTROL": "no-cache"]
        
        if let sessionKey = Settings.shared.sessionKey,
            let userEmail = Settings.shared.userEmail {
            headers["SESSION_KEY"] = sessionKey
            headers["EMAIL_KEY"] = userEmail
        }
        print("HTTP Headers for request: \(headers)")
        print("Request params: \(body ?? [:])")
        
        manager.request(urlString, method: method, parameters: body, headers: headers)
            .validate()
            .responseJSON {
                switch $0.result {
                case .success(let value):
                    print("Received response for '\(urlString)': \(value)")
                    callback(value)
                case .failure(let error):
                    print("Request for '\(urlString)' resulted in error: '\(error.localizedDescription)'")
                    callback(nil)
                }
        }
    }
}

// MARK: - Log in / Register / Reset Password / Change Password

extension Api {
    
    public func login(email: String,
                      password: String,
                      callback: @escaping (_ loggedIn: Bool, _ errorString: String?) -> Void) {
        
        let defaultErrorString = "Couldn't authenticate"
        
        request("authenticateUser", method: .post, body: ["email": email, "password": password]) {
            guard let response = $0 as? [String : Any] else {
                // no response
                callback(false, "Coudn't connect to the server")
                return
            }
            
            guard let statusCode = response[kStatusCode] as? Int
                else {
                    // wrong JSON structure
                    callback(false, defaultErrorString)
                    return
            }
            
            if statusCode != 0 {
                var errorString = defaultErrorString
                if let providedErrorString = response[kStatus] as? String {
                    errorString = providedErrorString
                }
                callback(false, errorString)
            } else {
                guard let sessionKey = response["sessionUUID"] as? String,
                    let premiumUser = response["premiumUser"] as? Bool
                    else {
                        // wrong JSON structure for successful response
                        callback(false, defaultErrorString)
                        return
                }
                
                Settings.shared.sessionKey = sessionKey
                Settings.shared.userEmail = email
                            
                if Test.of(kind: Test.premiumKinds.first!).purchased != premiumUser {
                    // silently try to send purchase to API
                    self.submitPurchase(callback: nil)
                }
                
                callback(true, nil)
            }
        }
    }
    
    public func register(email: String,
                         password: String,
                         firstName: String,
                         lastName: String,
                         callback: @escaping (_ registered: Bool, _ errorString: String?) -> Void) {
        
        let defaultErrorString = "Couldn't sign up"
        
        request("submitSignUp",
                method: .post,
                body: ["email":     email,
                       "password":  password,
                       "fname":     firstName,
                       "lname":     lastName]) {
                        
                        guard let response = $0 as? [String : Any] else {
                            // no response
                            callback(false, "Coudn't connect to the server")
                            return
                        }
                        
                        guard let statusCode = response[kStatusCode] as? Int
                            else {
                                // wrong JSON structure
                                callback(false, defaultErrorString)
                                return
                        }
                        
                        if statusCode != 0 {
                            var errorString = defaultErrorString
                            if let providedErrorString = response[kStatus] as? String {
                                errorString = providedErrorString
                            }
                            callback(false, errorString)
                        } else {
                            callback(true, nil)
                        }
        }
    }
    
    public func resetPassword(for email: String, callback: @escaping (_ resetted: Bool, _ errorString: String?) -> Void) {
        let defaultErrorString = "Couldn't send reset password e-mail"
        
        request("resetPassword", method: .post, body: ["email": email]) {
            
            guard let response = $0 as? [String : Any] else {
                // no response
                callback(false, "Coudn't connect to the server")
                return
            }
            
            guard let statusCode = response[kStatusCode] as? Int
                else {
                    // wrong JSON structure
                    callback(false, defaultErrorString)
                    return
            }
            
            if statusCode != 0 {
                var errorString = defaultErrorString
                if let providedErrorString = response[kStatus] as? String {
                    errorString = providedErrorString
                }
                callback(false, errorString)
            } else {
                callback(true, nil)
            }
        }
    }
    
    public func changePassword(to newPassword: String, callback: @escaping (_ changed: Bool, _ errorString: String?) -> Void) {
        let defaultErrorString = "Couldn't change your password"
        
        request("changePassword", method: .post, body: ["newPassword": newPassword]) {
            
            guard let response = $0 as? [String : Any] else {
                // no response
                callback(false, "Coudn't connect to the server")
                return
            }
            
            guard let statusCode = response[kStatusCode] as? Int
                else {
                    // wrong JSON structure
                    callback(false, defaultErrorString)
                    return
            }
            
            if statusCode != 0 {
                var errorString = defaultErrorString
                if let providedErrorString = response[kStatus] as? String {
                    errorString = providedErrorString
                }
                callback(false, errorString)
            } else {
                callback(true, nil)
            }
        }
    }
}

// MARK: - Ad

extension Api {
    
    public func receiveAd(callback: @escaping () -> Void) {
        request("getAd", method: .get, body: nil) {
            if let response = $0 as? [[String : Any]] {
                let realm = try! Realm()
                
                // delete cached
                let adsToDelete = Ad.cachedList(realm: realm)
                
                // clear, and add from response
                var ads: [Ad] = []
                
                for jsonObject in response {
                    if let ad = Ad.from(jsonObject: jsonObject) {
                        ads.append(ad)
                    }
                }
                
                // save to database
                try! realm.write {
                    if adsToDelete.count > 0 {
                        realm.delete(adsToDelete)
                    }
                    
                    realm.add(ads)
                }
            } else {
                // silent
            }
            
            callback()
        }
    }
}

// MARK: - Version

extension Api {
    
    public func receiveVersion(callback: @escaping (_ versionIncreased: Bool) -> Void) {
        request("getVersion", method: .get, body: nil) {
            if let response = $0 as? [String : Any] {
                guard let majorVersion = response["majorVersion"] as? Int,
                    let minorVersion = response["minorVersion"] as? Int
                    
                    else {
                    callback(false)
                    return
                }
                
                callback(majorVersion > Settings.shared.appMajorVersion)
                Settings.shared.appMajorVersion = majorVersion
                Settings.shared.appMinorVersion = minorVersion
            } else {
                callback(false)
            }
        }
    }
}

// MARK: - Questions

extension Api {
    
    public func receiveTopics(_ callback: @escaping (_ questions: [Topic]?, _ errorString: String?) -> Void) {
        request("getTopics", method: .get, body: nil) {
            if let response = $0 as? [[String : Any]] {
                let realm = try! Realm()
                
                var states: [Int: Bool] = [:]
                
                // delete cached
                let topicsToDelete = Topic.cachedList(realm: realm)
                if topicsToDelete.count > 0 {
                    for topic in topicsToDelete {
                        states[topic.id] = topic.available
                    }
                }
                
                // clear, and add from response
                var topics: [Topic] = []
                for jsonObject in response {
                    if let topic = Topic.from(jsonObject: jsonObject, states: states) {
                        topics.append(topic)
                    }
                }
                
                callback(topics, nil)
                
                // save to database
                try! realm.write {
                    if topicsToDelete.count > 0 {
                        realm.delete(topicsToDelete)
                    }
                    
                    realm.add(topics)
                }
            } else {
                callback(nil,
                         "Couldn't load topics. Please check your internet connection and try again later.")
            }
        }
    }
    
    public func receiveQuestions(_ callback: @escaping (_ questions: [Question]?, _ errorString: String?) -> Void) {
        let path = Test.of(kind: Test.premiumKinds.first!).purchased ? "getQuestionBankPremium" : "getQuestionBank"
        
        request(path, method: .get, body: nil) {
            if let response = $0 as? [String : Any] {
                guard let statusCode = response[kStatusCode] as? Int,
                    let jsonArray = response["questions"] as? [[String : Any]],
                    statusCode == 0 else {
                        
                    callback(nil, "Couldn't load questions bank")
                    return
                }
                
                let realm = try! Realm()
                
                // delete cached
                let questionsToDelete = Question.cachedList(realm: realm)
                
                // clear, and add from response
                var questions: [Question] = []
                var questionIds: [Int] = []
                
                for jsonObject in jsonArray {
                    if let question = Question.from(jsonObject: jsonObject),
                        !questionIds.contains(question.id) {
                        questionIds.append(question.id)
                        questions.append(question)
                    }
                }
                
                callback(questions, nil)
                
                // save to database
                print("Write \(questions.count) questions")
                try! realm.write {
                    if questionsToDelete.count > 0 {
                        realm.delete(questionsToDelete)
                    }
                    
                    realm.add(questions)
                }
            } else {
                callback(nil,
                         "Couldn't load questions bank. Please check your internet connection and try again later.")
            }
        }
    }
    
    public func submitPurchase(callback: ((_ submitted: Bool) -> Void)?) {
        request("purchaseInAppMade",
                method: .post,
                body: nil) {
                        if let response = $0 as? [String : Any] {
                            guard let statusCode = response[kStatusCode] as? Int,
                                statusCode == 0 else {
                                    if let callback = callback {
                                        callback(false)
                                    }
                                    return
                            }
                            
                            if let callback = callback {
                                callback(true)
                            }
                        } else {
                            if let callback = callback {
                                callback(false)
                            }
                        }
        }
    }
}

// MARK: - Tests

extension Api {
    
    public func submitResult(of test: Test, callback: @escaping (_ submitted: Bool) -> Void) {
        request("submitTestResult",
                method: .post,
                body: ["testName":          test.kind.textRepresentation(),
                       "totalQuestions":    test.questionsCount,
                       "answeredCorrect":   test.rightAnswersCount]) {
                    if let response = $0 as? [String : Any] {
                        guard let statusCode = response[kStatusCode] as? Int,
                            statusCode == 0 else {
                                callback(false)
                                return
                        }
                        
                        callback(true)
                    } else {
                        callback(false)
                    }
        }
    }
    
    public func receiveTestHistory(callback: ((_ testResults: [TestResult]?, _ errorString: String?) -> Void)?) {
        request("getTestHistory", method: .get, body: nil) {
            if let response = $0 as? [[String : Any]] {                
                let realm = try! Realm()
                
                // delete cached
                let testResultsToDelete = TestResult.cachedList()
                
                // clear, and add from response
                var testResults: [TestResult] = []
                for jsonObject in response {
                    if let testResult = TestResult.from(jsonObject: jsonObject) {
                        testResults.append(testResult)
                    }
                }
                
                if let callback = callback {
                    callback(testResults, nil)
                }
                
                // save to database
                try! realm.write {
                    if testResultsToDelete.count > 0 {
                        realm.delete(testResultsToDelete)
                    }
                    
                    realm.add(testResults)
                }
            } else {
                print("Invalid response")
                if let callback = callback {
                    callback(nil,
                             "Couldn't load test history. Please check your internet connection and try again later.")
                }
            }
        }
    }
}
