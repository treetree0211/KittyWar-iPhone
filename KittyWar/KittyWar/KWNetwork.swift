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
    case failure
}

enum LoginResult {
    case success
    case failure
}

enum FindMatchResult {
    case success
    case failure
}

enum SelectCatResult {
    case success
    case failure
}

enum ReadyResult {
    case success
    case failure
}

let registerResultNotification = Notification.Name("registerResultNotification")
let loginResultNotification = Notification.Name("loginResultNotification")
let findMatchResultNotification = Notification.Name("findMatchResultNotification")
let selectCatResultNotification = Notification.Name("selectCatResultNotification")
let setupGameNotification = Notification.Name("setupGameNotification")

let readyNotification = Notification.Name("readyNotification")

struct InfoKey {
    static let result = "result"
    static let token = "token"
    static let username = "username"
    static let opponentCatID = "opponentCatID"
    static let randomAbilityID = "randomAbilityID"
    static let chanceCards = "chanceCards"
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
        static let ready: UInt8 = 99
        static let nextPhase: UInt8 = 98
        static let selectCat: UInt8 = 100
        static let opponentCat: UInt8 = 49
        static let randomAbility: UInt8 = 56
        
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
                                    userInfo: [InfoKey.result: RegisterResult.failure])
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
                                    userInfo: [InfoKey.result: LoginResult.failure])
                        default:
                            nc.post(name: loginResultNotification,
                                    object: nil,
                                    userInfo: [InfoKey.result: LoginResult.failure])
                        }
                    }
                } catch let error as NSError {
                    print("Parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    // MARK: - Parse Game Server Response
    
    enum  BodyType {
        case int
        case string
        case intArray
        case json
    }
    
    private func parseGameServerResponse(response: [UInt8], bodyType: BodyType) -> (flag: UInt8, sizeOfBody: Int, bodyString: String?, bodyInt: Int?, bodyIntArray: [Int]?) {
        print("Response: \(response)")
        
        // process flag
        let flag: UInt8 = response[0]
        print("Response flag: \(flag)")
            
        // data size
        var sizeBytes = response[1...3]
        sizeBytes = [0, 0, 0, 0, 0] + sizeBytes
        let data = Data(bytes: sizeBytes)
        let sizeOfBody = Int(bigEndian: data.withUnsafeBytes { $0.pointee })
        print("Response body size: \(sizeOfBody)")
        
        var bodyString: String? = nil
        var bodyInt: Int? = nil
        var bodyIntArray: [Int]? = nil
        
        // process body
        if response.count > 4 {
            switch bodyType {
            case .int:
                bodyInt = Int(response[4])
                print("Response body int: \(bodyInt!)")
            case .string:
                let stringBytes = response[4...response.count - 1]
                let stringData = Data(bytes: stringBytes)
                bodyString = String(data: stringData, encoding: String.Encoding.utf8)
                print("Response body string: \(bodyString!)")
            case .intArray:
                bodyIntArray = [Int]()
                let intArrayBytes = response[4...response.count - 1]
                for intArrayByte in intArrayBytes {
                    bodyIntArray!.append(Int(intArrayByte))
                }
                print("Response int array: \(bodyIntArray!)")
            default:
                break
            }
        }
        
        return (flag, sizeOfBody, bodyString, bodyInt, bodyIntArray)
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
        var bytes = getMessagePrefix(flag: GameServerFlag.login,
                                     sizeOfData: username.characters.count)
        bytes += DSConvertor.stringToBytes(string: username)
        let loginData = Data(bytes: bytes)

        switch client.connect(timeout: 10) {
        case .success:
            switch client.send(data: loginData) {
            case .success:
                guard let response = client.read(1024 * 10) else {
                    return false
                }
                
                // parse response
                let (flag, sizeOfBody, _, bodyInt, _) =
                    parseGameServerResponse(response: response, bodyType: .int)
                
                // check response
                if flag == GameServerFlag.login && sizeOfBody == 1 && bodyInt == 1 {  // success
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
    
    func findMatch() {
        if !connectToGameServer() {
            return
        }
        
        let bytes = getMessagePrefix(flag: GameServerFlag.findMatch,
                                     sizeOfData: 0)
        let findMatchData = Data(bytes: bytes)
        
        DispatchQueue(label: "Network Queue").async {
            switch self.client.send(data: findMatchData) {
            case .success:
                guard let response = self.client.read(1024 * 10) else {
                    return
                }
                
                DispatchQueue.main.async {
                    // parse response
                    let (flag, sizeOfBody, _, _, _) =
                        self.parseGameServerResponse(response: response, bodyType: .int)
                    
                    // check response
                    if flag == GameServerFlag.findMatch && sizeOfBody == 1 {  // successfully found a match
                        print("Successfully found a match!")
                        
                        let nc = NotificationCenter.default
                        nc.post(name: findMatchResultNotification,
                                object: nil,
                                userInfo: [InfoKey.result: FindMatchResult.success])
                    }

                }
            case .failure (let error):
                print("Send data failed, error: \(error)")
            }
        }
    }
    
    func sendReadyMessageToGameServer() {
        if !connectToGameServer() {
            return
        }

        let bytes = getMessagePrefix(flag: GameServerFlag.ready,
                                     sizeOfData: 0)
        let readyData = Data(bytes: bytes)

        DispatchQueue(label: "Network Queue").async {
            switch self.client.send(data: readyData) {
            case .success:
                guard let response = self.client.read(1024 * 10) else {
                    return
                }
                
                DispatchQueue.main.async {
                    // parse response
                    let (flag, sizeOfBody, _, _, _) =
                        self.parseGameServerResponse(response: response, bodyType: .int)
                    
                    // check response
                    if flag == GameServerFlag.nextPhase && sizeOfBody == 0 {
                        print("Ready confirmed!")
                        
                        let nc = NotificationCenter.default
                        nc.post(name: readyNotification,
                                object: nil,
                                userInfo: [InfoKey.result: ReadyResult.success])
                    }
                }
            case .failure (let error):
                print("Send data failed, error: \(error)")
            }
        }
    }
    
    func selectCat(catID: Int) {
        if !connectToGameServer() {
            return
        }
        
        var bytes = getMessagePrefix(flag: GameServerFlag.selectCat,
                                     sizeOfData: 1)
        bytes += DSConvertor.stringToBytes(string: "\(catID)")
        // bytes.append(UInt8(catID))
        let selectCatData = Data(bytes: bytes)

        DispatchQueue(label: "Network Queue").async {
            switch self.client.send(data: selectCatData) {
            case .success:
                guard let response = self.client.read(1024 * 10) else {
                    return
                }
                
                DispatchQueue.main.async {
                    // parse response
                    let (flag, sizeOfBody, _, _, _) =
                        self.parseGameServerResponse(response: response, bodyType: .int)
                    
                    // check response
                    if flag == GameServerFlag.selectCat && sizeOfBody == 1 {  // successfully selected a cat
                        print("Successfully select a cat!")
                        
                        let nc = NotificationCenter.default
                        nc.post(name: selectCatResultNotification,
                                object: nil,
                                userInfo: [InfoKey.result: SelectCatResult.success])
                    }
                }
            case .failure (let error):
                print("Send data failed, error: \(error)")
            }
        }
    }
    
    func sendReadyForCatSelectionMessageToGameServer() {
        if !connectToGameServer() {
            return
        }
        
        let bytes = getMessagePrefix(flag: GameServerFlag.ready,
                                     sizeOfData: 0)
        let readyData = Data(bytes: bytes)
        
        DispatchQueue(label: "Network Queue").async {
            switch self.client.send(data: readyData) {
            case .success:
                // ready
                guard let readyResponse = self.client.read(1024 * 10) else {
                    return
                }
                
                let (readyResponseFlag, readyResponseSize, _, _, _) =
                    self.parseGameServerResponse(response: readyResponse, bodyType: .int)
                
                guard let setupResponse = self.client.read(1024 * 10) else {
                    return
                }
                
                let opponentCatResponse = [UInt8]() + setupResponse[0...4]
                
                let (opponentCatResponseFlag, opponentCatSize, _, opponentCatID, _) =
                    self.parseGameServerResponse(response: opponentCatResponse, bodyType: .int)
                
                let randomAbilityResponse = [UInt8]() + setupResponse[5...9]
                
                let (randomAbilityFlag, randomAbilitySize, _, randomAbilityID, _) =
                    self.parseGameServerResponse(response: randomAbilityResponse, bodyType: .int)

                let chanceCardsResponse = [UInt8]() + setupResponse[10...15]
                
                let (chanceCardFlag, chanceCardSize, _, _, chanceCards) =
                    self.parseGameServerResponse(response: chanceCardsResponse, bodyType: .intArray)
                
                DispatchQueue.main.async {
                    // send notification
                    let nc = NotificationCenter.default
                    nc.post(name: setupGameNotification,
                            object: nil,
                            userInfo: [InfoKey.opponentCatID: opponentCatID!,
                                       InfoKey.randomAbilityID: randomAbilityID!,
                                       InfoKey.chanceCards: chanceCards!])
                }
            case .failure (let error):
                print("Send data failed, error: \(error)")
            }
        }
    }
        
}
