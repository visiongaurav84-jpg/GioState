import Foundation

// Root response model
struct IndicatorListResponse: Codable {
    let productList: [Product]?
    let statusCode: String?

    enum CodingKeys: String, CodingKey {
        case productList = "ProductList"
        case statusCode
    }
}

// Product model
struct Product: Codable {
    var productAggregateValue: String
    var productIcon: String
    var productName: String
    var unit: String?
    var productDescription: String
    var valueDate: String?
    var indicators: [String: String]?
    var frequency: [String: String]?

    enum CodingKeys: String, CodingKey {
        case productAggregateValue = "product_aggregate_value"
        case productIcon = "product_icon"
        case productName = "product_name"
        case unit = "Unit"
        case productDescription = "product_description"
        case valueDate = "value_date"
        case indicators = "Indicators"
        case frequency = "Frequency"
    }
}
