//
//  TabController.swift
//  BLEControl
//
//  Created by Xiaoke Zhang on 2017/8/3.
//  Copyright © 2017年 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth

final class TabBarController: UITabBarController, BluetoothSerialDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TabBarController.viewDidLoad()")
        // init serial
        serial = BluetoothSerial(delegate: self)
    }
    
    
    //MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String) {
        // add the received text to the textView, optionally with a line break at the end
        //mainTextView.text! += message
        //let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
        //if pref == ReceivedMessageOption.newline.rawValue { mainTextView.text! += "\n" }
        //textViewScrollToBottom()
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //reloadView()
        //dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        //reloadView()
        if serial.centralManager.state != .poweredOn {
            //dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
}
