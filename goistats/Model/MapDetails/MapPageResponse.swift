import Foundation

// MARK: - MapPageResponse
struct MapPageResponse: Codable {
    let productList: [MapList]?
    let statusCode: String?
    
    enum CodingKeys: String, CodingKey {
        case productList = "ProductList"
        case statusCode
    }
}

// MARK: - MapList
struct MapList: Codable {
    let productName: String?
    let productAggregateValue: String?
    let valueDate: String?
    let productDescription: String?
    let year: [String]?
    let sector: [String: String]?
    let imputation: [String: String]?
    let indicators: [String: String]?
    let data: MapData?
    let unit: String?
    let metaData: MapMetaData?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productAggregateValue = "product_aggregate_value"
        case valueDate = "value_date"
        case productDescription = "product_description"
        case year = "Year"
        case sector = "Sector"
        case imputation = "Imputation"
        case indicators = "Indicators"
        case data = "Data"
        case unit = "Unit"
        case metaData = "MetaData"
    }
}

// MARK: - MapData
struct MapData: Codable {
    let response: [ResponseItem]?
    let errorCode: String?
    
    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case errorCode = "Error_Code"
    }
}

// MARK: - ResponseItem
struct ResponseItem: Codable {
    let year: String?
    let state: String?
    let indicator: String?
    let sector: String?
    let imputationType: String?
    let unit: String?
    let indicator1Val: String?
    
    enum CodingKeys: String, CodingKey {
        case year
        case state
        case indicator
        case sector
        case imputationType = "imputation_type"
        case unit
        case indicator1Val = "Indicator1_val"
    }
}

// MARK: - MapMetaData
struct MapMetaData: Codable {
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