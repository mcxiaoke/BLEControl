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

extension Notification.Name{
    static let BluetoothDidStateChange = Notification.Name("EventBluetoothDidStateChange")
    static let BluetoothDidSendString = Notification.Name("kEventBluetoothDidSendString")
    static let BluetoothDidReceiveString = Notification.Name("EventBluetoothDidReceiveString")
}


