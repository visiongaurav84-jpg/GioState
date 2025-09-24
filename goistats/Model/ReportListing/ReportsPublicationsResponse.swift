//
//  ReportsPublicationsResponse.swift
//  goistats
//
//  Created by getitrent on 08/08/25.
//


import Foundation

struct ReportsPublicationsResponse: Codable {
    let data: [ReportData]?
}

struct ReportData: Codable, Identifiable {
    var id: UUID? = UUID()

    let documentTitle: String?
    let documentOverview: String?
    let thumbnail: String?
    let releaseDate: String?
    let type: String?
    let documentPath: String?
    
    var isExpanded: Bool? = false

    enum CodingKeys: String, CodingKey {
        case documentTitle = "document_title"
        case documentOverview = "document_overview"
        case thumbnail
        case releaseDate = "release_date"
        case type
        case documentPath = "document_path"
    }
}