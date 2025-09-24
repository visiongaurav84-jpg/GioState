//
//  PressReleaseResponse.swift
//  goistats
//
//  Created by getitrent on 08/08/25.
//


import Foundation

struct PressReleaseResponse: Codable {
    let data: [PressData]?
}

struct PressData: Codable, Identifiable, Equatable {
    let id = UUID() // Unique identifier, not optional
    let releaseDate: String?
    let documentTitle: String?
    let type: String?
    let documentOverview: String?
    let documentPath: String?
    var isExpanded: Bool? = false

    enum CodingKeys: String, CodingKey {
        case releaseDate = "release_date"
        case documentTitle = "document_title"
        case type
        case documentOverview = "document_overview"
        case documentPath = "document_path"
    }
}
