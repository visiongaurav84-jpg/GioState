//
//  AboutUsVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit
import LZViewPager

class AboutUsVC: UIViewController, LZViewPagerDelegate, LZViewPagerDataSource {
    
    //MARK: - Outlets...
    @IBOutlet weak var viewPager: LZViewPager!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Variable...
    private var subController:[UIViewController] = []
    private var enableSwipeable = true
    var indexValue:Int?
    var currentIndex = 0
    var organogramDetails: OrganogramDetails?
    var divisionArr = [DivisionDetails]()
    
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAboutUs()
    }
    
    //MARK: - Custom Methods...
    @IBAction func buttonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func viewPagerProperty(){
        self.viewPager.delegate = self
        self.viewPager.dataSource = self
        self.viewPager.hostController = self
        
        let vc1 = UIStoryboard(name: "SideMenu", bundle: nil).instantiateViewController(identifier: "OrganogramVC") as! OrganogramVC
        vc1.organogramDetails = self.organogramDetails
        let vc2 = UIStoryboard(name: "SideMenu", bundle: nil).instantiateViewController(identifier: "DivisionsVC") as! DivisionsVC
        vc2.divisionArr = self.divisionArr
        
        vc1.title = "Organogram"
        vc2.title = "Divisions Of MoSPI"
        
        subController = [vc1,vc2]
        
        viewPager.reload()
    }
    
    //MARK: - Delegate Methods...
    func numberOfItems() -> Int {
        return self.subController.count
    }
    
    func controller(at index: Int) -> UIViewController {
        return self.subController[index]
    }
    
    func button(at index: Int) -> UIButton {
        //Customize your button styles here
        let button = UIButton()
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = .clear
        
        button.setTitleColor(UIColor(named: "TextColorOneBlueToYellow"), for: .selected)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        
        if index == self.indexValue {
            button.isSelected = true
        }
        
        return button
    }
    
    func backgroundColorForHeader() -> UIColor {
        return UIColor.clear
    }
    
    func colorForIndicator(at index: Int) -> UIColor{
        return UIColor(named: "TextColorOneBlueToYellow") ?? UIColor.black
    }
    
    func heightForHeader() -> CGFloat{
        return 50
    }
    
    func shouldEnableSwipeable() -> Bool {
        return true
    }
    
    func widthForButton(at index: Int) -> CGFloat {
        return (UIScreen.main.bounds.width/CGFloat(Float(subController.count)))
    }
    
    func widthForIndicator(at index: Int) -> CGFloat{
        return (UIScreen.main.bounds.width/CGFloat(Float(subController.count)))
    }
    
}


extension AboutUsVC {
    
    func getAboutUs() {
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
            ]
            
            // Provide the desired order manually:
            let orderedKeys = ["deviceId"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            let salt = UserDefaults.standard.string(forKey: "ivKey") ?? ""
            
            getAboutUsAPI(params: params)
        }
        
        
        func getAboutUsAPI(params: NSDictionary)  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.aboutUsAPI(params: params, checkSum: "", success: { (response, status) in
                // print("API response:\n", response)
                
                //Model Converter into Json Str
                if let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                    //    print(str)
                }
                
                // 1. Convert response dictionary to JSON Data
                guard let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
                    print("Failed to serialize response")
                    return
                }
                
                // 2. Decode into IndicatorListResponse model
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(MospiAboutUsResponse.self, from: jsonData)
                    
                   // print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let dict = model.organogramDetails {
                            self.organogramDetails = dict
                        }
                        if let arr = model.divisionDetails {
                            self.divisionArr = arr
                        }
                        
                        self.viewPagerProperty()
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

