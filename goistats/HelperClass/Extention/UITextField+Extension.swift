//
//  UITextField+Extension.swift
//  USHA
//
//  Created by Hitesh Prajapati on 25/05/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import UIKit
private var __maxLengths = [UITextField: Int]()
extension UITextField{
    
    func setAppTheme(){
        self.setBorder(cornerRadius: 15, borderColor: AppColor.TextFieldBorderColor, borderWidth: 1)
    }
    
    func setInputViewDatePicker(target: Any, minDate : Date?, maxDate : Date?, selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .date //2
        if let date = minDate{
            datePicker.minimumDate = date
        }
        if let date = maxDate{
            datePicker.maximumDate = date
        }
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        
        self.inputView = datePicker //3
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        //let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
        barButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.systemBlue], for: .normal)
        barButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.systemBlue], for: .highlighted)
        toolBar.setItems([flexible, barButton], animated: false) //8
        self.inputAccessoryView = toolBar //9
    }
    
    func setInputViewTimePicker(target: Any, minDate : Date?, maxDate : Date?, selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .time //2
        if let date = minDate{
            datePicker.minimumDate = date
        }
        if let date = maxDate{
            datePicker.maximumDate = date
        }
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        
        self.inputView = datePicker //3
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        //let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
        barButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : self.tintColor ?? UIColor.systemBlue], for: .normal)
        barButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : self.tintColor ?? UIColor.systemBlue], for: .highlighted)
        toolBar.setItems([flexible, barButton], animated: false) //8
        self.inputAccessoryView = toolBar //9
    }
    
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    var isEmpty: Bool {
        let trimmedString = self.text?.trimmingCharacters(in: .whitespaces)
        if(trimmedString == "" || trimmedString == nil) {
            return true
        }
        return false
    }
    var isValidEmail: Bool {
        //        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailRegEx = "^[-A-Za-z0-9~!$%^&*_=+}{\'?]+(\\.[-A-Za-z0-9~!$%^&*_=+}{\'?]+)*@([A-Za-z0-9_][-A-Za-z0-9_]*(\\.[-A-Za-z0-9_]+)*\\.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[A-Za-z][A-Za-z])|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,5})?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text!)
    }
    
    
    
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    @IBInspectable var leftPadding: Double {
        get {
            self.leftViewMode = .never
            return 0
        }
        set {
            self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: 0))
            self.leftViewMode = .always
        }
    }
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
    
    var isValidPhoneNo: Bool{
        if self.text!.count == 10 {
            return true
        }
        return false
    }
    
    var isValidName: Bool{
        if self.text!.count >= 3 && self.text!.count <= 100 {
            return true
        }
        return false
    }
    var isValidPassword: Bool{
        if self.text!.count >= 7  {
            return true
        }
        return false
    }
    var isValidPan: Bool {
        let emailRegEx = "[A-Z]{5}[A-Z]{1}[0-9]{4}[A-Z]{1}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text!)
    }
    var isValidGSTIN: Bool {
        let emailRegEx = "^([0]{1}[1-9]{1}|[1-2]{1}[0-9]{1}|[3]{1}[0-7]{1})([a-zA-Z]{5}[0-9]{4}[a-zA-Z]{1}[1-9a-zA-Z]{1}[zZ]{1}[0-9a-zA-Z]{1})+$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text!)
    }
    
    var isValidAdharNo: Bool{
        if self.text!.count >= 12 {
            return true
        }
        return false
    }
    
    var isValidPinCode: Bool {
        let emailRegEx =  "^[0-9]{6}$"    // for US   "^[0-9]{5}(-[0-9]{4})?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text!)
    }
    var isValidIFSCCode: Bool {
        let emailRegEx =  "^[A-Z]{4}0[A-Z0-9]{6}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text!)
    }
    
    
    
    
}
extension String
{
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}

