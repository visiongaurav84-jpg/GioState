//
//  CommonFunctions.swift
//  USHA
//
//  Created by Hitesh Prajapati on 02/06/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import UIKit
import SystemConfiguration
import SVGKit
import SDWebImage
import SDWebImageWebPCoder
import Photos

//MARK: -
func openLink(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

func shareWebPBase64Image(base64String: String, presentingViewController: UIViewController) {
    // Step 1: Decode Base64 WebP data
    guard let webpData = Data(base64Encoded: base64String) else {
        showAlert(on: presentingViewController, title: "Error", message: "Invalid Base64 string.")
        return
    }
    
    // Step 2: Convert to UIImage (iOS 14+ supports WebP decoding)
    guard let image = UIImage(data: webpData) else {
        showAlert(on: presentingViewController, title: "Error", message: "Failed to decode WebP image. iOS 14+ required.")
        return
    }
    
    // Step 3: Re-encode as PNG for sharing
    guard let pngData = image.pngData() else {
        showAlert(on: presentingViewController, title: "Error", message: "Failed to convert image to PNG.")
        return
    }
    
    // Step 4: Write PNG data to temporary file
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("shared_image.png")
    do {
        try pngData.write(to: tempURL)
        
        // Step 5: Share via UIActivityViewController
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = presentingViewController.view // for iPad
        
        presentingViewController.present(activityVC, animated: true)
    } catch {
        showAlert(on: presentingViewController, title: "Error", message: "Could not write temporary image file.")
    }
}


func saveWebPBase64ToPhotos(base64String: String, presentingViewController: UIViewController) {
    // Step 1: Decode Base64 to Data
    guard let imageData = Data(base64Encoded: base64String) else {
        showAlert(on: presentingViewController, title: "Error", message: "Invalid Base64 data.")
        return
    }
    
    // Step 2: Create UIImage from WebP data
    guard let originalImage = UIImage(data: imageData) else {
        showAlert(on: presentingViewController, title: "Error", message: "Failed to decode WebP image. Requires iOS 14+.")
        return
    }
    
    // Step 3: Re-encode as PNG to ensure compatible format
    guard let pngData = originalImage.pngData(),
          let finalImage = UIImage(data: pngData) else {
        showAlert(on: presentingViewController, title: "Error", message: "Failed to re-encode image as PNG.")
        return
    }
    
    // Step 4: Request permission
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        DispatchQueue.main.async {
            guard status == .authorized || status == .limited else {
                showAlert(on: presentingViewController, title: "Permission Denied", message: "Enable access in Settings > Privacy > Photos.")
                return
            }
            
            // Step 5: Save using Photo Library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        showAlert(on: presentingViewController, title: "Success", message: "Image saved to your Photos.")
                    } else {
                        showAlert(on: presentingViewController, title: "Save Failed", message: error?.localizedDescription ?? "Unknown error.")
                    }
                }
            }
        }
    }
}


func shareUIImage(_ image: UIImage, presentingViewController: UIViewController) {
    // Convert UIImage to PNG data (you can use JPEG if you prefer)
    guard let pngData = image.pngData() else {
        showAlert(on: presentingViewController, title: "Error", message: "Failed to convert image to PNG.")
        return
    }
    
    // Save PNG data to a temporary file
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("shared_image.png")
    do {
        try pngData.write(to: tempURL)
        
        // Share via UIActivityViewController
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = presentingViewController.view // for iPad support
        
        presentingViewController.present(activityVC, animated: true)
    } catch {
        showAlert(on: presentingViewController, title: "Error", message: "Could not write temporary image file.")
    }
}


func saveUIimageInPhoto(finalImage: UIImage, presentingViewController: UIViewController){
    // Step 4: Request permission
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        DispatchQueue.main.async {
            guard status == .authorized || status == .limited else {
                showAlert(on: presentingViewController, title: "Permission Denied", message: "Enable access in Settings > Privacy > Photos.")
                return
            }
            
            // Step 5: Save using Photo Library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        showAlert(on: presentingViewController, title: "Success", message: "Image saved to your Photos.")
                    } else {
                        showAlert(on: presentingViewController, title: "Save Failed", message: error?.localizedDescription ?? "Unknown error.")
                    }
                }
            }
        }
    }
}

// MARK: - Alert Helper
private func showAlert(on viewController: UIViewController, title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    viewController.present(alert, animated: true)
}



func setHTMLContent(html: String, textView: UITextView, updateHeightConstraint: NSLayoutConstraint? = nil) {
    let font = UIFont(name: "NotoSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
    let color = textView.textColor ?? UIColor.textColorThreeBlackToYellow
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 4
    paragraphStyle.paragraphSpacing = 8
    
    let fullAttrText = NSMutableAttributedString()
    
    // Detect and extract list items
    if html.contains("<ol>") || html.contains("<ul>") {
        let isOrdered = html.contains("<ol>")
        let listRegex = try! NSRegularExpression(pattern: "<li[^>]*>(.*?)</li>", options: [.dotMatchesLineSeparators, .caseInsensitive])
        let matches = listRegex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        
        for (i, match) in matches.enumerated() {
            if let range = Range(match.range(at: 1), in: html) {
                var item = String(html[range])
                
                // Strip HTML tags inside the list item
                item = item.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                item = item.replacingOccurrences(of: "&nbsp;", with: " ")
                
                let prefix = isOrdered ? "\(i + 1). " : "• "
                let bulletText = prefix + item.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
                
                let attr = NSAttributedString(string: bulletText, attributes: [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ])
                
                fullAttrText.append(attr)
            }
        }
        
        // Try to extract and append non-list content after </ol> or </ul>
        if let range = html.range(of: "</ol>") ?? html.range(of: "</ul>") {
            let rest = String(html[range.upperBound...])
            if let restData = rest.data(using: .utf8),
               let restAttr = try? NSMutableAttributedString(data: restData, options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
               ], documentAttributes: nil) {
                
                restAttr.addAttributes([
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ], range: NSRange(location: 0, length: restAttr.length))
                fullAttrText.append(restAttr)
            }
        }
    } else {
        // Fallback: normal HTML content (no list detected)
        if let data = html.data(using: .utf8),
           let attributedString = try? NSMutableAttributedString(data: data, options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
           ], documentAttributes: nil) {
            attributedString.addAttributes([
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: attributedString.length))
            
            fullAttrText.append(attributedString)
        }
    }
    
    // Final setup
    textView.attributedText = fullAttrText
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.isSelectable = true
    textView.dataDetectorTypes = [.link]
    
    // Adjust height after layout
    DispatchQueue.main.async {
        textView.layoutIfNeeded()
        let contentHeight = textView.contentSize.height
        print("Final content height: \(contentHeight)")
        if let constraint = updateHeightConstraint {
            constraint.constant = contentHeight
            textView.superview?.layoutIfNeeded()
        }
    }
}


func setHTMLContent2(
    html: String,
    textView: UITextView,
    updateHeightConstraint: NSLayoutConstraint? = nil
) {
    // Fonts and color (adjust sizes if you want slightly larger/smaller)
    let regularFont = UIFont(name: "NotoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
    let boldFont = UIFont(name: "NotoSans-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
    let color = textView.textColor ?? UIColor.textColorThreeBlackToYellow
    
    // Global paragraph style (used for normal paragraphs)
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 1
    para.paragraphSpacing = 8
    para.alignment = .justified
    
    // Paragraph style for list items so wrapped lines align under text (not number)
    let listPara = NSMutableParagraphStyle()
    listPara.lineSpacing = 1
    listPara.paragraphSpacing = 8
    listPara.alignment = .justified
    listPara.firstLineHeadIndent = 0
    listPara.headIndent = 28                 // indent for wrapped lines
    listPara.tabStops = [NSTextTab(textAlignment: .left, location: 28)]
    
    let result = NSMutableAttributedString()
    
    // 1) Split around the first <ol> ... </ol> block (works for your HTML structure)
    if
        let olStartRange = html.range(of: "<ol", options: .caseInsensitive),
        let olOpenTagEnd = html.range(of: ">", range: olStartRange.lowerBound..<html.endIndex),
        let olEndRange = html.range(of: "</ol>", options: .caseInsensitive)
    {
        let beforeListHTML = String(html[..<olStartRange.lowerBound])
        let listInnerHTML = String(html[olOpenTagEnd.upperBound..<olEndRange.lowerBound])
        let afterListHTML = String(html[olEndRange.upperBound...])
        
        // Convert the part before the list (this contains the "Our Role" strong heading)
        if let beforeData = beforeListHTML.data(using: .utf8),
           let beforeAttr = try? NSMutableAttributedString(
            data: beforeData,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        {
            // Normalize fonts: preserve bold vs regular
            normalizeFontsAndStyle(attr: beforeAttr, regularFont: regularFont, boldFont: boldFont, color: color, paragraphStyle: para)
            result.append(beforeAttr)
            // Make sure there's a newline after the heading
            if result.string.last != "\n" {
                result.append(NSAttributedString(string: "\n"))
            }
        }
        
        // Extract <li> items from listInnerHTML and build numbered items manually with tab
        let liPattern = "<li[^>]*>([\\s\\S]*?)</li>"
        let liRegex = try! NSRegularExpression(pattern: liPattern, options: [.caseInsensitive])
        let innerNSRange = NSRange(listInnerHTML.startIndex..<listInnerHTML.endIndex, in: listInnerHTML)
        let matches = liRegex.matches(in: listInnerHTML, options: [], range: innerNSRange)
        
        for (index, match) in matches.enumerated() {
            guard match.numberOfRanges >= 2,
                  let itemRange = Range(match.range(at: 1), in: listInnerHTML)
            else { continue }
            
            var itemHTML = String(listInnerHTML[itemRange])
            // Remove tags inside <li> and decode entities:
            // - decode HTML entities using our helper
            // - then strip any remaining tags (if present)
            itemHTML = itemHTML.htmlDecoded
            itemHTML = itemHTML.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            itemHTML = itemHTML.replacingOccurrences(of: "\n", with: " ")
            let trimmed = itemHTML.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Build numbered line with a tab so paragraph style tabStops/ headIndent align properly
            let numbered = "\(index + 1).\t\(trimmed)\n"
            let attr = NSMutableAttributedString(string: numbered, attributes: [
                .font: regularFont,
                .foregroundColor: color,
                .paragraphStyle: listPara
            ])
            result.append(attr)
        }
        
        // Add an extra newline after the list for spacing
        result.append(NSAttributedString(string: "\n"))
        
        // Convert after-list content (this contains NSO LEADERSHIP etc)
        if let afterData = afterListHTML.data(using: .utf8),
           let afterAttr = try? NSMutableAttributedString(
            data: afterData,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        {
            normalizeFontsAndStyle(attr: afterAttr, regularFont: regularFont, boldFont: boldFont, color: color, paragraphStyle: para)
            result.append(afterAttr)
        }
    } else {
        // No <ol> found — simply parse full HTML and normalize fonts
        if let data = html.data(using: .utf8),
           let attr = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        {
            normalizeFontsAndStyle(attr: attr, regularFont: regularFont, boldFont: boldFont, color: color, paragraphStyle: para)
            result.append(attr)
        }
    }
    
    // Final UITextView setup
    textView.attributedText = result
    textView.isEditable = false
    textView.isSelectable = true
    textView.isScrollEnabled = false
    textView.dataDetectorTypes = [.link]
    textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 12)
    textView.textContainer.lineFragmentPadding = 0
    
    // Update height after layout (sizeThatFits gives reliable result)
    DispatchQueue.main.async {
        let targetSize = CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let fitting = textView.sizeThatFits(targetSize)
        if let c = updateHeightConstraint {
            c.constant = fitting.height
            textView.superview?.layoutIfNeeded()
        }
    }
}

func setHTMLContentForKeyTrendings(
    html: String,
    textView: UITextView,
    updateHeightConstraint: NSLayoutConstraint? = nil
) {
    let font = UIFont(name: "NotoSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
    let boldFont = UIFont(name: "NotoSans-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
    let color = textView.textColor ?? UIColor.textColorThreeBlackToYellow
    let bulletColor = UIColor.textColorThreeBlackToYellow   // change this to any color you want for bullets/numbers
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 4
    paragraphStyle.paragraphSpacing = 8
    paragraphStyle.alignment = .justified
    
    guard let data = html.data(using: .utf8),
          let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
          ) else {
        textView.text = html
        return
    }
    
    attributedString.addAttributes([
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraphStyle
    ], range: NSRange(location: 0, length: attributedString.length))
    
    let finalText = NSMutableAttributedString()
    attributedString.string.enumerateLines { line, _ in
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }
        
        if let range = attributedString.string.range(of: line) {
            let nsRange = NSRange(range, in: attributedString.string)
            let lineAttr = attributedString.attributedSubstring(from: nsRange).mutableCopy() as! NSMutableAttributedString
            
            // Headings bold
            if trimmed.lowercased().contains("about the infographic")
                || trimmed.lowercased().contains("key takeaways") {
                lineAttr.addAttribute(.font, value: boldFont, range: NSRange(location: 0, length: lineAttr.length))
            }
            // Skip bullets if already numbered ("1.", "2)") OR starts with "Source:"
            else if !trimmed.hasPrefix("•"),
                    trimmed.range(of: #"^\d+[\.\)]"#, options: .regularExpression) == nil,
                    !trimmed.lowercased().hasPrefix("source:") {
                
                let bullet = NSMutableAttributedString(
                    string: "• ",
                    attributes: [
                        .font: font,
                        .foregroundColor: bulletColor,   // bullet colored separately
                        .paragraphStyle: paragraphStyle
                    ]
                )
                bullet.append(lineAttr) // append rest of the line (normal color)
                lineAttr.setAttributedString(bullet)
            } else {
                // If it's a numbered line, color just the number part
                if let match = trimmed.range(of: #"^\d+[\.\)]"#, options: .regularExpression) {
                    let nsNumRange = NSRange(match, in: trimmed)
                    lineAttr.addAttribute(.foregroundColor, value: bulletColor, range: nsNumRange)
                }
            }
            
            lineAttr.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: lineAttr.length))
            lineAttr.append(NSAttributedString(string: "\n", attributes: [.paragraphStyle: paragraphStyle]))
            
            finalText.append(lineAttr)
        }
    }
    
    textView.attributedText = finalText
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.isSelectable = true
    textView.dataDetectorTypes = [.link]
    textView.linkTextAttributes = [
        .foregroundColor: UIColor.systemBlue,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    DispatchQueue.main.async {
        textView.layoutIfNeeded()
        let contentHeight = textView.contentSize.height
        if let constraint = updateHeightConstraint {
            constraint.constant = contentHeight
            textView.superview?.layoutIfNeeded()
        }
    }
}

/// Also applies a provided paragraph style and color.
private func normalizeFontsAndStyle(attr: NSMutableAttributedString, regularFont: UIFont, boldFont: UIFont, color: UIColor, paragraphStyle: NSParagraphStyle) {
    let full = NSRange(location: 0, length: attr.length)
    attr.enumerateAttribute(.font, in: full, options: []) { value, range, _ in
        if let existing = value as? UIFont {
            let traits = existing.fontDescriptor.symbolicTraits
            if traits.contains(.traitBold) {
                attr.addAttribute(.font, value: boldFont, range: range)
            } else {
                attr.addAttribute(.font, value: regularFont, range: range)
            }
        } else {
            attr.addAttribute(.font, value: regularFont, range: range)
        }
    }
    attr.addAttribute(.foregroundColor, value: color, range: full)
    attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: full)
}




func setHTMLContent(html: String, label: UILabel, fontSize:Int = 16) {
    guard let data = html.data(using: .utf8) else {
        label.text = html
        return
    }
    
    do {
        let attributedString = try NSMutableAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
        
        // Optional: customize formatting
        let fullRange = NSRange(location: 0, length: attributedString.length)
        let font = UIFont(name: "NotoSans-Regular", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
        let color = label.textColor ?? UIColor.label
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.alignment = .justified  // This makes it justified
        
        attributedString.addAttributes([
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ], range: fullRange)
        
        label.attributedText = attributedString
        label.numberOfLines = 0
        
    } catch {
        print("Failed to parse HTML: \(error)")
        label.text = html
    }
}


func extractPdfUrlFromHtml(html: String) -> String? {
    let pattern = #"href=["'](.*?\.pdf)["']"#
    if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        if let match = regex.firstMatch(in: html, options: [], range: range),
           let urlRange = Range(match.range(at: 1), in: html) {
            return String(html[urlRange])
        }
    }
    return nil
}


func jsonToPrettyString(_ jsonObject: Any) -> String? {
    do {
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        return String(data: data, encoding: .utf8)
    } catch {
        print("Failed to convert JSON to pretty string:", error)
        return nil
    }
}

func displayWebP(base64String: String, imageView: UIImageView) {
    // Ensure WebP coder is registered
    let WebPCoder = SDImageWebPCoder.shared
    SDImageCodersManager.shared.addCoder(WebPCoder)
    
    // Decode Base64 string to Data
    guard let imageData = Data(base64Encoded: base64String) else {
        print("Invalid Base64 string.")
        return
    }
    
    // Decode WebP image to UIImage
    guard let image = SDImageWebPCoder.shared.decodedImage(with: imageData, options: nil) else {
        print("Failed to decode WebP image.")
        return
    }
    
    // Set image on the given UIImageView
    DispatchQueue.main.async {
        imageView.image = image
    }
}


func displaySVG(from imgSt: String, in imageView: UIImageView) {
    
    guard let decodedData = Data(base64Encoded: imgSt) else {
        print("Failed to decode Base64 string")
        return
    }
    
    // Convert byte data to String
    guard let svgString = String(data: decodedData, encoding: .utf8) else {
        print("Unable to convert byte data to string")
        return
    }
    
    // Convert string back to Data (optional, SVGKit needs Data or path)
    guard let svgData = svgString.data(using: .utf8) else {
        print("Unable to convert string to UTF-8 data")
        return
    }
    
    // Load the SVG image
    if let svgImage = SVGKImage(data: svgData) {
        imageView.image = svgImage.uiImage
    } else {
        print("Failed to load SVG image")
    }
}

func stringToBase64(valueStr:String)->String{
    
    let utf8str = valueStr.data(using: .utf8)
    
    var base64Str = ""
    if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
        print("Encoded: \(base64Encoded)")
        base64Str = base64Encoded
        if let base64Decoded = Data(base64Encoded: base64Encoded, options: Data.Base64DecodingOptions(rawValue: 0))
            .map({ String(data: $0, encoding: .utf8) }) {
            // Convert back to a string
           // print("Decoded: \(base64Decoded ?? "")")
        }
    }
    return base64Str
}

func base64ToString(valueStr:String)->String{
    var base64ToStr = ""
    if let base64Decoded = Data(base64Encoded: valueStr, options: Data.Base64DecodingOptions(rawValue: 0))
        .map({ String(data: $0, encoding: .utf8) }) {
        // Convert back to a string
        //print("Decoded: \(base64Decoded ?? "")")
        base64ToStr = base64Decoded ?? ""
    }
    return base64ToStr
}

func getDate(date:String) -> String {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "yyyy-MM-dd"
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = "dd-MM-yyyy"
    
    if let date = dateFormatterGet.date(from: date) {
        return dateFormatterPrint.string(from: date)
    } else {
        print("There was an error decoding the string")
        return ""
    }
}



func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
}


extension UIViewController {
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func popupActionSheet(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = getColor(hex: "AA2323")
        
        for (index, title) in actionTitles.enumerated() {
            if title == "Back"{
                let action = UIAlertAction(title: title, style: .cancel, handler: actions[index])
                actionSheet.addAction(action)
            }else{
                let action = UIAlertAction(title: title, style: .default, handler: actions[index])
                actionSheet.addAction(action)
            }
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
}




//MARK:- Date
func getStringFrom(_ dateval: Date?, format Strformat: String?) -> String? {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = Strformat ?? ""
    var dateString: String? = nil
    if let aDateval = dateval {
        dateString = dateFormater.string(from: aDateval)
    }
    return dateString
}

func getDateFrom(_ str: String?, givenFormat strGivenFormat: String?, returnFormat strReturnFormat: String?) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = strGivenFormat ?? ""
    let date: Date? = dateFormatter.date(from: str ?? "")
    let strDate = getStringFrom(date, format: strReturnFormat)
    return strDate
}

func getPastYears(count : Int = 20) -> [String]{
    var years = [String]()
    for i in -count ... 0{
        if let date = Calendar.current.date(byAdding: .year, value: i, to: Date()){
            years.append(getDateFrom("\(date)", givenFormat: "yyyy-MM-dd HH:mm:ss Z", returnFormat: "yyyy") ?? "-")
        }
    }
    years = years.reversed()
    return years
}

func getMonthsList() -> [String]{
    return ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
}

//MARK:- Alerts
func showAlert(vc : UIViewController, title : String = APPNAME, message : String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
    }))
    vc.present(alert, animated: true, completion: nil)
}

func showConfirmationAlert(vc : UIViewController, title : String = APPNAME, message : String, btnOkTitle : String, btnCancelTitle : String, confirmation : @escaping(_ isConfirm : Bool) -> Void){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let actionOK = UIAlertAction(title: btnOkTitle, style: .default) { (action) in
        confirmation(true)
    }
    let actionCancel = UIAlertAction(title: btnCancelTitle, style: .cancel){ (action) in
        confirmation(false)
    }
    alert.addAction(actionOK)
    alert.addAction(actionCancel)
    vc.present(alert, animated: true, completion: nil)
}

func showSessionExpiredAlert(vc : UIViewController) {
    let alert = UIAlertController(title: APPNAME, message: "Session expired.\nPlease login again to continue.", preferredStyle: .alert)
    let actionOK = UIAlertAction(title: "OK", style: .default) { (action) in
        if #available(iOS 13.0, *) {
            logoutUser()
        } else {
            logoutUser()
        }
    }
    alert.addAction(actionOK)
    vc.present(alert, animated: true, completion: nil)
}


//func showTextFieldAlert(vc : UIViewController, message : String, response : @escaping(_ value : String) -> Void){
//    let alert = UIAlertController(title: APPNAME, message: message, preferredStyle: .alert)
//    alert.addTextField { (textField) in
//        //textField.placeholder = ""
//        textField.addTarget(alert, action: #selector(alert.isEmpty), for: .editingChanged)
//    }
//
//    let actionSubmit = UIAlertAction(title: "Submit", style: .default) { [weak alert] (_) in
//        let textField = alert!.textFields![0]
//        response(textField.text!)
//    }
//    actionSubmit.isEnabled = false
//
//    alert.addAction(actionSubmit)
//    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
//    }))
//
//    vc.present(alert, animated: true, completion: nil)
//}

////MARK:-
//@available(iOS 13.0, *)
//func showImageViewer(images : [SKPhoto], startIndex : Int){
//    if let vc = AppDelegate.shared.window?.rootViewController, images.count > 0{
//        SKPhotoBrowserOptions.displayAction = false
//        let imgViewer = SKPhotoBrowser(photos: images)
//        imgViewer.initializePageIndex(startIndex)
//        vc.present(imgViewer, animated: true, completion: nil)
//    }
//}

//MARK:-
func getErrorMessage(from response : NSDictionary) -> String{
    var errorMsgs = ""
    if let arrayKeys = response.allKeys as? [String] {
        
        for key in arrayKeys{
            if let errors = response[key] as? [String]{
                errorMsgs.append(errors.joined(separator: "\n"))
            }
            else if let errors = response[key] as? String{
                errorMsgs.append(errors)
            }
        }
        if let errors = response["errorMessage"] as? String{
            errorMsgs.append(errors)
        }
        return errorMsgs.isBlank ? AppMessages.SomethingWrong : errorMsgs
    }
    return errorMsgs.isBlank ? AppMessages.SomethingWrong : errorMsgs
}

func logoutUser(){
    Constant.isUserLogin = false
    USERDEFAULTS.removeObject(forKey: UDKeys.AccessToken)
    USERDEFAULTS.removeObject(forKey: UDKeys.TokenType)
    AppDelegate.shared.setupRootVC()
    UIView.transition(with: AppDelegate.shared.window!, duration: 0.4, options: .transitionCrossDissolve, animations: { }, completion: nil)
}

import SVProgressHUD

func downloadPDF(url: URL, vc: UIViewController, showLoading: Bool = true) {
    
    // MARK: - Show Loader
    if showLoading {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.textColorOneBlueToYellow)
        SVProgressHUD.setForegroundColor(UIColor.textColorSixWhiteToBlack)
        SVProgressHUD.setRingRadius(10)                 // Spinner radius
        SVProgressHUD.setRingThickness(1.5)             // Spinner thickness
        SVProgressHUD.setFont(.systemFont(ofSize: 12))  // Status label font
        SVProgressHUD.setMinimumSize(CGSize(width: 5, height: 5)) // Force size
        SVProgressHUD.setContainerView(nil) // ensure not overridden
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.show(withStatus: "Getting things ready for you...")
        
        vc.view.isUserInteractionEnabled = false   // Disable interaction
    }
    
    // MARK: - Prepare file name
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = dateFormatter.string(from: Date())
    let appendFileName = dateString + url.lastPathComponent
    let fileName = appendFileName + ".pdf"
    
    guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let destinationFileUrl = documentsUrl.appendingPathComponent(fileName)
    
    // MARK: - Start download
    let session = URLSession(configuration: .default)
    let task = session.downloadTask(with: url) { (tempLocalUrl, response, error) in
        
        // MARK: - Hide loader
        DispatchQueue.main.async {
            if showLoading {
                SVProgressHUD.dismiss()
                vc.view.isUserInteractionEnabled = true   // Re-enable interaction
            }
        }
        
        if let tempLocalUrl = tempLocalUrl, error == nil {
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                print("Successfully downloaded. Status code: \(statusCode)")
            }
            do {
                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    
                    if let fileUrl = contents.first(where: { $0.lastPathComponent == destinationFileUrl.lastPathComponent }) {
                        DispatchQueue.main.async {
                            let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                            if let popController = activityViewController.popoverPresentationController {
                                popController.sourceView = vc.view
                            }
                            vc.present(activityViewController, animated: true, completion: nil)
                        }
                    }
                    
                } catch {
                    print("Error reading directory: \(error)")
                }
                
            } catch {
                print("Error saving file \(destinationFileUrl): \(error)")
            }
        } else {
            print("Download error: \(error?.localizedDescription ?? "")")
        }
    }
    task.resume()
}


func shareURL(urlString: String, title: String? = nil, from viewController: UIViewController) {
    
    guard let url = URL(string: urlString) else {
        //print("Invalid URL string: \(urlString)")
        return
    }
    
    var items: [Any] = [url]
    
    if let title = title {
        items.insert(title, at: 0) // Adds text before URL
    }
    
    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
    
    // iPad support (to avoid crash)
    if let popover = activityVC.popoverPresentationController {
        popover.sourceView = viewController.view
        popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                    y: viewController.view.bounds.midY,
                                    width: 0, height: 0)
        popover.permittedArrowDirections = []
    }
    
    viewController.present(activityVC, animated: true, completion: nil)
}

