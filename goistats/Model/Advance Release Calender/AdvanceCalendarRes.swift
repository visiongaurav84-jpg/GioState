import Foundation

struct ReleaseCalendar: Codable {
    var totalRecords: Int?
    var releaseList: [ReleaseList]?
    var statusCode: String?
    var footer: String?

    enum CodingKeys: String, CodingKey {
        case totalRecords = "TotalRecords"
        case releaseList
        case statusCode
        case footer
    }
}

struct ReleaseList: Codable {
    var month: String?
    var data: [ReleaseData]?

    enum CodingKeys: String, CodingKey {
        case month = "Month"
        case data = "Data"
    }
}

struct ReleaseData: Codable {
    var releaseData: String?
    var dateOfRelease: String?

    enum CodingKeys: String, CodingKey {
        case releaseData = "release_data"
        case dateOfRelease = "date_of_release"
    }
}
