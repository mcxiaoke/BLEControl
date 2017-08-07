//
//  Extensions.swift
//  BLEControl
//
//  Created by Xiaoke Zhang on 2017/8/7.
//  Copyright © 2017年 Balancing Rock. All rights reserved.
//


extension Data {
    func hexString() -> String {
        return map { String(format: "%02hhx ", $0) }.joined()
    }
    
    func utf8String() -> String {
        return String(data: self, encoding: String.Encoding.utf8)!
    }
}
