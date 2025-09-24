import Foundation

struct InfoGraphicsResponse: Codable {
    let infoList: [InfoGraphicsListResponse]?
    let statusCode: String?
    let totalRecords: Int?

    enum CodingKeys: String, CodingKey {
        case infoList = "InfoList"
        case statusCode
        case totalRecords = "Total_Records"
    }
}

struct InfoGraphicsListResponse: Codable {
    let productName: String?
    let aboutInfographics: String?
    let keyTakeaways: String?
    let imageIcon: String?
    let title: String?
    let id: Int?
    let viewCount: Int?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case aboutInfographics = "about_infographics"
        case keyTakeaways = "key_takeaways"
        case imageIcon = "image_icon"
        case title
        case id
        case viewCount = "view_count"
    }
}
