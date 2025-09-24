//
//  ContactUsResponse.swift
//  goistats
//
//  Created by getitrent on 11/08/25.
//


import Foundation

struct ContactUsResponse: Codable {
    var appDetails: AppDetails?
    var urls: [Urls]?
    var supportQueries: [SupportQueries]?
    var statusCode: String?
    
    enum CodingKeys: String, CodingKey {
        case appDetails = "app_details"
        case urls
        case supportQueries = "support_queries"
        case statusCode
    }
}

struct AppDetails: Codable {
    var appName: String?
    var appDescription: String?
    var webManager: String?
    var dataSupport: String?
    
    enum CodingKeys: String, CodingKey {
        case appName = "app_name"
        case appDescription = "app_description"
        case webManager = "web_manager"
        case dataSupport = "data_support"
    }
}

struct Urls: Codable {
    var urlKey: String?
    var urlVal: String?
    
    enum CodingKeys: String, CodingKey {
        case urlKey = "URL_KEY"
        case urlVal = "URL_VAL"
    }
}

struct SupportQueries: Codable {
    var subject: String?
    var division: String?
    var contactPerson: String?
    var contactEmail: String?
    var contactPhone: String?
    
    enum CodingKeys: String, CodingKey {
        case subject
        case division
        case contactPerson = "contact_person"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
    }
}