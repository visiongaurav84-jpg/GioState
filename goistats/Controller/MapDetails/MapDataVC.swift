//
//  DataVC.swift
//  goistats
//
//  Created by getitrent on 31/07/25.
//

import UIKit
import DropDown

protocol updateMapDataDelegate {
    func updateData(year:String, sectorKey:String, sectorValue:String, imputationKey:String, imputationValue:String)
}

class MapDataVC: UIViewController, updateMapVisualizationDelegate {

    
    //MARK: - Outlets...
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var viewScreenShot: UIView!
    @IBOutlet weak var viewParentView: UIView!
    @IBOutlet weak var lblIndicatorName: UILabel!
    @IBOutlet weak var btnSector: UIButton!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var btnImputation: UIButton!
    @IBOutlet weak var imgSector: UIImageView!
    @IBOutlet weak var imgYear: UIImageView!
    @IBOutlet weak var imgImputation: UIImageView!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var viewFrequency: UIView!
    @IBOutlet weak var txtSector: UITextField!
    @IBOutlet weak var txtYear: UITextField!
    @IBOutlet weak var txtImputation: UITextField!
    @IBOutlet weak var tblProductDataList: UITableView!{
        didSet{
            tblProductDataList.register(
                UINib(
                    nibName: "MapDataTVC",
                    bundle: nil
                ),
                forCellReuseIdentifier: "MapDataTVC"
            )
        }
    }
    
    //MARK: - Variable
    var productList : [MapList] = []
    var dropDownYearArr = [String]()
    var dropDownSectorArr = [String]()
    var dropDownImputationArr = [String]()
    let dropDown = DropDown()
    var productDict:Product?

    var yearValue: String = ""
    var sectorKey: String = ""
    var sectorValue: String = ""
    var imputationKey: String = ""
    var imputationValue: String = ""
    var indicatorKey: String = ""
    var indicatorValue: String = ""
    
    var eSankhyikiWebsiteURL  =  ""
    var dataUpdate: updateMapDataDelegate?
    
    //This is only use for First Time....
    var yearCheck: String = "first"
    var sectorCheck: String = "first"
    var imputationCheck: String = "first"
    
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getProductDetails()
    }
    
    static func getInstance() -> MapDataVC{
        return MainStoryboard.instantiateViewController(withIdentifier: "MapDataVC") as! MapDataVC
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
    
    @IBAction func yearClicked(_ sender: Any) {
        
        CustomMethods.openDropDownss(dropDown: dropDown, array: dropDownYearArr, leading: 10, anchor: self.txtYear) { (dropDown) in
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                //print("Selected item: \(item) at index: \(index)")
                self.txtYear.text = item
                self.yearValue = item
                
                self.dataUpdate?.updateData(year: self.yearValue, sectorKey: self.sectorKey,sectorValue: self.sectorValue,imputationKey: self.imputationKey,imputationValue: self.imputationValue)
                
                self.getProductDetails()
            }
        }
    }
    
    @IBAction func sectorClicked(_ sender: Any) {
        
        CustomMethods.openDropDownss(dropDown: dropDown, array: dropDownSectorArr, leading: 10, anchor: self.txtSector) { (dropDown) in
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
               // print("Selected item: \(item) at index: \(index)")
                self.txtSector.text = item
                self.sectorKey = item
                
                if let frequency = self.productList.first?.sector {
                    let sortedValues = frequency.sorted { $0.key < $1.key }.map { $0.value }
                    print(sortedValues)
                    if index < sortedValues.count {
                        self.sectorValue = sortedValues[index]
                    }
                }
                
                self.dataUpdate?.updateData(year: self.yearValue, sectorKey: self.sectorKey,sectorValue: self.sectorValue,imputationKey: self.imputationKey,imputationValue: self.imputationValue)
                
                self.getProductDetails()
            }
        }
    }
    
    @IBAction func imputationClicked(_ sender: Any) {
        
        CustomMethods.openDropDownss(dropDown: dropDown, array: dropDownImputationArr, leading: 10, anchor: self.txtImputation) { (dropDown) in
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
               // print("Selected item: \(item) at index: \(index)")
                self.txtImputation.text = item
                self.imputationKey = item
                
                if let imputation = self.productList.first?.imputation {
                    let sortedValues = imputation.sorted { $0.key < $1.key }.map { $0.value }
                    print(sortedValues)
                    if index < sortedValues.count {
                        self.imputationValue = sortedValues[index]
                    }
                }
                
                self.dataUpdate?.updateData(year: self.yearValue, sectorKey: self.sectorKey,sectorValue: self.sectorValue,imputationKey: self.imputationKey,imputationValue: self.imputationValue)
                
                self.getProductDetails()
            }
        }
    }
    
    func updateVisualization(year:String, sectorKey: String, sectorValue: String, imputationKey: String, imputationValue: String ) {
        self.txtYear.text = year
        self.yearValue = year
        self.txtSector.text = sectorKey
        self.sectorKey = sectorKey
        self.sectorValue = sectorValue
        self.txtImputation.text = imputationKey
        self.imputationKey = imputationKey
        self.imputationValue = imputationValue
        
        self.getProductDetails()
    }
    
    
    
    @IBAction func downloadClicked(_ sender: Any) {
        //Create CSV File
        if let fileURL = convertJsonToCsv(productList: productList, selectedItem: self.indicatorKey) {
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
        convertJsonToCsvAndShare(productList: productList, selectedItem: self.indicatorKey)
    }
    
    
}


//MARK: - TableView Methods
extension MapDataVC : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.productList.count>0 ? self.productList[0].data?.response?.count ?? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapDataTVC", for: indexPath) as! MapDataTVC
        if let item = self.productList[0].data?.response?[indexPath.row] {
            cell.configure(with: item)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    
}

extension MapDataVC{
    
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
            
            
            // Get Indicator key value.
            if let indicators = self.productDict?.indicators {
                if !indicators.isEmpty {
                    // Get first entry (any, since Dictionary has no guaranteed order)
                    if let firstEntry = indicators.first {
                        self.indicatorKey = firstEntry.key
                        self.indicatorValue = firstEntry.value
                    }
                } else {
                    self.indicatorKey = indicators["NA"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    self.indicatorValue = indicators["NA"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                }
            }
            
            let params: NSDictionary = [
                "productName": self.productDict?.productName ?? "",
                "deviceId": encryptedDeviceId ?? "",
                "year": (self.yearValue.isEmpty == false ? self.yearValue : "2023-24"),
                "sector_code": (self.sectorValue.isEmpty == false ? self.sectorValue : "1"),
                "imputation_type": (self.imputationValue.isEmpty == false ? self.imputationValue : "1"),
                "indicatorValue": self.indicatorValue
            ]
            
            print(params)
            
            // Provide the desired order manually:
            let orderedKeys = ["productName","deviceId","year","sector_code","imputation_type","indicatorValue"]
            
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
            
            ApiRequest.mapDetailsAPI(params: params, checkSum: checkSum, success: { (response, status) in
               print("API response:\n", response)
                
                // Pretty print the response JSON
                if let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
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
                    let model = try decoder.decode(MapPageResponse.self, from: jsonData)
                    
                    print("Decoded Response:", model)
                    
                    // Step 6: Use the decoded model
                    if status == StatusType.Success {
                        if let productList = model.productList {
                            self.productList = productList
                            self.lblHeading.text = productList[0].productDescription
                            self.lblIndicatorName.text = productList[0].indicators?.first?.key ?? ""
                            self.setPeroidValue()
                            self.eSankhyikiWebsiteURL = productList[0].metaData?.eslink ?? ""
                           
                            
                            // Year...
                            self.dropDownYearArr.removeAll()
                            self.dropDownYearArr = productList.first?.year ??  []
                            
                            if self.yearCheck == "first"{
                                if !self.dropDownYearArr.isEmpty {
                                    self.txtYear.text = self.dropDownYearArr.first
                                    self.yearValue = self.dropDownYearArr.first ?? ""
                                    self.imgYear.layer.cornerRadius = 10
                                    self.imgYear.clipsToBounds = true
                                    self.imgYear.isHidden = self.dropDownSectorArr.count != 1
                                    self.btnYear.isEnabled = self.dropDownSectorArr.count != 1
                                }
                                self.yearCheck = ""
                            }
                            
                            // Sector...
                            self.dropDownSectorArr = productList.first?.sector?
                                .sorted { $0.key < $1.key }
                                .map { $0.key } ?? []
                            
                            var localFrequencyArr = self.dropDownSectorArr
                            localFrequencyArr = localFrequencyArr.reversed()
                            
                            
                            if self.sectorCheck == "first"{
                                if !self.dropDownSectorArr.isEmpty {
                                    self.txtSector.text = self.dropDownSectorArr.first
                                    self.sectorKey = self.dropDownSectorArr.first ?? ""
                                    self.imgSector.layer.cornerRadius = 10
                                    self.imgSector.clipsToBounds = true
                                    self.imgSector.isHidden = self.dropDownSectorArr.count != 1
                                    self.btnSector.isEnabled = self.dropDownSectorArr.count != 1
                                    
                                }
                                self.sectorCheck = ""
                            }
                            
                            // Imputation...
                            self.dropDownImputationArr = productList.first?.imputation?
                                .sorted { $0.key < $1.key }
                                .map { $0.key } ?? []
                            
                            var localImputationArr = self.dropDownImputationArr
                            localImputationArr = localImputationArr.reversed()
                            
                            
                            if self.imputationCheck == "first"{
                                if !self.dropDownImputationArr.isEmpty {
                                    self.txtImputation.text = localImputationArr.first
                                    self.imputationKey = localImputationArr.first ?? ""
                                    self.imgImputation.layer.cornerRadius = 10
                                    self.imgImputation.clipsToBounds = true
                                    self.imgImputation.isHidden = self.dropDownImputationArr.count != 1
                                    self.btnImputation.isEnabled = self.dropDownImputationArr.count != 1
                                    
                                }
                                self.imputationCheck = ""
                            }
                            
                            //update table data.
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
    
    func setPeroidValue() {
        let aggregateValue = productList[0].productAggregateValue ?? ""
        let valueDate = productList[0].valueDate ?? ""
        self.lblSubHeading.text = aggregateValue
        let subHeading = "(Period: \(valueDate))"
        
        let boldWord = "Period:"
        let attributedString = NSMutableAttributedString(string: subHeading)
        
        if let range = subHeading.range(of: boldWord) {
            let nsRange = NSRange(range, in: subHeading)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: nsRange)
        }
        
        self.lblProduct.attributedText = attributedString
    }
    
    func convertJsonToCsvAndShare(productList: [MapList], selectedItem: String) {
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
    
    func convertJsonToCsv(productList: [MapList], selectedItem: String) -> URL? {
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
            let header = ["State/U.T.", "Value", "Unit"]
            csvText.append(header.joined(separator: ",") + "\n")
            
            // Data rows
            productList[0].data?.response?.forEach { map in
                let value = Double(map.indicator1Val ?? "") ?? 0.0
                let period = map.state!
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
