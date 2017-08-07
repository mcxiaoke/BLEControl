//
//  MessageViewController.swift
//  BLEControl
//
//  Created by Xiaoke Zhang on 2017/8/3.
//  Copyright © 2017年 Balancing Rock. All rights reserved.
//

import UIKit
import QuartzCore
import CoreBluetooth

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

final class MessageViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MessageViewController.viewDidLoad")
        reloadView()
        
        mainTextView.layoutManager.allowsNonContiguousLayout = true
        mainTextView.text = ""
        messageField.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: .BluetoothDidStateChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onMessageSent(noti:)), name: .BluetoothDidSendString, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onMessageReceived(noti:)), name: .BluetoothDidReceiveString, object: nil)
        
        // to dismiss the keyboard if the user taps outside the textField while editing
        let tap = UITapGestureRecognizer(target: self, action: #selector(MessageViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func reloadView() {
        print("MessageViewController.reloadView")
        // in case we're the visible view again
        
        if serial.isReady {
            navItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navItem.title = "BLE Message"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navItem.title = "BLE Message"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }
    
    func textViewScrollToBottom() {
        let range = NSMakeRange(NSString(string: mainTextView.text).length - 1, 1)
        mainTextView.scrollRangeToVisible(range)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !serial.isReady {
            let alert = UIAlertController(title: "Not connected", message: "What am I supposed to send this to?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
            present(alert, animated: true, completion: nil)
            messageField.resignFirstResponder()
            return true
        }
        
        // send the message to the bluetooth device
        // but fist, add optionally a line break or carriage return (or both) to the message
        let pref = UserDefaults.standard.integer(forKey: MessageOptionKey)
        var msg = messageField.text!
        switch pref {
        case MessageOption.newline.rawValue:
            msg += "\n"
        case MessageOption.carriageReturn.rawValue:
            msg += "\r"
        case MessageOption.carriageReturnAndNewline.rawValue:
            msg += "\r\n"
        default:
            msg += ""
        }
        
        // send the message and clear the textfield
        serial.sendMessageToDevice(msg)
        messageField.text = ""
        return true
    }
    
    func handleMessage(message:String){
        // add the received text to the textView, optionally with a line break at the end
        var newText = mainTextView.text!
        newText += message
        let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
        if pref == ReceivedMessageOption.newline.rawValue { newText += "\n" }
        mainTextView.text = newText
        textViewScrollToBottom()
    }
    
    func onMessageSent(noti:Notification){
        if let message = noti.userInfo?[BluetoothDidSendStringMessageKey] as? String{
            handleMessage(message: message)
        }
    }
    
    func onMessageReceived(noti:Notification){
        if let message = noti.userInfo?[BluetoothDidReceiveStringMessagekey] as? String{
            handleMessage(message: message)
        }
    }
    
    func dismissKeyboard() {
        messageField.resignFirstResponder()
    }
    
    
    //MARK: IBActions
    
    @IBAction func barButtonPressed(_ sender: AnyObject) {
        print("MessageViewController.barButtonPressed \(serial.connectedPeripheral)")
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
    
}
