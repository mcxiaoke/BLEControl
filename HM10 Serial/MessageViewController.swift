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

class MessageItem: Any {
    let raw:Data
    let text:String
    let hex:String
    
    init(_ data:Data) {
        raw = data
        text = data.utf8String()
        hex = data.hexString()
    }
}

final class MessageViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    
    var messages: [MessageItem] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MessageViewController.viewDidLoad")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        
        reloadView()
        
        messageField.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: .BluetoothDidStateChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onMessageSent(noti:)), name: .BluetoothDidSendData, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onMessageReceived(noti:)), name: .BluetoothDidReceiveData, object: nil)
        
        // to dismiss the keyboard if the user taps outside the textField while editing
        let tap = UITapGestureRecognizer(target: self, action: #selector(MessageViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func reloadView() {
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
    
    func scrollToBottom() {
        let lastItem = IndexPath(item: messages.count - 1, section: 0)
        tableView.scrollToRow(at: lastItem, at: .bottom, animated: true)
        
//        let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height)
//        self.tableView.setContentOffset(scrollPoint, animated: true)
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
        handleMessage(msg.data(using: String.Encoding.utf8)!)
        serial.sendMessageToDevice(msg)
        messageField.text = ""
        return true
    }
    
    func handleMessage(_ data:Data){
        messages.append(MessageItem(data))
        tableView.reloadData()
        scrollToBottom()
    }
    
    @objc func onMessageSent(noti:Notification){
        if let data = noti.userInfo?[BluetoothDidSendDataMessageKey] as? Data{
            handleMessage(data)
        }
    }
    
    @objc func onMessageReceived(noti:Notification){
        if let data = noti.userInfo?[BluetoothDidReceiveDataMessageKey] as? Data{
            handleMessage(data)
        }
    }
    
    @objc func dismissKeyboard() {
        messageField.resignFirstResponder()
    }
    
    
    //MARK: IBActions
    
    @IBAction func barButtonPressed(_ sender: AnyObject) {
        print("MessageViewController.barButtonPressed \(String(describing: serial.connectedPeripheral))")
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
    
}

extension MessageViewController: UITableViewDelegate {

}

extension MessageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell")!
        let textString = cell.viewWithTag(1) as! UILabel
        let textHex = cell.viewWithTag(2) as! UILabel
        let item = messages[indexPath.row]
        textString.text = item.text
        textHex.text = item.hex
        return cell
    }
    
    

}
