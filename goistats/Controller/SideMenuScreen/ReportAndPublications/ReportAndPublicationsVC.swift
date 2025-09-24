//
//  ReportAndPublicationsVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class ReportAndPublicationsVC: UIViewController {
    
    //MARK: - Outlets...
    @IBOutlet weak var tblReport: UITableView!{
        didSet{
            tblReport.register(UINib(nibName: "ReportAndPublicatiosTVC", bundle: nil), forCellReuseIdentifier: "ReportAndPublicatiosTVC")        }
    }
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Variable...
    var reportAndPublicationsArr = [ReportData]()
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Custom Methods...
    func setupUI(){
        tblReport.showsVerticalScrollIndicator = false
        tblReport.estimatedRowHeight = 100
        tblReport.rowHeight = UITableView.automaticDimension
        getReportAndPublications()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreDetailsClick(_ sender: Any) {
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "web"
        vc.pdfURL = ApiUrl.mospiWebsiteURL
        vc.headerTitle = "MoSPI Website"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension ReportAndPublicationsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reportAndPublicationsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportAndPublicatiosTVC", for: indexPath) as! ReportAndPublicatiosTVC
        let dict = reportAndPublicationsArr[indexPath.row]
        cell.configure(with: dict)
        cell.toggleExpand = { [weak self] in
            guard let self = self else { return }
            self.reportAndPublicationsArr[indexPath.row].isExpanded?.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.btnView.tag = indexPath.row
        cell.btnView.addTarget(self, action: #selector(ViewTap(_:)), for: .touchUpInside)
        return cell
    }
    
    @IBAction func ViewTap(_ sender : UIButton){
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "pdf"
        vc.pdfURL = reportAndPublicationsArr[sender.tag].documentPath ?? ""
        vc.headerTitle = "Report and Publications"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ReportAndPublicationsVC {
    
    func getReportAndPublications() {
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
            
            getReportAndPublicationsAPI(params: params)
        }
        
        
        func getReportAndPublicationsAPI(params: NSDictionary)  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.reportsListingAPIAPI(params: params, checkSum: "", success: { (response, status) in
                
                //print("API response:\n", response)
                
                //Model Converter into Json Str
                if let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                    //print(str)
                }
                
                // 1. Convert response dictionary to JSON Data
                guard let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
                    print("Failed to serialize response")
                    return
                }
                
                // 2. Decode into IndicatorListResponse model
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(ReportsPublicationsResponse.self, from: jsonData)
                    
                   // print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let arr = model.data {
                            self.reportAndPublicationsArr = arr
                        }
                        self.tblReport.reloadData()
                        
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
