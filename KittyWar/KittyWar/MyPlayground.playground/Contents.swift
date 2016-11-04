//: Playground - noun: a place where people can play

import UIKit

let a: [String: Any] = ["status": "201"]

let b = a["status"]

if let c = a["status"] as? Int {
    print("Hello")
}