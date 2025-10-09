//
//  VisualizationVC.swift
//  goistats
//
//  Created by getitrent on 31/07/25.
//

import UIKit
import DropDown
import DGCharts

protocol updateMapVisualizationDelegate {
    func updateVisualization(year:String, sectorKey:String, sectorValue:String, imputationKey:String, imputationValue:String)
}

class MapVisualizationVC: UIViewController, updateMapDataDelegate {
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var imgResetMap: UIImageView!
    @IBOutlet weak var imgBottomMap: UIImageView!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var viewScreenShot: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblIndicatorName: UILabel!
    @IBOutlet weak var btnSector: UIButton!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var imgSector: UIImageView!
    @IBOutlet weak var imgYear: UIImageView!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblGeography: UILabel!
    @IBOutlet weak var lblFrequency: UILabel!
    @IBOutlet weak var lblTimePeriod: UILabel!
    @IBOutlet weak var lblDataSource: UILabel!
    @IBOutlet weak var lblLastUpdatedData: UILabel!
    @IBOutlet weak var lblFutureRelease: UILabel!
    @IBOutlet weak var lblBasePeriod: UILabel!
    @IBOutlet weak var lblKeyStatics: UILabel!
    @IBOutlet weak var lblRemark: UILabel!
    @IBOutlet weak var lblNmds: UILabel!
    @IBOutlet weak var lblForFurtherDetails: UILabel!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var txtSector: UITextField!
    @IBOutlet weak var txtYear: UITextField!
    @IBOutlet weak var mapView: IndiaMapView!
    @IBOutlet weak var btnImputation: UIButton!
    @IBOutlet weak var imgImputation: UIImageView!
    @IBOutlet weak var txtImputation: UITextField!
    
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
    
    var nmsLinkUrl: String = ""
    var esLinkUrl: String = ""
    var visualizationUpdate: updateMapVisualizationDelegate?

    //This is only use for First Time....
    var yearCheck: String = "first"
    var sectorCheck: String = "first"
    var imputationCheck: String = "first"
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //Get Product data from the server.
       self.getProductDetails()
    }
    
    static func getInstance() -> MapVisualizationVC{
        return MainStoryboard.instantiateViewController(withIdentifier: "MapVisualizationVC") as! MapVisualizationVC
    }
    
    
    //MARK: - Action Methods...
    @IBAction func resetMapClicked(_ sender: Any) {
        mapView.resetZoom()
    }
    
    
    @IBAction func yearClicked(_ sender: Any) {
        
        CustomMethods.openDropDownss(dropDown: dropDown, array: dropDownYearArr, leading: 10, anchor: self.txtYear) { (dropDown) in
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
               // print("Selected item: \(item) at index: \(index)")
                self.txtYear.text = item
                self.yearValue = item
                
                self.visualizationUpdate?.updateVisualization(year: self.yearValue, sectorKey: self.sectorKey,sectorValue: self.sectorValue,imputationKey: self.imputationKey,imputationValue: self.imputationValue)
                
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
                
                self.visualizationUpdate?.updateVisualization(year: self.yearValue, sectorKey: self.sectorKey,sectorValue: self.sectorValue,imputationKey: self.imputationKey,imputationValue: self.imputationValue)
                
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
                
                self.visualizationUpdate?.updateVisualization(year: self.yearValue, sectorKey: self.sectorKey,sectorValue: self.sectorValue,imputationKey: self.imputationKey,imputationValue: self.imputationValue)
                
                self.getProductDetails()
            }
        }
    }
    
    func updateData(year:String, sectorKey: String, sectorValue: String, imputationKey: String, imputationValue: String ) {
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
    
    @IBAction func nmdsClicked(_ sender: Any) {
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "pdf"
        vc.pdfURL = nmsLinkUrl
        vc.headerTitle = "Metadata"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func esClicked(_ sender: Any) {
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "web"
        vc.pdfURL = esLinkUrl
        vc.headerTitle = "eSankhyiki Portal"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func downloadClicked(_ sender: Any) {
        //Create the UIImage
        UIGraphicsBeginImageContext(self.viewScreenShot.frame.size)
        self.viewScreenShot.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        saveUIimageInPhoto(finalImage: image, presentingViewController: self)
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        //Create the UIImage
        UIGraphicsBeginImageContext(self.viewScreenShot.frame.size)
        self.viewScreenShot.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        shareUIImage(image, presentingViewController: self)
    }
    
    
    let stateToCode: [String: String] = [
        "IN-AN": "Andaman & Nicobar Islands",
        "IN-AP": "Andhra Pradesh",
        "IN-AR": "Arunachal Pradesh",
        "IN-AS": "Assam",
        "IN-BR": "Bihar",
        "IN-CH": "Chandigarh",
        "IN-CT": "Chhattisgarh",
        "IN-DN": "Dadra & Nagar Haveli and Daman & Diu",
        "IN-DD": "Dadra & Nagar Haveli and Daman & Diu",
        "IN-DL": "Delhi",
        "IN-GA": "Goa",
        "IN-GJ": "Gujarat",
        "IN-HR": "Haryana",
        "IN-HP": "Himachal Pradesh",
        "IN-JK": "Jammu & Kashmir",
        "IN-JH": "Jharkhand",
        "IN-KA": "Karnataka",
        "IN-KL": "Kerala",
        "IN-LA": "Ladakh",
        "IN-LD": "Lakshadweep",
        "IN-MP": "Madhya Pradesh",
        "IN-MH": "Maharashtra",
        "IN-MN": "Manipur",
        "IN-ML": "Meghalaya",
        "IN-MZ": "Mizoram",
        "IN-NL": "Nagaland",
        "IN-OR": "Odisha",
        "IN-PY": "Puducherry",
        "IN-PB": "Punjab",
        "IN-RJ": "Rajasthan",
        "IN-SK": "Sikkim",
        "IN-TN": "Tamil Nadu",
        "IN-TG": "Telangana",
        "IN-TR": "Tripura",
        "IN-UP": "Uttar Pradesh",
        "IN-UT": "Uttarakhand",
        "IN-WB": "West Bengal"
    ]
    
    private func buildStateData(response: [ResponseItem]) -> [String: (Int, String)] {
        var map: [String: (Int, String)] = [:]
        
        for item in response {
            guard let stateName = item.state, let valueStr = item.indicator1Val, let value = Int(valueStr) else { continue }

            // Find ISO code from stateToCode
            if let isoCode = stateToCode.first(where: { $0.value == stateName })?.key {
                map[isoCode] = (value, stateName)
            }
            
            // Special case: Dadra & Nagar Haveli and Daman & Diu
            if stateName == "Dadra & Nagar Haveli and Daman & Diu" {
                map["IN-DD"] = (value, stateName)
                map["IN-DN"] = (value, stateName)
            }
        }
        
        return map
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle == .dark {
            print("Dark Mode")
            // load dark image
            imgBottomMap.image = UIImage(named: "bottom_map_value_dark")
        } else {
            print("Light Mode")
            // load light image
            imgBottomMap.image = UIImage(named: "bottom_map_value")
        }
    }
    
}


extension MapVisualizationVC{
    
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
                            
                            self.imgYear.layer.cornerRadius = 10
                            self.imgYear.clipsToBounds = true
                            self.imgYear.isHidden = self.dropDownYearArr.count != 1
                            self.btnYear.isEnabled = self.dropDownYearArr.count != 1
                            
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
                            
                            
                            //Meta Data Value Set
                            let metaDataDict = productList.first?.metaData
                            
                            self.lblCategory.text = metaDataDict?.category
                            self.lblGeography.text = metaDataDict?.geography
                            self.lblFrequency.text = metaDataDict?.frequency
                            self.lblTimePeriod.text = metaDataDict?.timePeriod
                            self.lblDataSource.text = metaDataDict?.dataSource
                            self.lblAbout.text = metaDataDict?.description
                            self.lblLastUpdatedData.text = metaDataDict?.lastUpdatedDate
                            self.lblFutureRelease.text = metaDataDict?.futureRelease
                            self.lblKeyStatics.text = metaDataDict?.keyStatistics
                            self.lblBasePeriod.text = metaDataDict?.basePeriod
                            self.lblRemark.text = metaDataDict?.remarks
                            self.lblNmds.text = metaDataDict?.nms?.htmlToPlainString()
                            self.lblForFurtherDetails.text = metaDataDict?.eslink
                            
                            
                            if let nms = metaDataDict?.nms, !nms.isEmpty {
                                self.nmsLinkUrl = extractPdfUrlFromHtml(html: nms)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            }
                            
                            if let eslink = metaDataDict?.eslink, !eslink.isEmpty {
                                self.esLinkUrl = eslink
                            }
                            
                            
                            //Update Map Data.
                            if let firstProduct = productList.first {
                                self.mapView.updateStateData(
                                    data: self.buildStateData(response: firstProduct.data?.response ?? []),
                                    dataUnit: firstProduct.unit ?? ""
                                )
                            }
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
                self.scrollView.isHidden = false
                
                
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
}


extension MapVisualizationVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

