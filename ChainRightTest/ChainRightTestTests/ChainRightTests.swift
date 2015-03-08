//
//  ChainRightTests.swift
//  ChainRightTest
//
//  Created by Joseph Dixon on 3/8/15.
//  Copyright (c) 2015 Joseph Dixon. All rights reserved.
//

import UIKit
import XCTest

class ChainRightTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        let status = ChainRight.readUsernames()
        switch status {
        case let .Success(usernames):
            println("Deleting passwords for: \(usernames)")
            for username in usernames {
                ChainRight.deletePasswordForUsername(username)
            }
        case let .Failure(error):
            XCTAssert(false, "Unable to delete existing usernames in setup")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWritePassword() {
        let username = "joseph"
        let password = "freddy111"
        let status = ChainRight.writePassword(password, forUsername: username)
        
        switch status {
        case .Success:
            XCTAssert(true, "Dummy string")
        case let .Failure(error):
            XCTAssert(false, "Failed writing password: \(error)")
        }
    }
    
    func testRetrievePassword() {
        let username = "joseph"
        let password = "freddy222"
        ChainRight.writePassword(password, forUsername: username)
        
        let status = ChainRight.readPasswordForUsername(username)
        switch status {
        case let .Success(passwordFromKeychain):
            XCTAssertEqual(password, passwordFromKeychain, "Passwords do not match")
        case let .Failure(error):
            XCTAssert(false, "Failed reading password: \(error)")
        }
    }
    
    func testDeletePassword() {
        let username = "joseph"
        let password = "freddy333"
        ChainRight.writePassword(password, forUsername: username)
        
        let deleteStatus = ChainRight.deletePasswordForUsername(username)
        switch deleteStatus {
        case .Success:
            XCTAssert(true, "Dummy string")
        case let .Failure(error):
            XCTAssert(false, "Error deleting password: \(error)")
        }
        
        let readStatus = ChainRight.readUsernames()
        switch readStatus {
        case let .Success(usernames):
            XCTAssert(!contains(usernames, username), "Username still exists in keychain")
        case let .Failure(error):
            XCTAssert(false, "Failed reading list of users")
        }
    }

    func testRetrieveUsernames() {
        let usernames = [ ("joseph", "test111"), ("markD", "test222"), ("TJ", "test333") ]
        for (username, password) in usernames {
            ChainRight.writePassword(password, forUsername: username)
        }
        
        let status = ChainRight.readUsernames()
        switch status {
        case let .Success(usernamesFromKeychain):
            for (username, _) in usernames {
                XCTAssert(contains(usernamesFromKeychain, username), "Keychain is missing username: \(username)")
            }
        case let .Failure(error):
            XCTAssert(false, "Failed to read usernames: \(error)")
        }
    }
}
