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
                      callback: @escaping ([String: Any]?) -> Void) {
        
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
        
        Alamofire.request(urlString, method: method, parameters: body, headers: headers)
            .validate()
            .responseJSON {
                switch $0.result {
                case .success(let value):
                    print("Received response for '\(urlString)': \(value)")
                    callback(value as? [String : Any])
                case .failure:
                    callback(nil)
                }
        }
        
//        // generate query string
//        var queryPairs: [String] = []
//        for (key, value) in params {
//            let pair = key
//                .appending("=")
//                .appending(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//            queryPairs.append(pair)
//        }
//        let queryString = queryPairs.joined(separator: "&")
//        
//        // generate url string
//        var urlString = kBaseUrlString.appending(path)
//        if httpMethod == .get {
//            urlString.append("?".appending(queryString))
//        }
//        
//        // make request
//        var request = URLRequest(url: URL(string: urlString)!,
//                                 cachePolicy: .useProtocolCachePolicy,
//                                 timeoutInterval: 10)
//        request.httpMethod = httpMethod.rawValue
//        
//        if httpMethod != .get {
//            request.httpBody = queryString.data(using: .utf8)
//        }
//        
//        let headers = ["api_key": "abc123",
//                       "content-type": "application/x-www-form-urlencoded",
//                       "cache-control": "no-cache"]
//        request.allHTTPHeaderFields = headers
//        
//        // prepare call
//        let errorCallback = {
//            OperationQueue.main.addOperation {
//                callback(nil)
//            }
//        }
//        
//        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                print("Caught an error on calling \(urlString): \(error.localizedDescription)")
//                errorCallback()
//            } else {
//                do {
//                    guard let response: [String: Any] =
//                        try JSONSerialization.jsonObject(with: data!,
//                                                         options: .mutableContainers) as? [String: Any]
//                        else {
//                            errorCallback()
//                            return
//                    }
//                    
//                    OperationQueue.main.addOperation {
//                        callback(response)
//                    }
//                } catch (_) {
//                    errorCallback()
//                }
//            }
//        }
//        
//        // fire
//        dataTask.resume()
    }
}

// MARK: - Log in / Register

extension Api {
    
    public func login(email: String,
                      password: String,
                      callback: @escaping (_ loggedIn: Bool, _ errorString: String?) -> Void) {
        
        let defaultErrorString = "Couldn't authenticate"
        
        request("authenticateUser", method: .post, body: ["email": email, "password": password]) {
            guard let response = $0 else {
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
                        
                        guard let response = $0 else {
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
            if let response = $0 {
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
            if let response = $0 {
                guard let appVersion = response["majorVersion"] as? Int else {
                    callback(false)
                    return
                }
                
                callback(appVersion > Settings.shared.appVersion)
                Settings.shared.appVersion = appVersion
            } else {
                callback(false)
            }
        }
    }
}

// MARK: - Questions

extension Api {
    
    public func receiveQuestions(_ callback: @escaping (_ questions: [Question]?, _ errorString: String?) -> Void) {
        request("getQuestionBank", method: .get, body: nil) {
            if let response = $0 {
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
                    if let response = $0 {
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
}
