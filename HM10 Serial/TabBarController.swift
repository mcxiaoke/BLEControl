//
//  TabController.swift
//  BLEControl
//
//  Created by Xiaoke Zhang on 2017/8/3.
//  Copyright © 2017年 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import AudioToolbox

final class TabBarController: UITabBarController, BluetoothSerialDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TabBarController.viewDidLoad()")
        // init serial
        serial = BluetoothSerial(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Tab.viewWillAppear")
//        serial.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Tab.viewWillDisappear")
//        serial.delegate = nil
    }
    
    
    //MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String) {
        print("Tab.serialDidReceiveString")
    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        print("Tab.serialIsReady")
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Tab.serialDidDisconnect")
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //reloadView()
        //dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        print("Tab.serialDidChangeState")
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
