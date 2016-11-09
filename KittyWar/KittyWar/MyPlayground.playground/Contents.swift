//: Playground - noun: a place where people can play

import Foundation

var token = "2s648hGSKF8aaLgTTl8/RQ=="
var byteArray = [UInt8]()
for char in token.utf8{
    byteArray += [char]
}
print(byteArray)
String(bytes: byteArray, encoding: .utf8)

let flag: UInt8 = 1

func intToByteArray(number: Int) -> [UInt8] {
    var result = [UInt8]()
    
    var _number: Int = number
    let mask8Bits = 0xFF
    
    for _ in (0 ..< MemoryLayout<Int>.size).reversed() {
        result.insert(UInt8(_number & mask8Bits), at: 0)
        _number >>= 8
    }
    
    return result
}

intToByteArray(number: 256)

