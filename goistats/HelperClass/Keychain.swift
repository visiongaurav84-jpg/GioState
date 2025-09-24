//
//  Keychain.swift
//  GOISTATS
//
//  Created by PECS IOS on 18/09/23.
//  Copyright © 2023 Gaurav. All rights reserved.
//

import Foundation
import Security

// Constant Identifiers
let userAccount = "AuthenticatedUser"
let accessGroup = "SecuritySerivice"


/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */
let deviceIdKey = "deviceId"
let ivKey = "ivKey"
let rsaKey = "rsaKey"


// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class KeychainService: NSObject {
    
    /**
     * Exposed methods to perform save and load queries.
     */
    
    public class func saveDeviceId(deviceId: NSString) {
        self.save(service: deviceIdKey as NSString, data: deviceId)
    }
    
    public class func getDeviceId() -> NSString? {
        return self.load(service: deviceIdKey as NSString)
    }
    
    
    public class func saveIV(IV: NSString) {
        self.save(service: ivKey as NSString, data: IV)
    }
    
    public class func getIV() -> NSString? {
        return self.load(service: ivKey as NSString)
    }
    
    public class func saveRSA(rsa: NSString) {
        self.save(service: rsaKey as NSString, data: rsa)
    }
    
    public class func getRSA() -> NSString? {
        return self.load(service: rsaKey as NSString)
    }
    
    
    
    /**
     * Delete keychain access data
     */
    public class func deleteDeviceId() {
        self.delete(service: deviceIdKey as NSString)
    }
    
    public class func deleteIV() {
        self.delete(service: ivKey as NSString)
    }
    
    public class func deleteRSA() {
        self.delete(service: rsaKey as NSString)
    }
    
    private class func delete(service: NSString) {
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        
        SecItemDelete(keychainQuery as CFDictionary)
    }
    
    
    /**
     * Internal methods for querying the keychain.
     */
    
    private class func save(service: NSString, data: NSString) {
        let dataFromString: NSData = data.data(using: NSUTF8StringEncoding, allowLossyConversion: false)! as NSData
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue!, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: NSUTF8StringEncoding)
            }
        } else {
           // print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}
