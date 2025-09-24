//
//  UserDefaults.swift
//  USHA
//
//  Created by Gaurav Awasthi on 04/01/21.
//  Copyright © 2021 Devstree. All rights reserved.
//

import Foundation

//MARK:-
struct UDKeys {
    static let isUserLogin      =   "isUserLogin"
    static let TokenType        =   "token_type"
    static let AccessToken      =   "accessToken"
    static let RefreshToken   =    "refreshToken"
    
    static let UserID           =   "id"
    static let UserType         =   "UserType"
    static let UserName         =   "UserName"
    static let ProfileName         =   "ProfileName"
    static let EmailOrMob       =   "EmailOrMob"
    static let Password         =   "Password"
    static let Remindar         =   "Remindar"
    static let Ptus             =   "PTUS"
    static let Email            =   "Email"
    static let Zone            =   "Zone"
    static let Phone            =   "Phone"
    static let ImageName        =   "ImageName"
    static let Roll        =   "roll"
    static let EmpId         =   "employeeId"
    static let StudentId         =   "StudentId"
    
    
    static let UEmail           =   "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    static let UPhone           =   "phn"
    static let Uid              =   "uid"
    static let UName            =   "nam"
    static let UImage           =   "img"
    
    static let ForgotPassword   =   "ForgotPassword"
    static let isSkipLoginCheck = "Yes"
    
    static let lat   =   "lat"
    static let long   =   "long"
    static let address   =   "address"
    static let currentView = "1"
    
}

struct Constant {
    
    static var isSkipLoginCheck : String{
        set{
            USERDEFAULTS.set(newValue, forKey: UDKeys.isSkipLoginCheck)
        }
        get{
            return USERDEFAULTS.value(forKey: UDKeys.isSkipLoginCheck) as? String ?? ""
        }
    }
    
    static var currentView : String{
        set{
            USERDEFAULTS.set(newValue, forKey: UDKeys.currentView)
        }
        get{
            return USERDEFAULTS.value(forKey: UDKeys.currentView) as? String ?? ""
        }
    }
    
    
    static var isUserLogin : Bool{
        set{
            USERDEFAULTS.set(newValue, forKey: UDKeys.isUserLogin)
        }
        get{
            return USERDEFAULTS.value(forKey: UDKeys.isUserLogin) as? Bool ?? false
        }
    }
    
    
    static var TokenType : String{
        set{
            USERDEFAULTS.set(newValue, forKey: UDKeys.TokenType)
        }
        get{
            return USERDEFAULTS.value(forKey: UDKeys.TokenType) as? String ?? ""
        }
    }
    
    static var AccessToken : String{
        set{
            USERDEFAULTS.set(newValue, forKey: UDKeys.AccessToken)
        }
        get{
            return USERDEFAULTS.value(forKey: UDKeys.AccessToken) as? String ?? ""
        }
    }
    
    static var RefreshToken : String{
        set{
            USERDEFAULTS.set(newValue, forKey: UDKeys.RefreshToken)
        }
        get{
            return USERDEFAULTS.value(forKey: UDKeys.RefreshToken) as? String ?? ""
        }
    }
    
    static var UserID: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.UserID) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.UserID)
        }
    }
    
    static var StudentID: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.StudentId) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.StudentId)
        }
    }
    
    static var UID: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.Uid) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.Uid)
        }
    }
    
    static var UserType: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.UserType) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.UserType)
        }
    }
    
    static var UserName: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.UserName) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.UserName)
        }
    }
    
    
    static var ProfileName: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.ProfileName) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.ProfileName)
        }
    }
    
    static var EmpId: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.EmpId) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.EmpId)
        }
    }
    
    
    static var EmailOrMob: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.EmailOrMob) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.EmailOrMob)
        }
    }
    
    static var Password: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.Password) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.Password)
        }
    }
    
    static var Remindar: Bool {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.Remindar) as? Bool ?? false
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.Remindar)
        }
    }
    
    static var Ptus: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.Ptus) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.Ptus)
        }
    }
    
    static var Email: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.Email) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.Email)
        }
    }
    
    static var Zone: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.Zone) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.Zone)
        }
    }
    
    static var Phone: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.Phone) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.Phone)
        }
    }
    
    static var ImageName: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.ImageName) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.ImageName)
        }
    }
    
    static var Roll: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.Roll) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.Roll)
        }
    }
    
    static var lat: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.lat) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.lat)
        }
    }
    
    
    static var long: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.long) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.long)
        }
    }
    
    static var address: String {
        get {
            return USERDEFAULTS.value(forKey: UDKeys.address) as? String ?? ""
        }
        set {
            USERDEFAULTS.set(newValue, forKey: UDKeys.address)
        }
    }
    
}
