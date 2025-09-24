//
//  Struct.swift
//  DelhiMetro
//
//  Created by Hardik on 08/04/21.
//

import Foundation
import UIKit

struct MyUserDefault {
    static let kAccessToken = "kAccessToken"
    static let kLoginUserDetails = "kLoginUserDetails"
    static let kIsUserLogin = "kIsUserLogin"
    static let kOfflineAttandance = "kOfflineAttandance"
    static let kOfflineReport = "kOfflineReport"
}

struct APILoginParameter {
    static let password = "password"
    static let rememberMe = "rememberMe"
    static let role = "role"
    static let username = "username"
}

struct APIChangePWDParameter {
    static let uid  = "uid"
    static let pwd  = "pwd"
    static let npwd = "npwd"
}

struct APIDocCentralParameter {
    static let pkcode  = "pkcode"
    static let stage  = "stage"
    static let doctype = "doctype"
}

struct APIPackageParameter {
    static let projid  = "projid"
    static let stage  = "stage"
}

struct APIVerifyOTPParameter {
    static let id = "id"
    static let otp = "otp"
}

struct APIReportDetailsParameter {
    static let sdt = "sdt"
    static let edt = "edt"
    static let ProjID = "ProjID"
    static let pkcode = "pkcode"
    static let CSGroup = "CSGroup"
    static let mnDt = "mnDt"
    static let mxDt = "mxDt"
    static let stn = "stn"
}

struct APIReportDetailsAwardParameter {
    static let mnDt = "mnDt"
    static let mxDt = "mxDt"
    static let package = "package"
    static let ProjID = "ProjID"
    static let countryKey = "CountryKey"
}

struct ApiInventorydParameter {
    static let ft = "ft"
    static let yr = "yr"
    static let st = "st"
    static let ih = "ih"
    static let scat = "scat"
    static let cat = "cat"
    static let itr = "itr"
    static let ivh = "ivh"
    static let stn = "stn"
    static let invtr2 = "invtr2"
    static let mw = "mw"
    static let str = "str"
    
    static let nsc = "nsc"
    static let pcat = "pcat"
    static let nfy = "nfy"
    static let nsfy = "nsfy"
    static let nihd = "nihd"
}
struct collectionlistDataModel {
    var name:String = String()
    
    var img:UIImage = UIImage()
    init(name:String,img:UIImage){
        
        self.name = name
        self.img = img
        
    }
}


