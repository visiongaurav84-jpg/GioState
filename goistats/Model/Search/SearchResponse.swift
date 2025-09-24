//
//  SearchResponse.swift
//  goistats
//
//  Created by getitrent on 06/08/25.
//


import Foundation

struct SearchResponse: Codable {
    let errorCode: String?
    let response: [SearchSubResponse]?
    let statusCode: String?

    enum CodingKeys: String, CodingKey {
        case errorCode = "Error_Code"
        case response
        case statusCode
    }
}

struct SearchSubResponse: Codable {
    let productName: String?
    let keyword: String?
    let indicatorKey1: String?
    let indicatorVal1: String?
    let indicatorKey2: String?
    let indicatorVal2: String?
    let indicatorKey3: String?
    let indicatorVal3: String?
    let indicators: [String: String]?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case keyword
        case indicatorKey1 = "Indicator_Key1"
        case indicatorVal1 = "Indicator_Val1"
        case indicatorKey2 = "Indicator_Key2"
        case indicatorVal2 = "Indicator_Val2"
        case indicatorKey3 = "Indicator_Key3"
        case indicatorVal3 = "Indicator_Val3"
        case indicators = "Indicators"
    }
}
