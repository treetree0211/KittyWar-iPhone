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

enum FindGameResult {
    case success
    case fail
}

let registerResultNotification = Notification.Name("registerResultNotification")
let loginResultNotification = Notification.Name("loginResultNotification")
let findGameResultNotification = Notification.Name("findGameResultNotification")

struct InfoKey {
    static let result = "result"
    static let token = "token"
    static let username = "username"
}

class KWNetwork: NSObject, WebSocketDelegate, WebSocketPongDelegate {
    
    // MARK: - Constants
    
    private struct WebServerBaseURL {
        static let local = "http://127.0.0.1:8000/"
        static let remote = "http://www.bruce.com:8000/"
    }
    
    private struct GameServerURL {
        static let local = "http://127.0.0.1:2056/"
        static let remote = "http://www.bruce.com:2056/"
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
    
    private struct GameServerFlag {
        static let login: UInt8 = 0
        static let logout: UInt8 = 1
        static let findMatch: UInt8 = 2
    }

    // MARK: - Properties
    
    // whether server is running on a local machine
    private static let serversAreRunningLocally = true
    
    private lazy var socket: WebSocket = {
        let socket = WebSocket(url: URL(string: KWNetwork.getGameServerURL())!)
        
        // set delegates
        socket.delegate = self
        socket.pongDelegate = self
        
        // set header
//        socket.headers["Sec-WebSocket-Protocol"] = ""
//        socket.headers["Sec-WebSocket-Version"] = ""
//        socket.headers["My-Awesome-Header"] = ""
        
        return socket
    }()
    
    static let shared: KWNetwork = {
        let network = KWNetwork()
        return network
    }()
    
    // MARK: - Get Web Server/ Game Server (Base) URL
    
    private static func getWebServerBaseURL() -> String {
        return KWNetwork.serversAreRunningLocally ? WebServerBaseURL.local : WebServerBaseURL.remote
    }
    
    private static func getGameServerURL() -> String {
        return KWNetwork.serversAreRunningLocally ? GameServerURL.local : GameServerURL.remote
    }
    
    // MARK: - Initialization
    
    override init() {
        
    }
    
    // MARK: - Webserver Register & Login
    
    func register(username: String, email: String, password: String) {
        // create request
        var request = URLRequest(url: URL(string: KWNetwork.getWebServerBaseURL() + RequestURL.register)!)
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
        var request = URLRequest(url: URL(string: KWNetwork.getWebServerBaseURL() + RequestURL.login)!)
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
                                    userInfo: [InfoKey.result: LoginResult.success, InfoKey.username: username, InfoKey.token: token!])
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
    
    // MARK: - Game Server
    
    // flag (1 byte) + token (24 bytes) + sizeOfData (3 bytes)
    private func getMessagePrefix(flag: UInt8, sizeOfData: Int) -> [UInt8] {
        var result = [UInt8]()
        
        // insert flag at the beginning
        result.insert(flag, at: 0);

        // append token
        let token = KWUserDefaults.getToken()
        result += DSConvertor.stringToBytes(string: token)
        
        // append size of data
        let sizeByteArray = DSConvertor.intToByteArray(number: sizeOfData)
        result += sizeByteArray.suffix(3)  // last three bytes
        
        return result
    }
    
    private func connectToGameServer() {
        if socket.isConnected {
            print("Web socket is connected")
            return
        }
        
        // connect
        socket.connect()
        
        if (socket.isConnected) {
            print("Connection is successful")
            
            // create login data
            let username = KWUserDefaults.getUsername()
            var bytes = getMessagePrefix(flag: GameServerFlag.login, sizeOfData: username.characters.count)
            bytes += DSConvertor.stringToBytes(string: username)
            let loginData = Data(bytes: bytes)
            
            // send login data
            socket.write(data: loginData)

        } else {
            print("Connection is failure")
        }
    }
    
    func findMatch(token: String) {
        connectToGameServer()
        
        // TODO: update this to use server API
        // socket.write(string: "Find Game")
    }
    
    // MARK: - WebSocketDelegate
    
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
    
    // MARK: - WebSocketPongDelegate
    
    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        print("Got pong! Maybe some data: \(data?.count)")
    }
    
}
