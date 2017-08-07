//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth


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
        NotificationCenter.default.addObserver(self, selector: #selector(KeyPadViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
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
    
    func reloadView() {
        print("KeyPadViewController state=\(serial.centralManager.state.rawValue)")
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
    
    //MARK: IBActions
    
    @IBAction func buttonTouchDown(_ sender: UIView){
//        print("buttonTouchDown: \(sender.tag)")
        if false {
//        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            let tag = sender.tag
            timer = SwiftTimer(interval: .milliseconds(500),repeats: true) { _ in
                serial.sendMessageToDevice("\(tag)")
            }
            timer?.start()
            timer?.fire()
        }
    }
    
    @IBAction func buttonTouchUp(_ sender: UIView){
//        print("buttonTouchUp: \(sender.tag)")
        timer = nil
    }
    
    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
    

}
