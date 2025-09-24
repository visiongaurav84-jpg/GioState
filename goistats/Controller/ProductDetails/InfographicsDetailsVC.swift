//
//  InfographicsDetailsVC.swift
//  goistats
//
//  Created by getitrent on 01/08/25.
//

import UIKit

class InfographicsDetailsVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var constraintsKeyTakewayHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintsAboutHeight: NSLayoutConstraint!
    @IBOutlet weak var txtViewKeyTakeaways: UITextView!
    @IBOutlet weak var txtViewAbout: UITextView!
    @IBOutlet weak var imgDetailImage: UIImageView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var constraintImgHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintViewHeight: NSLayoutConstraint!
    
    var infoGraphicID:String?
    var infoList = [InfoList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.isHidden = true
        self.getInfographics()
        self.updateViewCount()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Choose height based on device
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let imageHeight: CGFloat = isIpad ? 900 : 500
        
        if constraintImgHeight.constant != imageHeight {
            constraintImgHeight.constant = imageHeight
            constraintViewHeight.constant = imageHeight
            
        }
    }
    
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func downloadClicked(_ sender: UIButton) {
        saveWebPBase64ToPhotos(base64String: self.infoList[0].image_icon ?? "", presentingViewController: self)
    }
    
    @IBAction func shareClicked(_ sender: UIButton) {
        shareWebPBase64Image(base64String: self.infoList[0].image_icon ?? "", presentingViewController: self)
    }
    
    @IBAction func homeClicked(_ sender: UIButton) {
        AppDelegate.shared.setupRootVC()
    }
    
    @IBAction func zoomClicked(_ sender: UIButton) {
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "ZoomVC") as! ZoomVC
        vc.imgUrlStr = self.infoList[0].image_icon ?? ""
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func setUI() {
        displayWebP(base64String: self.infoList[0].image_icon ?? "", imageView: self.imgDetailImage)
        self.lblHeading.text = self.infoList[0].title
        self.lblViewCount.text = String(self.infoList[0].view_count ?? 0) + " Views"
        
        setHTMLContent(
            html: self.infoList[0].about_infographics ?? "",
            textView: self.txtViewAbout,
            updateHeightConstraint: self.constraintsAboutHeight
        )
        
        let rawHTML = self.infoList[0].key_takeaways ?? ""
        setHTMLContent(
            html: rawHTML,
            textView: self.txtViewKeyTakeaways,
            updateHeightConstraint: self.constraintsKeyTakewayHeight
        )
        //        setHTMLContentForKeyTrendings(html: rawHTML,
        //                                      textView: self.txtViewKeyTakeaways,
        //                                      updateHeightConstraint: self.constraintsKeyTakewayHeight)
        
        self.view.layoutIfNeeded()
        
    }
    
    func convertHTMLListToBullets(_ html: String) -> String {
        var modifiedHTML = html
        // Replace <ol> and <ul> items with bullet characters (•)
        modifiedHTML = modifiedHTML
            .replacingOccurrences(of: "<ol>", with: "")
            .replacingOccurrences(of: "</ol>", with: "")
            .replacingOccurrences(of: "<ul>", with: "")
            .replacingOccurrences(of: "</ul>", with: "")
            .replacingOccurrences(of: "<li>", with: "• ")
            .replacingOccurrences(of: "</li>", with: "<br/>")
        
        return modifiedHTML
    }
    
}


extension InfographicsDetailsVC {
    
    func getInfographics() {
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
            
            let params: NSDictionary = [
                "deviceId": encryptedDeviceId!,
                "id" : self.infoGraphicID ?? "",
            ]
            
            // Provide the desired order manually:
            let orderedKeys = ["deviceId","id"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            
            getInfographicsAPI(params: params, checkSum: checkSum)
        }
        
        
        func getInfographicsAPI(params: NSDictionary, checkSum:String)  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.infographicsDetailsAPI(params: params, checkSum: checkSum, success: { (response, status) in
                //print("API response:\n", response)
                
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
                    let model = try decoder.decode(InfoGraphicsDetails.self, from: jsonData)
                    
                    // print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let infoList = model.infoList {
                            self.infoList.append(contentsOf: infoList)
                            self.setUI()
                            self.scrollView.isHidden = false
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
    
    
    func updateViewCount() {
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
            
            let params: NSDictionary = [
                "deviceId": encryptedDeviceId!,
                "viewId" : self.infoGraphicID ?? "",
            ]
            
            // Provide the desired order manually:
            let orderedKeys = ["deviceId","viewId"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            
            updateViewCountAPI(params: params, checkSum: checkSum)
        }
        
        
        func updateViewCountAPI(params: NSDictionary, checkSum:String)  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.updateViewAPI(params: params, checkSum: checkSum, success: { (response, status) in
                //print("API response:\n", response)
                
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
                    let model = try decoder.decode(InfoGraphicsDetails.self, from: jsonData)
                    
                    // print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        
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
}
