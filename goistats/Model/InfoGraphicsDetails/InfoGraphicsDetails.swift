//
//  InfoGraphicsDetails.swift
//  goistats
//
//  Created by getitrent on 07/08/25.
//


import Foundation

struct InfoGraphicsDetails: Codable {
    let statusCode: String?
    let total_Records: String?
    let infoList: [InfoList]?

    enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case total_Records = "Total_Records"
        case infoList = "InfoList"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try values.decodeIfPresent(String.self, forKey: .statusCode)
        total_Records = try values.decodeIfPresent(String.self, forKey: .total_Records)
        infoList = try values.decodeIfPresent([InfoList].self, forKey: .infoList)
    }
}

struct InfoList: Codable {
    let image_icon: String?
    let id: Int?
    let title: String?
    let about_infographics: String?
    let key_takeaways: String?
    let view_count: Int?
    let product_name: String?

    enum CodingKeys: String, CodingKey {
        case image_icon = "image_icon"
        case id = "id"
        case title = "title"
        case about_infographics = "about_infographics"
        case key_takeaways = "key_takeaways"
        case view_count = "view_count"
        case product_name = "product_name"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        image_icon = try values.decodeIfPresent(String.self, forKey: .image_icon)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        about_infographics = try values.decodeIfPresent(String.self, forKey: .about_infographics)
        key_takeaways = try values.decodeIfPresent(String.self, forKey: .key_takeaways)
        view_count = try values.decodeIfPresent(Int.self, forKey: .view_count)
        product_name = try values.decodeIfPresent(String.self, forKey: .product_name)
    }
}