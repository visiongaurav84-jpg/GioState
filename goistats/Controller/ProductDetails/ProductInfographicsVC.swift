//
//  InfographicsVC.swift
//  goistats
//
//  Created by getitrent on 31/07/25.
//

import UIKit

class ProductInfographicsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tblInfographics: UITableView!{
        didSet{
            tblInfographics.register(UINib(nibName: "InfographicsTVC", bundle: nil), forCellReuseIdentifier: "InfographicsTVC")        }
    }
    
    //MARK: - variables....
    var currentIndex = 0
    var pageCount:Int?
    var infoList : [InfoGraphicsListResponse] = []
    var productName:String?
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    // MARK: - Setup Method
    func setUp() {
        Constant.currentView = "3"
        self.pageCount = 1
        self.getInfographics()
    }
    
    // MARK: - Navigation
    static func getInstance() -> ProductVC {
        return MainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! ProductVC
    }
}


// MARK: - UITable DataSource & Delegate
extension ProductInfographicsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfographicsTVC", for: indexPath) as! InfographicsTVC
        let item = infoList[indexPath.row]
        cell.configure(with: item, presentingViewController: self)
        
        if infoList.count-1 == indexPath.row{
            self.pageCount = self.pageCount!+1
            self.getInfographics()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "InfographicsDetailsVC") as! InfographicsDetailsVC
        vc.infoGraphicID = String(self.infoList[indexPath.row].id ?? 0)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProductInfographicsVC {
    
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
                "opt" : "",
                "pageNum" : String(format: "%d", self.pageCount!),
                "product_name" : String(self.productName ?? "")
                
            ]
            
            // Provide the desired order manually:
            let orderedKeys = ["deviceId","opt","pageNum","product_name"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            let salt = UserDefaults.standard.string(forKey: "ivKey") ?? ""
            
            getInfographicsAPI(params: params)
        }
        
        
        func getInfographicsAPI(params: NSDictionary)  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.infographicsAPI(params: params, checkSum: "", success: { (response, status) in
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
                    let model = try decoder.decode(InfoGraphicsResponse.self, from: jsonData)
                    
                    //print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let infoList = model.infoList {
                            self.infoList.append(contentsOf: infoList)
                            self.tblInfographics.reloadData()
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
}

