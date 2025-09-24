//
//  NotificationVC.swift
//  goistats
//
//  Created by getitrent on 18/07/25.
//

import UIKit
import Lottie

class NotificationVC: UIViewController {
    
    //MARK: - Outlets...
    @IBOutlet weak var tblNotification: UITableView!{
        didSet{
            tblNotification.register(UINib(nibName: "NotificationTVC", bundle: nil), forCellReuseIdentifier: "NotificationTVC")        }
    }
    
    @IBOutlet weak var viewDelete: UIView!
    @IBOutlet weak var viewMainAnimation: UIView!
    @IBOutlet weak var viewLottie: LottieAnimationView!
    
    //MARK: - Variables
    var notificationsArr: [NotificationItem] = []
    var batchId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDelete.isHidden = true
        viewMainAnimation.isHidden = true
        setLottieAnimation()
        getNotification()
        
    }
    
    
    @IBAction func backClicked(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
        AppDelegate.shared.setupRootVC()
    }
    
    @IBAction func deleteClick(_ sender: Any) {
        if (notificationsArr.count>0) {
            batchId = notificationsArr[0].batchId ?? ""
        } else {
            batchId =  ""
        }
        
        notificationsArr = []
        self.tblNotification.reloadData()
        getNotification()
    }
    
    
    func setLottieAnimation() {
        // Load animation from bundle
        viewLottie.animation = LottieAnimation.named("notification")
        
        // Configure
        viewLottie.loopMode = .loop
        viewLottie.contentMode = .scaleAspectFit
        
        // Play
        viewLottie.play()
    }
    
}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC", for: indexPath) as! NotificationTVC
        let notification = notificationsArr[indexPath.row]
        cell.configure(with: notification)
        return cell
    }
    
}


extension NotificationVC {
    
    func getNotification() {
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
                "batchId": batchId,
            ]
            
            // Provide the desired order manually:
            let orderedKeys = ["deviceId", "batchId"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            let salt = UserDefaults.standard.string(forKey: "ivKey") ?? ""
            
            getNotificationAPI(params: params, checkSum: checkSum)
        }
        
        
        func getNotificationAPI(params: NSDictionary, checkSum: String = "")  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.getNotificationAPI(params: params, checkSum: checkSum, success: { (response, status) in
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
                    let model = try decoder.decode(NotificationResponse.self, from: jsonData)
                    
                    //print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let arr = model.data {
                            self.notificationsArr = arr
                        }
                        
                        //Hide and show delete button.
                        if (self.notificationsArr.count>0) {
                            self.viewDelete.isHidden = false
                            self.viewMainAnimation.isHidden = true
                        } else {
                            self.viewDelete.isHidden = true
                            self.viewMainAnimation.isHidden = false
                        }
                        
                        self.tblNotification.reloadData()
                        
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
