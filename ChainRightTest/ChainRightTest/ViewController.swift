//
//  ViewController.swift
//  ChainRightTest
//
//  Created by Joseph Dixon on 3/6/15.
//  Copyright (c) 2015 Joseph Dixon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        let listStatus = ChainRight.readUsernames()
        switch listStatus {
        case let .Success(usernames):
            println("Found users: \(usernames)")
        case let .Failure(error):
            println("Failure: \(error)")
        }
        
        
        let status = ChainRight.readPasswordForUsername("joseph")
        switch status {
        case let .Success(password):
            println("Found password: \(password)")
        case let .Failure(error):
            println("Failure: \(error)")
        }
    }

    @IBAction func didPressAddUserButton(sender: AnyObject) {
        let username = usernameField.text
        let password = passwordField.text
        let status = ChainRight.writePassword(password, forUsername: username)
        switch status {
        case .Success:
            println("User added successfully")
        case let .Failure(error):
            println("Failure: \(error)")
        }
    }

}

