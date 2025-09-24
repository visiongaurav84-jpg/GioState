//
//  TrendingProduct+CoreDataProperties.swift
//  
//
//  Created by getitrent on 08/08/25.
//
//

import Foundation
import CoreData


extension TrendingProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrendingProduct> {
        return NSFetchRequest<TrendingProduct>(entityName: "TrendingProduct")
    }

    @NSManaged public var dataJSON: String?
    @NSManaged public var frequencyJSON: String?
    @NSManaged public var indicatorListJSON: String?
    @NSManaged public var indicatorsJSON: String?
    @NSManaged public var lastUpdatedDate: Date?
    @NSManaged public var metaDataJSON: String?
    @NSManaged public var productAggregateValue: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var productIcon: String?
    @NSManaged public var productName: String?
    @NSManaged public var productRank: Int32
    @NSManaged public var unit: String?
    @NSManaged public var valueDate: String?

}
