//
//  FeedbackVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 03/08/25.
//

import UIKit

class FeedbackVC: UIViewController {
    
    @IBOutlet weak var lblFeedback: UILabel!
    @IBOutlet weak var txtViewRmark: UITextView!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
    }
    
    
    func setUpUi(){
        txtName.attributedPlaceholder = NSAttributedString(
            string: "Your Name",
            attributes: [
                .foregroundColor: UIColor.black // Change to your desired color
            ]
        )
        txtEmail.attributedPlaceholder = NSAttributedString(
            string: "Your Email",
            attributes: [
                .foregroundColor: UIColor.black // Change to your desired color
            ]
        )
        txtPhone.attributedPlaceholder = NSAttributedString(
            string: "Your Phone Number",
            attributes: [
                .foregroundColor: UIColor.black // Change to your desired color
            ]
        )
    }
    
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func submitFeedback(_ sender: Any) {
        // Trimmed inputs
        let name = txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = txtPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let remark = txtViewRmark.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Patterns
        let emailPattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let mobilePattern = "^[0-9]{10}$"
        let invalidCharPattern = "[<>%]"
        
        // Helper closures
        func matches(_ text: String, pattern: String) -> Bool {
            return text.range(of: pattern, options: .regularExpression) != nil
        }
        
        // 1. Name validation
        if name.isEmpty {
            showAlert("Name cannot be empty")
            txtName.becomeFirstResponder()
            return
        } else if matches(name, pattern: invalidCharPattern) {
            showAlert("Special characters are not allowed in name (like <, >, %)")
            txtName.becomeFirstResponder()
            return
        }
        
        // 2. Email validation
        if email.isEmpty {
            showAlert("Email cannot be empty")
            txtEmail.becomeFirstResponder()
            return
        } else if matches(email, pattern: invalidCharPattern) {
            showAlert("Special characters are not allowed in email (like <, >, %)")
            txtEmail.becomeFirstResponder()
            return
        } else if !matches(email, pattern: emailPattern) {
            showAlert("Invalid email format")
            txtEmail.becomeFirstResponder()
            return
        }
        
        // 3. Phone validation
        if phone.isEmpty {
            showAlert("Mobile number cannot be empty")
            txtPhone.becomeFirstResponder()
            return
        } else if !matches(phone, pattern: mobilePattern) {
            showAlert("Enter a valid 10-digit mobile number")
            txtPhone.becomeFirstResponder()
            return
        }
        
        // 4. Remarks validation
        if remark.isEmpty {
            showAlert("Comment cannot be empty")
            txtViewRmark.becomeFirstResponder()
            return
        } else if matches(remark, pattern: invalidCharPattern) {
            showAlert("Special characters are not allowed in comments (like <, >, %)")
            txtViewRmark.becomeFirstResponder()
            return
        }
        
        
        var feedback = FeedbackSubRequest(
            name: name,
            mobno: phone,
            email: email,
            comments: remark
        )
        
        do {
            let jsonData = try JSONEncoder().encode(feedback)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              //  print("JSON String: \(jsonString)")
                // All validations passed
                submitFeedback(feedbackData: jsonString)
            }
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
        }
        
    }
    
    // Email validation helper
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//MARK: - Textview Delegates
extension FeedbackVC : UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if txtViewRmark.text == ""{
            self.lblFeedback.isHidden = false
            
        }else{
            self.lblFeedback.isHidden = true
        }
        
        return true
    }
}

//MARK: - SUBMIT FEEDBACK API

extension FeedbackVC {
    
    func submitFeedback(feedbackData:String) {
        // Example Usage: Encrypting data and storing it
        let prefs = UserDefaults.standard
        
        if prefs.string(forKey: "deviceId") == nil {
            // 1. Get unique app ID (Correct)
            let uniqueAppId = EncryptionUtility.getUniqueAppId()
            
            // 2. Generate a key using unique app ID (Correct)
            let derivedKeyHex = EncryptionUtility.generateKey(appId: uniqueAppId)
            
            // 3. RSA encrypt the derived key (Correct)
            let rsaEncryptedKey = EncryptionUtility.rsaEncrypt(text: derivedKeyHex!)
            
            // 4. AES encrypt the device ID using the derived key
            let encryptedDeviceId = EncryptionUtility.encrypt(plainText: uniqueAppId, password: derivedKeyHex!)
            
            // 5. Model Name
            let modelName = EncryptionUtility.deviceModelName()
            
            //6. Get Encrypted feedbackdata.
            let encryptedFeedbackData = EncryptionUtility.encrypt(plainText: feedbackData, password: derivedKeyHex!)
            
            let params: NSDictionary = [
                "deviceId": KeychainService.getDeviceId() as String? ?? "",
                "data":encryptedFeedbackData ?? "",
            ]
            
            // Provide the desired order manually:
            let orderedKeys = ["deviceId", "data"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            let salt = UserDefaults.standard.string(forKey: "ivKey") ?? ""
            
            submitFeedbackAPI(params: params, checkSum: checkSum)
            //print(params)
        }
        
        
        func submitFeedbackAPI(params: NSDictionary, checkSum: String = "")  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.submitFeedbackAPI(params: params, checkSum: checkSum, success: { (response, status) in
               // print("API response:\n", response)
                
                //Model Converter into Json Str
                if let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                   // print(str)
                }
                
                // 1. Convert response dictionary to JSON Data
                guard let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
                    print("Failed to serialize response")
                    return
                }
                
                // 2. Decode into IndicatorListResponse model
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(FeedbackResponse.self, from: jsonData)
                    
                   // print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let model = model as? FeedbackResponse, model.statusCode == "00" {
                            // Show toast
                            self.showToast(message: model.message ?? "")
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else if status == StatusType.TokenExpired {
                        AppNotification.showErrorMessage("Error!")
                    } else {
                        AppNotification.showErrorMessage(getErrorMessage(from: response))
                    }
                    
                } catch {
                    print("Decoding error:", error.localizedDescription)
                    AppNotification.showErrorMessage("Failed to decode response")
                }
                
            }) { (error, status) in
                if status == StatusType.TokenExpired {
                    showSessionExpiredAlert(vc: self)
                } else {
                    print("API error:", error)
                    AppNotification.showErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    func showToast(message: String, duration: Double = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        if let window = UIApplication.shared.windows.first {
            toastLabel.frame = CGRect(x: 20, y: window.frame.height - 100, width: window.frame.width - 40, height: 35)
            window.addSubview(toastLabel)
            UIView.animate(withDuration: 0.5, animations: {
                toastLabel.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                    toastLabel.alpha = 0.0
                }) { _ in
                    toastLabel.removeFromSuperview()
                }
            }
        }
    }
}
