//
//  AdvanceReleaseCalenderVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class AdvanceReleaseCalenderVC: UIViewController {
    
    //MARK: - Outlets...
    @IBOutlet weak var tblAdvanceRelease: UITableView!{
        didSet{
            tblAdvanceRelease.register(UINib(nibName: "AdvanceReleaseCalenderTVC", bundle: nil), forCellReuseIdentifier: "AdvanceReleaseCalenderTVC")
            tblAdvanceRelease.register(UINib(nibName: "AdvanceReleaseCalenderHeaderTVC", bundle: nil), forCellReuseIdentifier: "AdvanceReleaseCalenderHeaderTVC")
            tblAdvanceRelease.register(UINib(nibName: "AdvanceReleseFooterTVC", bundle: nil), forCellReuseIdentifier: "AdvanceReleseFooterTVC")
        }
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var viewHeader: UIView!
    
    //MARK: - Variable...
    var releaseListArr = [ReleaseList]()
    var footerData: String?
    
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Custom Methods...
    func setupUI(){
        self.viewHeader.layer.cornerRadius = 10
        self.viewHeader.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.viewHeader.clipsToBounds = true
        tblAdvanceRelease.showsVerticalScrollIndicator = false
        
        // Remove top padding above section header for iOS 15+
        if #available(iOS 15.0, *) {
            tblAdvanceRelease.sectionHeaderTopPadding = 0
        }
        tblAdvanceRelease.rowHeight = UITableView.automaticDimension
        
        getAdvanceReleaseCalender()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension AdvanceReleaseCalenderVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.releaseListArr.count+1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.releaseListArr.count>section{
            return   self.releaseListArr[section].data?.count ?? 0
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdvanceReleaseCalenderTVC", for: indexPath) as! AdvanceReleaseCalenderTVC
        let report = releaseListArr[indexPath.section].data?[indexPath.row]
        if let report = report {
            cell.configure(with: report)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.releaseListArr.count>section{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvanceReleaseCalenderHeaderTVC") as! AdvanceReleaseCalenderHeaderTVC
            let report = releaseListArr[section].month
            if let report = report {
                cell.configure(with: report)
            }
            return cell.contentView
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvanceReleseFooterTVC") as! AdvanceReleseFooterTVC
            cell.configure(with: self.footerData ?? "")
            return cell.contentView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.releaseListArr.count>section{
            return 50
        } else {
            return UITableView.automaticDimension
        }
    }}


extension AdvanceReleaseCalenderVC {
    
    func getAdvanceReleaseCalender() {
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
            
            getAdvanceReleaseCalenderAPI(params: params)
        }
        
        
        func getAdvanceReleaseCalenderAPI(params: NSDictionary)  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.advanceReleaseAPI(params: params, checkSum: "", success: { (response, status) in
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
                    let model = try decoder.decode(ReleaseCalendar.self, from: jsonData)
                    
                   // print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let arr = model.releaseList {
                            self.releaseListArr = arr
                            self.footerData = model.footer
                           // print(self.footerData)
                        }
                        self.tblAdvanceRelease.reloadData()
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

