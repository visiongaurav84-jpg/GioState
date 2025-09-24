//
//  Constant.swift
//  GOISTATS
//
//  Copyright © 2020 Devstree. All rights reserved.
//

import UIKit

//MARK: -
let APPNAME                 = "GoIStats"
let USERDEFAULTS            = UserDefaults.standard
let MainStoryboard          = UIStoryboard(name: "Main", bundle: nil)
let SideMenuStoryboard          = UIStoryboard(name: "SideMenu", bundle: nil)
let SideMenuWidth : CGFloat  = UIScreen.main.bounds.width-80


//MARK: - App Theme Colors
struct AppColor {
    static let PrimaryColor             : UIColor = #colorLiteral(red: 0.5594990253, green: 0, blue: 0.1685554683, alpha: 1)
    static let SecondryColor            : UIColor = #colorLiteral(red: 0.9825310111, green: 0.737876296, blue: 0.03488355502, alpha: 1)
    static let LightPrimaryColor        : UIColor = #colorLiteral(red: 0.9605136514, green: 0.8102169633, blue: 0.812975347, alpha: 1)
    static let BtnBackgroundColor       : UIColor = #colorLiteral(red: 0.9128693938, green: 0.4943870306, blue: 0.2279749215, alpha: 1)
    static let ShadowColor              : UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    static let LinkButtonColor          : UIColor = #colorLiteral(red: 0.07947992533, green: 0, blue: 0.8339485526, alpha: 1)
    static let TextFieldBorderColor     : UIColor = #colorLiteral(red: 0.6282263398, green: 0.6234036088, blue: 0.6233764887, alpha: 1)
    static let BorderColorBtn           : UIColor = #colorLiteral(red: 0.9763854146, green: 0.9765252471, blue: 0.9763547778, alpha: 1)
}

//MARK: - App Theme Fonts
struct AppFont {
    static let Regular  =   "NotoSans-Regular"
    static let Light    =   "NotoSans-Light"
    static let Bold     =   "NotoSans-Bold"
    static let Rechard  =   "NotoSans-Regular"
}

//MARK: - Static Response Messages
struct AppMessages{
    static let SomethingWrong = "Something went wrong. Please try again later."
    static let InternetError = "Please check internet connection, and try again."
    static let otpError = "Please enter the correct OTP."
}

//MARK: - API Base Url
let ApiHostURL       =   "https://goistatsapp.mospi.gov.in/GOISTAT/"
//let ApiHostURL       =   "http://10.24.89.9:8081/GOISTAT/"

let PdfBaseUrl       =   "https://goistatsapp.mospi.gov.in/"

//MARK: - API Request URLs
struct ApiUrl {
    static let mospiWebsiteURL  =  "https://www.mospi.gov.in/"
    
    //API End Points
    static let authHandshakeAPI  =  ApiHostURL + "AuthHandShake"
    static let topProductsAPI  =  ApiHostURL + "TopProducts"
    static let infographicsAPI  =  ApiHostURL + "InfoListing"
    static let productsListAPI  =  ApiHostURL + "IndicatorListing"
    static let productDetailsAPI  =  ApiHostURL + "ProductsPage"
    static let searchAPI  =  ApiHostURL + "SearchQuery"
    static let infoGraphicDetailsAPI  =  ApiHostURL + "InfoListingId"
    static let updateViewAPI  =  ApiHostURL + "infoUpdate"
    static let aboutUsAPI  =  ApiHostURL + "aboutUs"
    static let reportsListingAPI  =  ApiHostURL + "ReportsListing"
    static let whatsNewAPI  =  ApiHostURL + "PressListing"
    static let advanceReleaseAPI  =  ApiHostURL + "ReleaseCalendar"
    static let userGuideURL = PdfBaseUrl + "uploads/reports_publications/user_guide_new.pdf"
    static let contactUsAPI  =  ApiHostURL + "appContact"
    static let notificationAPI  =  ApiHostURL + "notificationDetails"
    static let submitFeedbackAPI  =  ApiHostURL + "SubmitFeedBack"
    
    
    
    
    
    
    
    
    
    
    
}

//MARK: - Social media links.
struct SocialLinks {
    static let facebook = "https://www.facebook.com/GoIStats/"
    static let instagram = "https://www.instagram.com/goistats"
    static let youtube = "https://www.youtube.com/@GoIStats"
    static let twitter = "https://x.com/goistats"
    static let linkedin = "https://in.linkedin.com/company/ministry-of-statistics-programme-implementation"
}

//MARK: - API Response Codes.
struct StatusType {
    static let Success          =   200
    static let Ok               =   204
    static let TokenExpired     =   401
    static let NotFound         =   404
    static let InternalError    =   500
}

//MARK: - PAgination Count.
let PaginationCount = 10

//UN :  P_ecom
//PW : P@moc#432
