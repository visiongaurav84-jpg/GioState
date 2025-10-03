//
//  DataVC.swift
//  goistats
//
//  Created by getitrent on 31/07/25.
//

import UIKit
import DropDown

protocol updateProductDataDelegate {
    func updateData(indicatorValue:String, indicatorKey:String, frequencyValue:String, frequencyKey:String)
}

class ProductDataVC: UIViewController, updateProductVisualizationDelegate {
    
    //MARK: - Outlets...
    @IBOutlet weak var viewScreenShot: UIView!
    @IBOutlet weak var viewParentView: UIView!
    @IBOutlet weak var lblIndicatorName: UILabel!
    @IBOutlet weak var btnFrequency: UIButton!
    @IBOutlet weak var btnIndicator: UIButton!
    @IBOutlet weak var imgFrequency: UIImageView!
    @IBOutlet weak var imgIndicator: UIImageView!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var viewFrequency: UIView!
   // @IBOutlet weak var constraintsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var txtFrequency: UITextField!
    @IBOutlet weak var txtIndicator: UITextField!
    @IBOutlet weak var tblProductDataList: UITableView!{
        didSet{
            tblProductDataList.register(UINib(nibName: "ProductDataTVC", bundle: nil), forCellReuseIdentifier: "ProductDataTVC")
        }
    }
    
    //MARK: - Variable
    var productList : [ProductList] = []
    var dropDownIndicatorArr = [String]()
    var dropDownFrequencyArr = [String]()
    let dropDown = DropDown()
    var productDict:Product?
    
    var indicatorValue: String = ""
    var indicatorUpdatedKey: String = ""
    var frequencyValue: String = ""
    var frequencyKey: String = ""
    var eSankhyikiWebsiteURL  =  ""
    
    var dataUpdate: updateProductDataDelegate?
    
    //This is only use for First Time....
    var indicatorKey: String = ""
    var frequencycheck: String = "first"
    
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewParentView.isHidden = true
       // self.constraintsViewHeight.constant = 210
        self.viewFrequency.isHidden = false
        self.tblProductDataList.showsVerticalScrollIndicator = false
        
        
        if let indicators = self.productDict?.indicators,
           let firstEntry = indicators.sorted(by: { $0.key < $1.key }).first {
            indicatorKey = firstEntry.key
            indicatorValue = firstEntry.value
        } else {
            indicatorKey = "NA"
            indicatorValue = self.productDict?.indicators?["NA"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        
        
        self.getProductDetails()
    }
    
    //MARK: - Action Methods...
    
    @IBAction func viewPdfBottomClicked(_ sender: Any) {
        if(!self.eSankhyikiWebsiteURL.isEmpty){
            let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
            vc.type = "web"
            vc.pdfURL = self.eSankhyikiWebsiteURL
            vc.headerTitle = "eSankhyiki Portal"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func indicatorClicked(_ sender: Any) {
        
        CustomMethods.openDropDownss(dropDown: dropDown, array: dropDownIndicatorArr, leading: 10, anchor: self.txtIndicator) { (dropDown) in
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                //print("Selected item: \(item) at index: \(index)")
                self.txtIndicator.text = item
                self.indicatorUpdatedKey = item
                
                self.lblIndicatorName.text = item
                
                if let indicators = self.productList.first?.indicators {
                    let sortedValues = indicators.sorted { $0.key < $1.key }.map { $0.value }
                    print(sortedValues)
                    if index < sortedValues.count {
                        self.indicatorValue = sortedValues[index]
                    }
                }
                self.dataUpdate?.updateData(indicatorValue: self.indicatorValue, indicatorKey: self.indicatorUpdatedKey, frequencyValue:self.frequencyValue, frequencyKey:self.frequencyKey)
                self.getProductDetails()
            }
        }
    }
    
    @IBAction func frequencyClicked(_ sender: Any) {
        
        CustomMethods.openDropDownss(dropDown: dropDown, array: dropDownFrequencyArr, leading: 10, anchor: self.txtFrequency) { (dropDown) in
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
               // print("Selected item: \(item) at index: \(index)")
                self.txtFrequency.text = item
                self.frequencyKey = item
                
                if let frequency = self.productList.first?.frequency {
                    let sortedValues = frequency.sorted { $0.key < $1.key }.map { $0.value }
                    print(sortedValues)
                    if index < sortedValues.count {
                        self.frequencyValue = sortedValues[index]
                    }
                }
                
                self.dataUpdate?.updateData(indicatorValue: self.indicatorValue, indicatorKey: self.indicatorUpdatedKey, frequencyValue:self.frequencyValue, frequencyKey:self.frequencyKey)
                
                self.getProductDetails()
            }
        }
    }
    
    func updateViziulization(indicatorValue: String, indicatorKey: String, frequencyValue: String, frequencyKey: String) {
        
        //print("opopop")
        self.txtIndicator.text = indicatorKey
        self.indicatorUpdatedKey = indicatorKey
        self.lblIndicatorName.text = indicatorKey
        self.indicatorValue = indicatorValue
        
        self.txtFrequency.text = frequencyKey
        self.frequencyValue = frequencyValue
        self.frequencyKey = frequencyKey
        
        self.getProductDetails()
    }
    
    
    
    @IBAction func downloadClicked(_ sender: Any) {
        //Create CSV File
        if let fileURL = convertJsonToCsv(productList: productList, selectedItem: self.indicatorUpdatedKey) {
            //print("CSV saved at: \(fileURL)")
            
            // Optional: Present share sheet
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
        } else {
            print("No data to export")
        }
    }
    
    @IBAction func sharedClicked(_ sender: Any) {
        //Share file
        convertJsonToCsvAndShare(productList: productList, selectedItem: self.indicatorUpdatedKey)
    }
    
    
}


//MARK: - TableView Methods
extension ProductDataVC : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.productList.count>0 ? self.productList[0].data?.response?.count ?? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDataTVC", for: indexPath) as! ProductDataTVC
        if let item = self.productList[0].data?.response?[indexPath.row] {
            cell.configure(with: item)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    
}

extension ProductDataVC{
    
    func getProductDetails() {
        
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
                "productName" : self.productDict?.productName ?? "",
                "indicatorValue" : indicatorValue,
                "deviceId" : encryptedDeviceId!,
                "frequency" : frequencyValue,
            ]
            //print(params)
            
            // Provide the desired order manually:
            let orderedKeys = ["productName","indicatorValue","deviceId","frequency"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            let salt = UserDefaults.standard.string(forKey: "ivKey") ?? ""
            
            getProductDetailsAPI(params: params, checkSum: checkSum)
        }
        
        func getProductDetailsAPI(params: NSDictionary, checkSum: String) {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.productDetailsAPI(params: params, checkSum: checkSum, success: { (response, status) in
               // print("API response:\n", response)
                
                // Pretty print the response JSON
                if let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                    //print(str)
                }
                
                do {
                    // Step 1: Convert to mutable [String: Any]
                    guard var modifiedResponse = response as? [String: Any] else {
                        print("Failed to cast response to [String: Any]")
                        return
                    }
                    
                    // Step 2: Navigate to ProductList[0].Data.Response
                    if var productList = modifiedResponse["ProductList"] as? [[String: Any]],
                       var firstProduct = productList.first,
                       var data = firstProduct["Data"] as? [String: Any],
                       let responseArray = data["Response"] as? [[String: Any]] {
                        
                        // Step 3: Convert all values to String
                        let convertedResponse: [[String: String]] = responseArray.map { dict in
                            var newDict: [String: String] = [:]
                            for (key, value) in dict {
                                newDict[key] = "\(value)"
                            }
                            return newDict
                        }
                        
                        // Step 4: Replace original response with converted one
                        data["Response"] = convertedResponse
                        firstProduct["Data"] = data
                        productList[0] = firstProduct
                        modifiedResponse["ProductList"] = productList
                    }
                    
                    // Step 5: Convert back to JSON
                    let jsonData = try JSONSerialization.data(withJSONObject: modifiedResponse, options: [])
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(ProductPageResponse.self, from: jsonData)
                    
                    //print("Decoded Response:", model)
                    
                    // Step 6: Use the decoded model
                    if status == StatusType.Success {
                        if let productList = model.productList {
                            self.productList = productList
                            
                            self.eSankhyikiWebsiteURL = productList[0].metaData?.eslink ?? ""
                            self.lblHeading.text = productList[0].productDescription
                            self.setPeroidVAlue()
                            
                            // Indicator...
                            self.dropDownIndicatorArr.removeAll()
                            if let indicator = productList[0].indicators {
                                self.dropDownIndicatorArr = productList.first?.indicators?
                                    .sorted { $0.key < $1.key }
                                    .map { $0.key } ?? []
                            }
                            
                            if self.dropDownIndicatorArr.contains(self.indicatorKey), self.indicatorKey != "" {
                                self.txtIndicator.text = self.indicatorKey
                                self.indicatorUpdatedKey = self.indicatorKey
                                self.lblIndicatorName.text = self.indicatorKey
                                
                                if let indicators = self.productList.first?.indicators {
                                    let sortedValues = indicators.sorted { $0.key < $1.key }.map { $0.value }
                                    print(sortedValues)
                                    self.indicatorValue = sortedValues[0]
                                }
                                self.indicatorKey = ""
                            }
                            
                            
                            
                            self.imgIndicator.layer.cornerRadius = 10
                            self.imgIndicator.clipsToBounds = true
                            self.imgIndicator.isHidden = self.dropDownIndicatorArr.count != 1
                            self.btnIndicator.isEnabled = self.dropDownIndicatorArr.count != 1
                            
                            // Frequency...
                            self.dropDownFrequencyArr = productList.first?.frequency?
                                .sorted { $0.key < $1.key }
                                .map { $0.key } ?? []
                            
                            var localFrequencyArr = self.dropDownFrequencyArr
                            localFrequencyArr = localFrequencyArr.reversed()
                            
                            
                            if self.frequencycheck == "first"{
                                if !self.dropDownFrequencyArr.isEmpty {
                                    self.txtFrequency.text = localFrequencyArr.first
                                    self.frequencyKey = localFrequencyArr.first ?? ""
                                    self.imgFrequency.layer.cornerRadius = 10
                                    self.imgFrequency.clipsToBounds = true
                                    self.imgFrequency.isHidden = self.dropDownFrequencyArr.count != 1
                                    self.btnFrequency.isEnabled = self.dropDownFrequencyArr.count != 1
                                    
                                   // self.constraintsViewHeight.constant = 200
                                    self.viewFrequency.isHidden = false
                                } else {
                                   // self.constraintsViewHeight.constant = 175
                                    self.viewFrequency.isHidden = true
                                }
                                self.frequencycheck = ""
                            }
                            
                            
                            
                            self.tblProductDataList.reloadData()
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
                
                //For Hidding the parenet View
                self.viewParentView.isHidden = false
                
                
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
    
    func setPeroidVAlue() {
        let aggregateValue = productList[0].productAggregateValue ?? ""
        let valueDate = productList[0].valueDate ?? ""
        let subHeading = "\(aggregateValue)   (Period: \(valueDate))"
        
        let boldWord = "Period:"
        let attributedString = NSMutableAttributedString(string: subHeading)
        
        if let range = subHeading.range(of: boldWord) {
            let nsRange = NSRange(range, in: subHeading)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: nsRange)
        }
        
        self.lblSubHeading.attributedText = attributedString
    }
    
    func convertJsonToCsvAndShare(productList: [ProductList], selectedItem: String) {
        guard !productList.isEmpty else { return }
        
        if let fileURL = convertJsonToCsv(productList: productList, selectedItem: selectedItem) {
            shareFile(fileURL)
        } else {
            print("No CSV file generated to share")
        }
    }
    
    func shareFile(_ fileURL: URL) {
        DispatchQueue.main.async {
            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = topVC.view // for iPad support
                topVC.present(activityVC, animated: true)
            }
        }
    }
    
    func convertJsonToCsv(productList: [ProductList], selectedItem: String) -> URL? {
        guard !productList.isEmpty else { return nil }
        
        do {
            let fileName = "\(Int(Date().timeIntervalSince1970 * 1000)).csv"
            
            // Save inside the app's Documents directory
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDir.appendingPathComponent(fileName)
            
            var csvText = ""
            
            // Product details
            csvText.append("\(productList[0].productDescription ?? "")\n")
            csvText.append("\(selectedItem)\n")
            csvText.append("\(productList[0].productAggregateValue ?? "")\n")
            csvText.append("Period : \(productList[0].valueDate ?? "")\n\n\n")
            
            // Header
            let header = ["Period", "Value", "Unit"]
            csvText.append(header.joined(separator: ",") + "\n")
            
            // Data rows
            productList[0].data?.response?.forEach { map in
                let value = Double(map["Indicator1_val"] ?? "") ?? 0
                let year = map["financialyear"] ?? map["year"] ?? ""
                let periodPart = map["month"] ?? map["quarterly"] ?? ""
                let period = "\(periodPart) \(year)".trimmingCharacters(in: .whitespaces)
                let unit = productList[0].unit ?? ""
                
                let rowValues = [period, "\(value)", unit]
                csvText.append(rowValues.joined(separator: ",") + "\n")
            }
            
            // Write file
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            
            return fileURL
            
        } catch {
            print("CSV export failed: \(error.localizedDescription)")
            return nil
        }
    }
}
