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
    private let kBaseUrlString = "http://52.206.94.249:5000/api/1/"
    
    // MARK: - Default Call
    fileprivate func request(_ path: String,
                             method: HTTPMethod,
                             body: Parameters?,
                      callback: @escaping (Any?) -> Void) {
        
        let urlString = kBaseUrlString.appending(path)
        
        var headers: HTTPHeaders = ["API_KEY": "abc123",
                                    "CONTENT-TYPE": "application/x-www-form-urlencoded",
                                    "CACHE-CONTROL": "no-cache"]
        
        if let sessionKey = Settings.shared.sessionKey,
            let userEmail = Settings.shared.userEmail {
            headers["SESSION_KEY"] = sessionKey
            headers["EMAIL_KEY"] = userEmail
        }
        print("HTTP Headers for request: \(headers)")
        print("Request params: \(body ?? [:])")
        
        Alamofire.request(urlString, method: method, parameters: body, headers: headers)
            .validate()
            .responseJSON {
                switch $0.result {
                case .success(let value):
                    print("Received response for '\(urlString)': \(value)")
                    callback(value)
                case .failure:
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
                guard let sessionKey = response["sessionUUID"] as? String
                    else {
                        // wrong JSON structure for successful response
                        callback(false, defaultErrorString)
                        return
                }
                
                Settings.shared.sessionKey = sessionKey
                Settings.shared.userEmail = email
                
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
            if let response = $0 as? [String : Any] {
                if let adImageUrlString = response["adImageURL"] as? String,
                    let adClickUrlString = response["adClickURL"] as? String {
                    Settings.shared.adImageUrlString = adImageUrlString
                    Settings.shared.adClickUrlString = adClickUrlString
                } else {
                    // silent
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
                guard let majorVersion = response["majorVersion"] as? Int else {
                    callback(false)
                    return
                }
                
                callback(majorVersion > Settings.shared.appMajorVersion)
                Settings.shared.appMajorVersion = majorVersion
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
                var topics = Topic.cachedList()
                if topics.count > 0 {
                    for topic in topics {
                        states[topic.id] = topic.available
                    }
                    
                    try! realm.write {
                        realm.delete(topics)
                    }
                }
                
                // clear, and add from response
                topics.removeAll()
                for jsonObject in response {
                    if let topic = Topic.from(jsonObject: jsonObject, states: states) {
                        topics.append(topic)
                    }
                }
                
                callback(topics, nil)
                
                // save to database
                try! realm.write {
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
                var questions = Question.cachedList()
                if questions.count > 0 {
                    try! realm.write {
                        realm.delete(questions)
                    }
                }
                
                // clear, and add from response
                questions.removeAll()
                for jsonObject in jsonArray {
                    if let question = Question.from(jsonObject: jsonObject) {
                        questions.append(question)
                    }
                }
                
                callback(questions, nil)
                
                // save to database
                try! realm.write {
                    realm.add(questions)
                }
            } else {
                callback(nil,
                         "Couldn't load questions bank. Please check your internet connection and try again later.")
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
    
    public func receiveTestHistory(_ callback: @escaping (_ testResults: [TestResult]?, _ errorString: String?) -> Void) {
        request("getTestHistory", method: .get, body: nil) {
            if let response = $0 as? [[String : Any]] {                
                let realm = try! Realm()
                
                // delete cached
                var testResults = TestResult.cachedList()
                if testResults.count > 0 {
                    try! realm.write {
                        realm.delete(testResults)
                    }
                }
                
                // clear, and add from response
                testResults.removeAll()
                for jsonObject in response {
                    if let testResult = TestResult.from(jsonObject: jsonObject) {
                        testResults.append(testResult)
                    }
                }
                
                callback(testResults, nil)
                
                // save to database
                try! realm.write {
                    realm.add(testResults)
                }
            } else {
                print("Invalid response")
                callback(nil,
                         "Couldn't load test history. Please check your internet connection and try again later.")
            }
        }
    }
}
