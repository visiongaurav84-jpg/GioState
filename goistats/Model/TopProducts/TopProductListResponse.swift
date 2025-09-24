import Foundation

// MARK: - Root Response
struct ProductListResponse: Codable {
    let productList: [TopProductListResponse]
    let statusCode: String

    enum CodingKeys: String, CodingKey {
        case productList = "ProductList"
        case statusCode
    }
}

// MARK: - Top Product
struct TopProductListResponse: Codable {
    let productName: String?
    let productRank: Int?
    let productAggregateValue: String?
    let productIcon: String?  // Optional: not present in your current JSON
    let valueDate: String?
    let productDescription: String?
    let data: DataRequest?
    let indicators: [String: String]?
    let indicatorList: [String: String]?
    let frequency: [String: String]?

    let metaData: MetaData?
    let unit: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productRank = "product_rank"
        case productAggregateValue = "product_aggregate_value"
        case productIcon = "product_icon"
        case valueDate = "value_date"
        case productDescription = "product_description"
        case data = "Data"
        case indicators = "Indicators"
        case frequency = "Frequency"
        case indicatorList = "IndicatorList"
        case metaData = "MetaData"
        case unit = "Unit"
    }
}

// MARK: - Data Section
struct DataRequest: Codable {
    let response: [[String: String]]?
    let errorCode: String?

    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case errorCode = "Error_Code"
    }
}

// MARK: - Metadata
struct MetaData: Codable {
    let description: String?
     let category: String?
     let dataSource: String?
     let eslink: String?
     let basePeriod: String?
     let geography: String?
     let lastUpdatedDate: String?
     let nms: String?
     let futureRelease: String?
     let keyStatistics: String?
     let remarks: String?
     let frequency: String?
     let timePeriod: String?

    enum CodingKeys: String, CodingKey {
        case description
        case category
        case dataSource = "data_source"
        case eslink
        case basePeriod = "base_period"
        case geography
        case lastUpdatedDate = "last_updated_date"
        case nms
        case futureRelease = "future_release"
        case keyStatistics = "key_statistics"
        case remarks
        case frequency
        case timePeriod = "time_period"
    }
}
