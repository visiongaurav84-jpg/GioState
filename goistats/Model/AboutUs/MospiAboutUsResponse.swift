//
//  MospiAboutUsResponse.swift
//  goistats
//
//  Created by getitrent on 08/08/25.
//


import Foundation

struct MospiAboutUsResponse: Codable {
    var organogramDetails: OrganogramDetails?
    var ministryProfile: MinistryProfile?
    var secretary: Secretary?
    var aboutNSO: AboutNSO?
    var divisionDetails: [DivisionDetails]?
    var nsoLeadership: [NSOLeadership]?
    var statusCode: String?
    
    enum CodingKeys: String, CodingKey {
        case organogramDetails = "OrganogramDetails"
        case ministryProfile = "MinistryProfile"
        case secretary = "Secretary"
        case aboutNSO = "AboutNSO"
        case divisionDetails = "DivisionDetails"
        case nsoLeadership = "NSOLeadership"
        case statusCode
    }
}

struct OrganogramDetails: Codable {
    var organogramTitle: String?
    var organogramImage: String?
    var organogramImageDark: String?
    
    enum CodingKeys: String, CodingKey {
        case organogramTitle = "organogram_title"
        case organogramImage = "organogram_image"
        case organogramImageDark = "organogram_image_dark"
    }
}

struct MinistryProfile: Codable {
    var aboutMinistry: String?
    var ministerName: String?
    var ministerProfilePath: String?
    var ministerDesignation: String?
    var aboutMinister: String?
    var ministerImage: String?
    
    enum CodingKeys: String, CodingKey {
        case aboutMinistry = "about_ministry"
        case ministerName = "minister_name"
        case ministerProfilePath = "minister_profile_path"
        case ministerDesignation = "minister_designation"
        case aboutMinister = "about_minister"
        case ministerImage = "minister_image"
    }
}

struct AboutNSO: Codable {
    var aboutNSO: String?
    
    enum CodingKeys: String, CodingKey {
        case aboutNSO = "about_nso"
    }
}

struct Secretary: Codable {
    var secretaryImage: String?
    var secretaryDesignation: String?
    var secretaryName: String?
    var aboutSecretary: String?
    
    enum CodingKeys: String, CodingKey {
        case secretaryImage = "secretary_image"
        case secretaryDesignation = "secretary_designation"
        case secretaryName = "secretary_name"
        case aboutSecretary = "about_secretary"
    }
}

struct DivisionDetails: Codable, Identifiable {
    var id = UUID()
    var divisionTitle: String?
    var divisionOverview: String?
    var isExpanded: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case divisionTitle = "division_title"
        case divisionOverview = "division_overview"
    }
}

struct NSOLeadership: Codable, Identifiable {
    var id = UUID()
    var dgName: String?
    var dgStatus: String?
    var dgProfile: String?
    var dgImage: String?
    
    enum CodingKeys: String, CodingKey {
        case dgName = "dg_name"
        case dgStatus = "dg_status"
        case dgProfile = "dg_profile"
        case dgImage = "dg_image"
    }
}
