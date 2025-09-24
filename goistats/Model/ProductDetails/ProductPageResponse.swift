import Foundation

struct ProductPageResponse: Codable {
    let productList: [ProductList]?
    let statusCode: String?

    enum CodingKeys: String, CodingKey {
        case productList = "ProductList"
        case statusCode
    }
}

struct ProductList: Codable, Identifiable {
    var id: UUID = UUID() // Keep this non-optional if needed for SwiftUI/List
    let productName: String?
    let productAggregateValue: String?
    let valueDate: String?
    let productDescription: String?
    let frequency: [String: String]?
    let indicators: [String: String]?
    let data: ProductData?
    let unit: String?
    let metaData: ProductMetaData?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productAggregateValue = "product_aggregate_value"
        case valueDate = "value_date"
        case productDescription = "product_description"
        case frequency = "Frequency"
        case indicators = "Indicators"
        case data = "Data"
        case unit = "Unit"
        case metaData = "MetaData"
    }
}

struct ProductData: Codable {
    let response: [[String: String]]?
    let errorCode: String?

    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case errorCode = "Error_Code"
    }
}

struct ProductMetaData: Codable {
    let description: String?
    let category: String?
    let geography: String?
    let frequency: String?
    let timePeriod: String?
    let dataSource: String?
    let lastUpdatedDate: String?
    let futureRelease: String?
    let basePeriod: String?
    let keyStatistics: String?
    let remarks: String?
    let nms: String?
    let eslink: String?

    enum CodingKeys: String, CodingKey {
        case description
        case category
        case geography
        case frequency
        case timePeriod = "time_period"
        case dataSource = "data_source"
        case lastUpdatedDate = "last_updated_date"
        case futureRelease = "future_release"
        case basePeriod = "base_period"
        case keyStatistics = "key_statistics"
        case remarks
        case nms
        case eslink
    }
}
