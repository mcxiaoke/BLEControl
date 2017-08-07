//
//  Const.swift
//  BLEControl
//
//  Created by Xiaoke Zhang on 2017/8/7.
//  Copyright © 2017年 Balancing Rock. All rights reserved.
//

import UIKit

let BluetoothDidSendStringMessageKey = "BluetoothDidSendStringMessageKey"
let BluetoothDidReceiveStringMessagekey = "BluetoothDidReceiveStringMessagekey"


let MessageOptionKey = "MessageOption"
let ReceivedMessageOptionKey = "ReceivedMessageOption"
//let WriteWithResponseKey = "WriteWithResponse" No longer neccessary v1.1.2
let HoldSendDelayOptionKey = "HoldSendDelayOption"

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
    newline,
    carriageReturn,
    carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
    newline
}

enum HoldSendDelayOption: Int {
    case t200ms,
    t500ms,
    t1000ms,
    t2000ms
}

extension Notification.Name{
    static let BluetoothDidStateChange = Notification.Name("EventBluetoothDidStateChange")
    static let BluetoothDidSendString = Notification.Name("kEventBluetoothDidSendString")
    static let BluetoothDidReceiveString = Notification.Name("EventBluetoothDidReceiveString")
}


