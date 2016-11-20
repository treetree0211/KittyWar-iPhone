//
//  KWNetwork.swift
//  KittyWar
//
//  Created by Hejia Su on 10/20/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import Foundation
import SwiftSocket

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

class KWNetwork: NSObject {
    
    // MARK: - Constants
    
    private struct HTTPRequestMethod {
        static let post = "POST"
    }
    
    private struct WebServerBaseURL {
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
    
    private struct GameServerURL {
        static let local = "127.0.0.1"
        static let remote = "www.bruce.com"
        static let port: Int32 = 2056
    }
    
    private struct GameServerFlag {
        static let login: UInt8 = 0
        static let logout: UInt8 = 1
        static let findMatch: UInt8 = 2
        static let userProfile: UInt8 = 3
        static let allCards: UInt8 = 4
        static let catCards: UInt8 = 5
        static let basicCards: UInt8 = 6
        static let chanceCards: UInt8 = 7
        static let abilityCards: UInt8 = 8
    }

    // MARK: - Properties
    
    // whether server is running on a local machine
    private static let serversAreRunningLocally = true
    
    private lazy var client: TCPClient = {
        let client = TCPClient(address: KWNetwork.getGameServerURL(),
                               port: GameServerURL.port)
        return client
    }()
    
    private var isConnectedToGameServer = false
    
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
        request.httpMethod = HTTPRequestMethod.post
        
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
        request.httpMethod = HTTPRequestMethod.post
        
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
    
    // return true if connected to the game server, otherwise return false
    private func connectToGameServer() -> Bool {
        if isConnectedToGameServer {
            return true
        }
        
        // create login data
        let username = KWUserDefaults.getUsername()
        var bytes = getMessagePrefix(flag: GameServerFlag.login, sizeOfData: username.characters.count)
        bytes += DSConvertor.stringToBytes(string: username)
        let loginData = Data(bytes: bytes)

        switch client.connect(timeout: 10) {
        case .success:
            switch client.send(data: loginData) {
            case .success:
                guard let data = client.read(1024 * 10) else {
                    return false
                }
                
                // check returned data
                if data[3] == 1 && data[4] == 1 {  // success
                    isConnectedToGameServer = true
                    print("Connection to game server success!")
                    return true
                } else {  // failure
                    isConnectedToGameServer = false
                    print("Connection to game server failed!")
                    return false
                }
            case .failure (let error):
                print("Authentication failed, error \(error)")
            }
        case .failure (let error):
            print("Connection to game server failed, error: \(error)")
            return false
        }
        
        return false
    }
    
    func findMatch(token: String) {
        if !connectToGameServer() {
            return
        }
        
        // TODO: update this to use server API
        // socket.write(string: "Find Game")
    }
    
}
