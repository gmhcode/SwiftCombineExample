//
//  ViewController.swift
//  SwiftCombine
//
//  Created by Greg Hughes on 10/23/19.
//  Copyright © 2019 Greg Hughes. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var allowMessagesSwitch: UISwitch!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    ///turns canSendMessages into a publisher
    @Published var canSendMessages : Bool = false
    
    private var  switchSubscriber : AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProcessingChain()
       
        
        
    }
    func setupProcessingChain(){
        //this basically adds an observer to canSendMessages for the sendButton.isEnabled property. when canSendMessages turns true, sendButton.isEnabled will also turn true.
        
        switchSubscriber = $canSendMessages.receive(on: DispatchQueue.main, options: nil).assign(to: \.isEnabled, on: sendButton)
        
        ///puts an observer on messageLabel.text so now whatever the messageSubscriber receives from the messagePublisher, it will change messageLabel.text
        let messageSubscriber = Subscribers.Assign(object: messageLabel, keyPath: \.text)
        
        /// this sends out messages to its subscribers, the message that it sends out is the notification object (which turns into message.content)
        let messagePublisher = NotificationCenter.Publisher(center: .default, name: .newMessage)
            
            ///this turns the notification into a string which we need because messageLabel.text is a string
            .map {notification -> String? in
                return (notification.object as? Message)?.content ?? ""
        }
        
        //this makes it so whatever messagePublisher sends out, messageSubscriber will receive it
        messagePublisher.subscribe(messageSubscriber)
        
    }
    

    @IBAction func didSwitch(_ sender: UISwitch) {
        canSendMessages = sender.isOn
    }
    @IBAction func sendMessage(_ sender: Any) {
        
        
        let message = Message(content: "the current Time is \(Date())", Author: "Me")
        
        //MARK:THIS IS THE OBJECT IN NOTIFICATION.OBJECT
        NotificationCenter.default.post(name: .newMessage, object: message)
    }
    
}

enum WeatherError: Error {
    case thingsJustHappen
}

extension Notification.Name{
    static let newMessage = Notification.Name("New Message")
}

struct Message {
    let content : String
    let Author : String
}
