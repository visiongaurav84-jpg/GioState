//
//  Date+Extension.swift
//  DelhiMetro
//
//  Created by Hardik on 09/04/21.
//

import Foundation

extension Date {
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let strDate: String = formatter.string(from: self)
        return strDate
    }
    
    func getFilterDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let strDate: String = formatter.string(from: self)
        return strDate
    }
    
    func getDisplaySortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let strDate: String = formatter.string(from: self)
        return strDate
    }
}
