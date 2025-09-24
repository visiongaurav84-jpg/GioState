//
//  CustomMethods.swift
//  All India ITR
//
//  Created by IOS Developer on 13/06/20.
//  Copyright © 2020 Avineet. All rights reserved.
//

import Foundation
import UIKit
import DropDown
import FittedSheets

class CustomMethods{
    
    class func convertImageToBase64(image: UIImage) -> String? {
        let imageData = image.jpegData(compressionQuality: 0.5)
        return imageData?.base64EncodedString()
    }
    
    class func randomString(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var strinsRandom = ""
        
        for _ in 0 ..< length {
            strinsRandom.append(letters.randomElement()!)
        }
        print(strinsRandom)
        return strinsRandom
    }
    
    class func phonecall(mobileNo:Int){
        guard let url = URL(string: "telprompt://\(mobileNo)"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    class func numberOnlyString(text: String) -> String {
        let okayChars = Set("1234567890")
        return text.filter {okayChars.contains($0) }
    }
    
    class func currancyFomater(no: Int) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0;
        return formatter.string(from: no as NSNumber) ?? ""
    }
    
    class func phoneFormat(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    class func openDropDown(dropDown:DropDown,array:[String],anchor:UITextField,callBack:((_ dropDown:DropDown)->())){
        dropDown.anchorView = anchor
        dropDown.width = anchor.frame.size.width + 30
        dropDown.dataSource = array
        dropDown.bottomOffset = CGPoint(x: 0, y:anchor.bounds.height)
        dropDown.direction = .any
        dropDown.show()
        
        callBack(dropDown)
    }
    
    class func openDropDownss(dropDown:DropDown,array:[String], leading:Int, anchor:UIView,callBack:((_ dropDown:DropDown)->())){
        dropDown.anchorView = anchor
        dropDown.width = anchor.frame.size.width + 30
        dropDown.dataSource = array
        dropDown.bottomOffset = CGPoint(x: 0, y:anchor.bounds.height)
        dropDown.direction = .any
        
        dropDown.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        dropDown.customCellConfiguration = { Index, title, cell in
            guard let cell = cell as? MyCell else{
                return
            }
            cell.lblUserName.text = array[Index]
            //            if Index == 0{
            //                cell.lblUserName.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            //            }else{
            //                cell.lblUserName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            //            }
            
            cell.lblUserName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            if leading == 10{
                cell.imgUser.isHidden = true
            }else{
                cell.imgUser.isHidden = false
            }
            
            cell.constranintsLeadingLbl.constant = CGFloat(leading)
        }
        dropDown.show()
        callBack(dropDown)
    }
    
    
}

