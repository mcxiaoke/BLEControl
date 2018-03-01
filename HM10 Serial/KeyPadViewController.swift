//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import AudioToolbox


final class KeyPadViewController: UIViewController {

//MARK: IBOutlets
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var stackView:UIStackView!
    var timer:SwiftTimer?


//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("KeyPadViewController.viewDidLoad")
        reloadView()
        setupButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(KeyPadViewController.reloadView), name: .BluetoothDidStateChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        timer = nil
    }

    deinit {
        timer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadView() {
        print("KeyPadViewController.reloadView")
        if serial.isReady {
            navItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navItem.title = "BLE Control"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navItem.title = "BLE Control"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }
    
    func setupButtons(){
        print("setupButtons")
        view.subviews.forEach { (v) in
            if let s = v as? UIStackView{
               s.subviews.forEach({ (v2) in
                if let s2 = v2 as? UIStackView{
                    s2.subviews.forEach({ (v3) in
                        if let b = v3 as? UIButton{
                            print("addTarget for UIButton: \(b.tag)")
                            b.addTarget(self, action: #selector(buttonTouchDown(_:)),
                                        for: .touchDown)
                            b.addTarget(self, action: #selector(buttonTouchUp(_:)),
                                        for: [.touchUpInside, .touchUpOutside,.touchDragExit])
                        }
                    })
                }
               })
            }
        }
    }
    
    func getSendDelay() -> Int{
        let pref = UserDefaults.standard.integer(forKey: HoldSendDelayOptionKey)
        let delay:Int
        switch pref {
        case HoldSendDelayOption.t200ms.rawValue:
            delay = 200
        case HoldSendDelayOption.t500ms.rawValue:
            delay = 500
        case HoldSendDelayOption.t1000ms.rawValue:
            delay = 1000
        case HoldSendDelayOption.t2000ms.rawValue:
            delay = 2000
        default:
            delay = 500
        }
        return delay
    }
    
    //MARK: IBActions
    
    @IBAction func buttonTouchDown(_ sender: UIView){
//        print("buttonTouchDown: \(sender.tag)")
//        if false {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            let tag = sender.tag
            timer = SwiftTimer(interval: .milliseconds(getSendDelay()),repeats: true) { _ in
                //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                serial.sendMessageToDevice("\(tag)")
            }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            timer?.start()
            timer?.fire()
        }
    }
    
    @IBAction func buttonTouchUp(_ sender: UIView){
//        print("buttonTouchUp: \(sender.tag)")
        timer = nil
    }
    
    @IBAction func barButtonPressed(_ sender: AnyObject) {
        print("KeyPadViewController.barButtonPressed \(String(describing: serial.connectedPeripheral))")
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
    

}
