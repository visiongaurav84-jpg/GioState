//
//  ContactUsVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class ContactUsVC: UIViewController {
    
    //MARK: - Outlets...
    @IBOutlet weak var tblContactUs: UITableView!{
        didSet{
            tblContactUs.register(UINib(nibName: "ContactUsHeaderTVC", bundle: nil), forCellReuseIdentifier: "ContactUsHeaderTVC")
            tblContactUs.register(UINib(nibName: "GoIStatsTVC", bundle: nil), forCellReuseIdentifier: "GoIStatsTVC")
            tblContactUs.register(UINib(nibName: "ImportantLiksTVC", bundle: nil), forCellReuseIdentifier: "ImportantLiksTVC")
            tblContactUs.register(UINib(nibName: "SupportAndQueriesTVC", bundle: nil), forCellReuseIdentifier: "SupportAndQueriesTVC")
            tblContactUs.register(UINib(nibName: "InfoTVC", bundle: nil), forCellReuseIdentifier: "InfoTVC")
        }
    }
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Variable...
    var titleName: String = ""
    var footerText: String = ""
    var appDetails: String = ""
    var descriptionStr: String?
    var urlArr = [Urls]()
    var supportQueriesArr = [SupportQueries]()
    
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getContactUs()
    }
    
    //MARK: - Custom Methods...
    func setupUI(){
        self.tblContactUs.isHidden = true
        tblContactUs.showsVerticalScrollIndicator = false
        tblContactUs.sectionHeaderTopPadding = 10
        tblContactUs.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension ContactUsVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return urlArr.count
        }else if section == 2{
            return supportQueriesArr.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoIStatsTVC", for: indexPath) as! GoIStatsTVC
            cell.configure(with: self.descriptionStr ?? "")
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImportantLiksTVC", for: indexPath) as! ImportantLiksTVC
            let dict = self.urlArr[indexPath.row]
            cell.configure(with: dict)
            if indexPath.row == urlArr.count-1{
                cell.viewMain.layer.cornerRadius = 12  // Set your desired radius
                cell.viewMain.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.viewMain.clipsToBounds = true
            }
            
            cell.btnView.tag = indexPath.row
            cell.btnView.addTarget(self, action: #selector(viewPdf(_:)), for: .touchUpInside)
            
            return cell
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportAndQueriesTVC", for: indexPath) as! SupportAndQueriesTVC
            if indexPath.row == supportQueriesArr.count-1{
                cell.contentView.layer.cornerRadius = 12  // Set your desired radius
                cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.contentView.clipsToBounds = true
            }
            let dict = self.supportQueriesArr[indexPath.row]
            cell.configure(with: dict)
            return cell
        }else{
            // let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTVC", for: indexPath) as! InfoTVC
            //             cell.configure(with: self.appDetails)
            //             return cell
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTVC", for: indexPath) as! InfoTVC
            cell.configure(with: self.appDetails)
            cell.onHeightChange = { [weak self] in
                UIView.setAnimationsEnabled(false)
                self?.tblContactUs.beginUpdates()
                self?.tblContactUs.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
            return cell
            
            
            
        }
        
    }
    
    @IBAction func viewPdf(_ sender: UIButton) {
        let dict = self.urlArr[sender.tag]
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "web"
        vc.pdfURL = dict.urlVal ?? ""
        vc.headerTitle = dict.urlKey ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactUsHeaderTVC") as! ContactUsHeaderTVC
        if section == 0{
            cell.configure(with: self.titleName)
        }else if section == 1{
            cell.configure(with: "Important Links")
        }else if section == 2{
            cell.configure(with: "Support & Queries")
        }else if section == 3{
            cell.configure(with: "")
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3{
            return 15
        }else{
            return 30
        }
    }
    
    
}

extension ContactUsVC {
    
    func getContactUs() {
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
            
            getContactUsAPI(params: params)
        }
        
        
        func getContactUsAPI(params: NSDictionary)  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.contactUsAPI(params: params, checkSum: "", success: { (response, status) in
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
                    let model = try decoder.decode(ContactUsResponse.self, from: jsonData)
                    
                    //print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        self.tblContactUs.isHidden = false
                        self.titleName = model.appDetails?.appName ?? ""
                        self.descriptionStr = model.appDetails?.appDescription ?? ""
                        self.urlArr = model.urls ?? []
                        self.supportQueriesArr = model.supportQueries ?? []
                        self.appDetails = model.appDetails?.webManager ?? ""
                        self.tblContactUs.reloadData()
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
