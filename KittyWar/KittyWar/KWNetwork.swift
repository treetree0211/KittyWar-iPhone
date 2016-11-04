//
//  KWNetwork.swift
//  KittyWar
//
//  Created by Hejia Su on 10/20/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import Foundation
import Starscream

enum RegisterResult {
    case usernameIsTaken
    case success
    case fail
}

enum LoginResult {
    case success
    case fail
}

let registerResultNotification = Notification.Name("registerResultNotification")
let loginResultNotification = Notification.Name("loginResultNotification")

struct InfoKey {
    static let result = "result"
    static let token = "token"
}

class KWNetwork: NSObject, WebSocketDelegate, WebSocketPongDelegate {
    
    // MARK: Constants
    
    private struct BaseURL {
        static let local = "http://127.0.0.1:8000/"
        static let remote = "http://www.bruce.com:8000/"
    }

    private struct RequestURL {
        static let register = "kittywar/register/mobile/"
        static let login = "kittywar/login/mobile/"
    }
    
    private struct RequestFormat {
        static let register = "username=%@&password=%@&email=%@"
        static let login = "username%@&password=%@"
    }
    
    private struct StatusCode {
        // register
        static let usernameIsTaken = 409
        static let registerSuccess = 201
        
        // login
        static let loginSuccess = 200
        static let loginFail = 400
    }
    
    private struct ResponseKey {
        static let status = "status"
        static let token = "token"
    }

    // MARK: Properties
    
    // whether server is running on a local machine
    private static let serverIsRunningLocally = true
    
    private lazy var socket: WebSocket = {
        let s = WebSocket(url: URL(string: KWNetwork.getBaseURL() + RequestURL.login)!)
        
        // set delegates
        s.delegate = self
        s.pongDelegate = self
        
        // connect
        s.connect()
        
        return s
    }()
    
    static let shared: KWNetwork = {
        let network = KWNetwork()
        return network
    }()
    
    // MARK: Helper
    
    private static func getBaseURL() -> String {
        return KWNetwork.serverIsRunningLocally ? BaseURL.local : BaseURL.remote
    }
    
    // MARK: Initialization
    
    override init() {
        
    }
    
    // MARK: Register & Login
    
    func register(username: String, email: String, password: String) {
        // create request
        var request = URLRequest(url: URL(string: KWNetwork.getBaseURL() + RequestURL.register)!)
        request.httpMethod = "POST"
        
        // json data
        let jsonDictionary = ["username": username, "password": password, "email": email]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonDictionary,
                                                          options: .prettyPrinted)
        } catch let error as NSError {
            print("JSON error: \(error)")
        }
        
        // start the session
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // check error first
            if error != nil {
                print("Request error: \(error)")
            } else {
                do {
                    let nc = NotificationCenter.default
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                    let status = (parsedData[ResponseKey.status] as! NSString).integerValue
                    
                    DispatchQueue.main.async {  // go back to main thread
                        switch status  {
                        case StatusCode.usernameIsTaken:
                            nc.post(name: registerResultNotification,
                                    object: nil,
                                    userInfo: [InfoKey.result: RegisterResult.usernameIsTaken])
                        case StatusCode.registerSuccess:
                            nc.post(name: registerResultNotification,
                                    object: nil,
                                    userInfo: [InfoKey.result: RegisterResult.success])
                        default:
                            nc.post(name: registerResultNotification,
                                    object: nil,
                                    userInfo: [InfoKey.result: RegisterResult.fail])
                        }
                    }
                } catch let error as NSError {
                    print("Parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    func login(username: String, password: String) {
        // create request
        var request = URLRequest(url: URL(string: KWNetwork.getBaseURL() + RequestURL.login)!)
        request.httpMethod = "POST"
        
        // json data
        let jsonDictionary = ["username": username, "password": password]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonDictionary,
                                                          options: .prettyPrinted)
        } catch let error as NSError {
            print("JSON error: \(error)")
        }

        // start the session
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // check error first
            if error != nil {
                print("Request error: \(error)")
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                    let status = (parsedData[ResponseKey.status] as! NSString).integerValue
                    let token: String? = parsedData[ResponseKey.token] as? String
                    
                    DispatchQueue.main.async {  // go back to main thread
                        let nc = NotificationCenter.default
                        
                        switch status  {
                        case StatusCode.loginSuccess:
                            nc.post(name: loginResultNotification,
                                    object: nil,
                                    userInfo: [InfoKey.result: LoginResult.success, InfoKey.token: token!])
                        case StatusCode.loginFail:
                            nc.post(name: loginResultNotification,
                                    object: nil,
                                    userInfo: [InfoKey.result: LoginResult.fail])
                        default:
                            nc.post(name: loginResultNotification,
                                    object: nil,
                                    userInfo: [InfoKey.result: LoginResult.fail])
                        }
                    }
                } catch let error as NSError {
                    print("Parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    // MARK: WebSocketDelete
    
    func websocketDidConnect(socket: WebSocket) {
        print("Websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("Got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Got some data: \(data.count)")
    }
    
    // MARK: WebSocketPongDelete
    
    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        print("Got pong! Maybe some data: \(data?.count)")
    }
    
}
