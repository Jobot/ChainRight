//
//  ChainRight.swift
//  ChainRightTest
//
//  Created by Joseph Dixon on 3/6/15.
//  Copyright (c) 2015 Joseph Dixon. All rights reserved.
//

import Foundation
import Security

enum ChainRight {
    
    enum WritePasswordStatus {
        case Success
        case Failure(error: String)
    }
    
    enum ReadPasswordStatus {
        case Success(String)
        case Failure(error: String)
    }
    
    enum DeletePasswordStatus {
        case Success
        case Failure(error: String)
    }
    
    enum ReadUsersStatus {
        case Success([String])
        case Failure(error: String)
    }
    
    enum Accessibility {
        case WhenUnlocked
        case AfterFirstUnlock
        case Always
        case WhenUnlockedThisDeviceOnly
        case AfterFirstUnlockThisDeviceOnly
        case AlwaysThisDeviceOnly
        
        private func rawValue () -> CFStringRef {
            switch self {
            case .WhenUnlocked:
                return kSecAttrAccessibleWhenUnlocked
            case .AfterFirstUnlock:
                return kSecAttrAccessibleAfterFirstUnlock
            case .Always:
                return kSecAttrAccessibleAlways
            case .WhenUnlockedThisDeviceOnly:
                return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            case .AfterFirstUnlockThisDeviceOnly:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .AlwaysThisDeviceOnly:
                return kSecAttrAccessibleAlwaysThisDeviceOnly
            }
        }
    }
    
    static func writePassword(password: String, forUsername username: String, accessibility: Accessibility = .WhenUnlocked) -> WritePasswordStatus {
        let maybeData = password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if maybeData == nil {
            return WritePasswordStatus.Failure(error: "Unable to create data from text")
        }
        
        let data = maybeData!
        let keychainQuery: [String:AnyObject] = [
            kSecClass : kSecClassInternetPassword,
            kSecAttrAccount : username,
            kSecAttrAccessible : accessibility.rawValue(),
            kSecValueData : data
        ]
        
        let status = SecItemAdd(keychainQuery, nil)
        switch status {
        case noErr:
            return WritePasswordStatus.Success
        default:
            return WritePasswordStatus.Failure(error: "Unable to write data to keychain")
        }
    }
    
    static func readPasswordForUsername(username: String) -> ReadPasswordStatus {
        let keychainQuery: [String:AnyObject] = [
            kSecClass : kSecClassInternetPassword,
            kSecAttrAccount : username,
            kSecReturnData : kCFBooleanTrue
        ]
        
        var password: String? = nil
        var rawDataRef: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(keychainQuery, &rawDataRef)
        if status == noErr {
            if let data = rawDataRef?.takeRetainedValue() as? NSData {
                if let password = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return ReadPasswordStatus.Success(password)
                }
            }
        }
        
        return ReadPasswordStatus.Failure(error: "Unable to read password data")
    }
    
    static func deletePasswordForUsername(username: String) -> DeletePasswordStatus {
        let keychainQuery: [String:AnyObject] = [
            kSecClass : kSecClassInternetPassword,
            kSecAttrAccount : username
        ]
        
        let status = SecItemDelete(keychainQuery)
        switch status {
        case noErr:
            return DeletePasswordStatus.Success
        case errSecParam:
            return DeletePasswordStatus.Failure(error: "Parameter malfunction")
        case errSecItemNotFound:
            return DeletePasswordStatus.Failure(error: "Unable to find the specified username")
        default:
            return DeletePasswordStatus.Failure(error: "Unable to delete password")
        }
    }
    
    static func readUsernames() -> ReadUsersStatus {
        let keychainQuery: [String:AnyObject] = [
            kSecClass : kSecClassInternetPassword,
            kSecMatchLimit : kSecMatchLimitAll,
            kSecReturnAttributes : kCFBooleanTrue
        ]
        
        var rawDataRef: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(keychainQuery, &rawDataRef)
        switch status {
        case noErr:
            if let records = rawDataRef?.takeRetainedValue() as? [[String:AnyObject]] {
                var usernames: [String] = []
                for record in records {
                    if let username = record["acct"] as? String {
                        usernames.append(username)
                    }
                }
                return ReadUsersStatus.Success(usernames)
            } else {
                return ReadUsersStatus.Failure(error: "Encountered unexpected data while reading usernames")
            }
        case errSecItemNotFound:
            return ReadUsersStatus.Success([])
        default:
            return ReadUsersStatus.Failure(error: "Unable to retrieve usernames")
        }
    }
}
