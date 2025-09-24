//
//  String+Extension.swift
//  USHA
//
//  Created by Hitesh Prajapati on 25/05/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import Foundation
extension String{
    
    /// Convert HTML fragments/entities to plain text (decodes &nbsp; &amp; etc).
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributed = try? NSAttributedString(data: data, options: opts, documentAttributes: nil) {
            return attributed.string
        }
        return self
    }
    
    func htmlToPlainString() -> String {
            guard let data = self.data(using: .utf8) else { return "" }
            do {
                let attributedString = try NSAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
                )
                return attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                print("HTML parse error: \(error)")
                return self
            }
        }
    
    func htmlToAttributedString() -> NSAttributedString? {
            guard let data = self.data(using: .utf8) else { return nil }
            do {
                let attributedString = try NSMutableAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
                )
                
                // Trim leading/trailing whitespace/newlines
                let clean = attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
                return NSAttributedString(string: clean, attributes: attributedString.attributes(at: 0, effectiveRange: nil))
            } catch {
                print("HTML error: \(error)")
                return nil
            }
        }
    
    
    var isValidEmail: Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // at least 8 characters
        //let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$%^&*?]).{8,}")
        // AlphaNumeric
        // at least 8 characters
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[a-zA-Z])(?=.*[0-9]).{8,}")
        return passwordTest.evaluate(with: self)
    }
    
    var isBlank : Bool {
        let charSet = CharacterSet.whitespaces
        let trimmedString = self.trimmingCharacters(in: charSet)
        if (trimmedString == "") {
            return true
        }
        if self.count == 0 || (self == "") || (self == "(null)") || (self == "<null>") || (self == "null") {
            return true
        }
        return false
    }
    
    var encode : String{
        let data = self.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    var decode : String{
        let data = self.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII) ?? self
    }
    
    var withoutHtmlTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options:
                .regularExpression, range: nil).replacingOccurrences(of: "&[^;]+;", with:
                                                                        "", options:.regularExpression, range: nil)
    }
    
    func convertIntoDispalyDateOnly() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        if let date = formatter.date(from: self) {
            let formateDay = DateFormatter()
            formateDay.dateFormat = "dd-MM-yyyy hh:mm a"
            let strDay = formateDay.string(from: date)
            
            return "\(strDay)"
        }
        return ""
    }
}
