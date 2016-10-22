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
    case error
}

enum LoginResult {
    case success
    case error
}

let registerResultNotification = Notification.Name("registerResultNotification")
let loginResultNotification = Notification.Name("loginResultNotification")

struct InfoKey {
    static let result = "result"
}

class KWNetwork: NSObject, WebSocketDelegate, WebSocketPongDelegate {
    
    // MARK: Constants
    
    private struct RequestURL {
        static let register = URL(string: "http://www.brucedsu.com/kittywar/register/mobile/")
        static let login = URL(string: "http://www.brucedsu.com/kittywar:2056")
    }
    
    private struct RequestFormat {
        static let register = "username=%s&password=%s&email=%s"
        static let login = "username%s&password=%s"
    }
    
    private struct StatusCode {
        static let usernameIsTaken = 409
        static let registerSuccess = 201
    }
    
    private struct ResponseKey {
        static let status = "status"
    }

    // MARK: Properties
    
    private lazy var socket: WebSocket = {
        let s = WebSocket(url: RequestURL.login!)
        return s
    }()
    
    static let shared: KWNetwork = {
        let network = KWNetwork()
        return network
    }()
    
    // MARK: Initialization
    
    override init() {
        
    }
    
    // MARK: Register & Login
    
    func register(username: String, email: String, password: String) {
        // create body string
        let bodyString = String(format: RequestFormat.register,
                                username, password, email)
        
        // create url request
        var request = URLRequest(url: RequestURL.register!)
        request.httpMethod = "POST"
        request.httpBody = bodyString.data(using: .utf8)
        
        // start the session
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // check error first
            if error != nil {
                print("Request error: \(error)")
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    
                    if let status = parsedData[ResponseKey.status] as? Int {
                        let nc = NotificationCenter.default
                        
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
                                    userInfo: [InfoKey.result: RegisterResult.error])
                        }
                    }
                } catch let error as NSError {
                    print("Parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    func login(username: String, password: String) {
        // set delegates
        socket.delegate = self
        socket.pongDelegate = self
        
        // connect
        socket.connect()
        
        // send login message
        let loginString = String(format: RequestFormat.login, username, password)
        socket.write(data: loginString.data(using: .utf8)!)
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
