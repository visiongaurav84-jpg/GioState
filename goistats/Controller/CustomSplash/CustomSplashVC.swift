//
//  CustomSplashVC.swift
//  goistats
//
//  Created by getitrent on 30/07/25.
//

import UIKit

class CustomSplashVC: UIViewController {
    var didCheckAlready = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didCheckAlready {
            didCheckAlready = true
            checkFreshInstallAndClearKeychainIfNeeded()
            checkAndProceed()
        }
    }
    
    
    //MARK: - Custom Methods
    static func getInstance() -> CustomSplashVC{
        return MainStoryboard.instantiateViewController(withIdentifier: "CustomSplashVC") as! CustomSplashVC
    }
    
    
    //MARK: - AUTH HANDSHAKE
    func authHandshake() {
        // Example Usage: Encrypting data and storing it
        let deviceId = KeychainService.getDeviceId() as String?
        let rsaKey = KeychainService.getRSA() as String?
        
        if deviceId == nil || rsaKey == nil {
            // 1. Get unique app ID (Correct)
            let uniqueAppId = EncryptionUtility.getUniqueAppId()
            
            // 2. Generate a key using unique app ID (Correct)
            let derivedKeyHex = EncryptionUtility.generateKey(appId: uniqueAppId)
            
            // 3. RSA encrypt the derived key (Correct)
            let rsaEncryptedKey = EncryptionUtility.rsaEncrypt(text: derivedKeyHex!)
            
            // 4. AES encrypt the device ID using the derived key
            let encryptedDeviceId = EncryptionUtility.encrypt(plainText: uniqueAppId, password: derivedKeyHex!)
            
            // 5. Save DeviceId to Key Chain Access.
            KeychainService.saveDeviceId(deviceId: encryptedDeviceId! as NSString)
            
            // 6. Save RSA key to Key Chain Access.
            KeychainService.saveRSA(rsa: rsaEncryptedKey! as NSString)
        }
        
        // Get Phone MOdel Name
        let modelName = EncryptionUtility.deviceModelName()
        
        let params: NSDictionary = [
            "deviceId": KeychainService.getDeviceId() as String? ?? "",
            "keyText": KeychainService.getRSA() as String? ?? "",
            "make": "Apple",
            "model": modelName,
            "platform": "iOS"
        ]
        
       // print(params)
        
        // Provide the desired order manually:
        let orderedKeys = ["deviceId", "keyText", "make", "model", "platform"]
        
        let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
        let checkSum = EncryptionUtility.sha256Checksum(json!)
        
        authHandShakeAPI(params: params, checkSum: checkSum)
        
        
        func authHandShakeAPI(params: NSDictionary, checkSum:String)  {
            if !isConnectedToNetwork(){
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            
            ApiRequest.authHandShakeAPI(params: params, checkSum: checkSum, success: { (response, status) in
                //print("API response : \n", response)
                //Model Converter into Json Str
                if let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                   // print(str)
                }
                guard let dict = ModelAuthHandShake(dictionary: response)else{
                    return
                }
                if status == StatusType.Success{
                    let app_version = dict.app_Update?.app_version_ios
                    let app_url = dict.app_Update?.download_url
                    
                    
                    let info = Bundle.main.infoDictionary
                    let currentVersion = info?["CFBundleShortVersionString"] as? String ?? ""
                    
                    
                    //Pls Change the app Store URL
                    if app_version ?? "" > currentVersion {
                        let refreshAlert = UIAlertController(title: "Alert", message: "New Update Available,  \n Kindly update the app. Thank you!", preferredStyle: UIAlertController.Style.alert)
                        refreshAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action: UIAlertAction!) in
                            //print("Handle Ok Logic here")
                            if let url = URL(string: app_url ?? "") {
                                UIApplication.shared.open(url)
                            }
                        }))
                        self.present(refreshAlert, animated: true, completion: nil)
                    }else{
                        AppDelegate.shared.setupRootVC()
                    }
                    
                }
                else if status == StatusType.TokenExpired{
                    AppNotification.showErrorMessage("Invalid login credentials!")
                }
                else{
                    AppNotification.showErrorMessage(getErrorMessage(from: response))
                }
                
            }) { (error, status) in
                if status == StatusType.TokenExpired{
                    showSessionExpiredAlert(vc: self)
                }
                else{
                    print("API error : ", error)
                    AppNotification.showErrorMessage(error.localizedDescription)
                }
            }
        }
        
        
    }
    
    func checkAndProceed() {
        if isConnectedToNetwork() {
            authHandshake()
        } else {
            if let deviceId = KeychainService.getDeviceId() as String?, !deviceId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                AppDelegate.shared.setupRootVC()
            } else {
                showRetryPopup()
            }
        }
    }
    
    
    func showRetryPopup() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "No Internet",
                message: "Please check your internet connection and try again.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                self.checkAndProceed()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // Check if already presenting something
            if self.presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func checkFreshInstallAndClearKeychainIfNeeded() {
        let hasLaunchedKey = "hasLaunchedBefore"
        let defaults = UserDefaults.standard
        
        if !defaults.bool(forKey: hasLaunchedKey) {
            // Fresh install detected
            //print("Fresh install detected. Clearing keychain.")
            KeychainService.deleteDeviceId()
            KeychainService.deleteIV()
            KeychainService.deleteRSA()
            
            // Mark as launched
            defaults.set(true, forKey: hasLaunchedKey)
            defaults.synchronize()
        }
    }
    
}
