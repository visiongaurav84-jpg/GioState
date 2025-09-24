//
//  HomeVC.swift
//  SII
//
//  Created by Admin on 28/01/25.
//

import UIKit
import DropDown

class TabBarVC: UIViewController {
    
    //MARK: - Ibbullet
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewHome: UIView!
    @IBOutlet weak var imgHome: UIImageView!
    @IBOutlet weak var lblHomeTitle: UILabel!
    @IBOutlet weak var viewProduct: UIView!
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var viewInfographics: UIView!
    @IBOutlet weak var imgInfographics: UIImageView!
    @IBOutlet weak var lblInfographicsTitle: UILabel!
    @IBOutlet var contentView: UIView!
    
    //MARK: - variable
    let dropDown = DropDown()
    
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblCount.isHidden = true
        getNotificationCount()
        
        self.lblCount.layer.cornerRadius = 11
        self.lblCount.clipsToBounds = true
        
        self.viewHome.backgroundColor = .white
        self.lblHomeTitle.textColor = UIColor.black
        self.imgHome.setImageColor(color: .black)
        
        self.viewProduct.backgroundColor = .clear
        self.lblProductTitle.textColor = UIColor.white
        self.imgProduct.setImageColor(color: .white)
        
        self.viewInfographics.backgroundColor = .clear
        self.lblInfographicsTitle.textColor = UIColor.white
        self.imgInfographics.setImageColor(color: .white)
        
        guard let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeVC") as? HomeVC else { return }
        // Properly add HomeVC as a child ViewController
        addChild(home)
        // Set frame to match contentView
        home.view.frame = contentView.bounds
        contentView.addSubview(home.view)
        // Notify HomeVC that it moved to a parent
        home.didMove(toParent: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    //MARK: - Custom Methods
    static func getInstance() -> TabBarVC{
        return MainStoryboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
    }
    
    @IBAction func sideMeanuClicked(_ sender: Any) {
        if !isConnectedToNetwork() {
            AppNotification.showErrorMessage(AppMessages.InternetError)
            return
        }
        panel?.openLeft(animated: true)
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func notificationClicked(_ sender: Any) {
        if !isConnectedToNetwork() {
            AppNotification.showErrorMessage(AppMessages.InternetError)
            return
        }
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tabBarClicked(_ sender: UIButton) {
        if(sender.tag == 1){
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            guard let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProductVC") as? ProductVC else { return }
            addChild(home)
            home.view.frame = contentView.bounds
            contentView.addSubview(home.view)
            home.didMove(toParent: self)
            
            self.viewHome.backgroundColor = .clear
            self.lblHomeTitle.textColor = UIColor.white
            self.imgHome.setImageColor(color: .white)
            
            self.viewProduct.backgroundColor = .white
            self.lblProductTitle.textColor = UIColor.black
            self.imgProduct.setImageColor(color: .black)
            
            self.viewInfographics.backgroundColor = .clear
            self.lblInfographicsTitle.textColor = UIColor.white
            self.imgInfographics.setImageColor(color: .white)
            
            self.viewSearch.isHidden = false
            
        }else if(sender.tag == 2){
            guard let home = self.storyboard?.instantiateViewController(identifier: "HomeVC") as? HomeVC else { return }
            addChild(home)
            home.view.frame = contentView.bounds
            contentView.addSubview(home.view)
            home.didMove(toParent: self)
            
            self.viewHome.backgroundColor = .white
            self.lblHomeTitle.textColor = UIColor.black
            self.imgHome.setImageColor(color: .black)
            
            self.viewProduct.backgroundColor = .clear
            self.lblProductTitle.textColor = UIColor.white
            self.imgProduct.setImageColor(color: .white)
            
            self.viewInfographics.backgroundColor = .clear
            self.lblInfographicsTitle.textColor = UIColor.white
            self.imgInfographics.setImageColor(color: .white)
            
            self.viewSearch.isHidden = true
            
        }else if(sender.tag == 3){
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            guard let home = self.storyboard?.instantiateViewController(identifier: "InfographicsVC") as? InfographicsVC else { return }
            addChild(home)
            home.view.frame = contentView.bounds
            contentView.addSubview(home.view)
            home.didMove(toParent: self)
            
            self.viewHome.backgroundColor = .clear
            self.lblHomeTitle.textColor = UIColor.white
            self.imgHome.setImageColor(color: .white)
            
            self.viewProduct.backgroundColor = .clear
            self.lblProductTitle.textColor = UIColor.white
            self.imgProduct.setImageColor(color: .white)
            
            self.viewInfographics.backgroundColor = .white
            self.lblInfographicsTitle.textColor = UIColor.black
            self.imgInfographics.setImageColor(color: .black)
            
            self.viewSearch.isHidden = true
            
            
        }
        
    }
    
    
}

extension TabBarVC {
    
    func getNotificationCount() {
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
                "batchId": "",
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
                //AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.getNotificationAPI(params: params, checkSum: checkSum, success: { (response, status) in
              //  print("API response:\n", response)
                
                //Model Converter into Json Str
                if let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
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
                    
                    print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let arr = model.data {
                            if arr.count > 0 {
                                self.lblCount.text = String(arr.count)
                                self.lblCount.isHidden = false
                            }else{
                                self.lblCount.isHidden = true
                            }
                            //self.notificationsArr = arr
                        }
                        //self.tblNotification.reloadData()
                        
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
