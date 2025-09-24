//
//  NotificationResponse.swift
//  goistats
//
//  Created by getitrent on 12/08/25.
//


import Foundation

struct NotificationResponse: Codable {
    var data: [NotificationItem]?
    var statusCode: String?
    var errorCode: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case statusCode
        case errorCode = "Error_Code"
    }
}

struct NotificationItem: Codable {
    var id: Int?
    var batchId: String?
    var messageText: String?
    var dateCreated: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case batchId = "batch_id"
        case messageText = "message_text"
        case dateCreated = "date_created"
    }
}
