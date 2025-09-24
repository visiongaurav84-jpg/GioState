//
//  CoreDataHelper.swift
//  goistats
//
//  Created by Mahendra Bohra on 08/08/25.
//

import Foundation
import CoreData

//MARK: - CoreDataHelper Functions

func encodeToJSONString<T: Encodable>(_ obj: T?) -> String? {
    guard let obj = obj,
          let data = try? JSONEncoder().encode(obj),
          let jsonString = String(data: data, encoding: .utf8) else { return nil }
    return jsonString
}


func getLastUpdatedDate() -> String {
    let context = CoreDataStack.shared.context
    let request: NSFetchRequest<TrendingProduct> = TrendingProduct.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "lastUpdatedDate", ascending: false)]
    request.fetchLimit = 1
    
    do {
        if let date = try context.fetch(request).first?.lastUpdatedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy" // Aug 12, 2025
            return formatter.string(from: date)
        }
    } catch {
        print("Error fetching last updated date:", error)
    }
    return "N/A"
}
