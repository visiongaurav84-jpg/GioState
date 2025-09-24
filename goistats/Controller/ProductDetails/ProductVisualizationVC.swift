//
//  VisualizationVC.swift
//  goistats
//
//  Created by getitrent on 31/07/25.
//

import UIKit
import DropDown
import DGCharts

protocol updateProductVisualizationDelegate {
    func updateViziulization(indicatorValue:String, indicatorKey:String, frequencyValue:String, frequencyKey:String)
}

class ProductVisualizationVC: UIViewController, updateProductDataDelegate {
    
    
    //MARK: - Outlets
    @IBOutlet weak var viewScreenShot: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblHorizentalChart: UILabel!
    @IBOutlet weak var lblIndicatorName: UILabel!
    @IBOutlet weak var btnFrequency: UIButton!
    @IBOutlet weak var btnIndicator: UIButton!
    @IBOutlet weak var imgFrequecy: UIImageView!
    @IBOutlet weak var imgIndicator: UIImageView!
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
    @IBOutlet weak var viewFrequency: UIView!
    @IBOutlet weak var constraintsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var txtFrequency: UITextField!
    @IBOutlet weak var txtIndicator: UITextField!
    @IBOutlet weak var viewForLineChart: LineChartView!
    
    //MARK: - Variable
    var productList : [ProductList] = []
    var dropDownIndicatorArr = [String]()
    var dropDownFrequencyArr = [String]()
    var dropDownArr = ["A","B"]
    let dropDown = DropDown()
    var productDict:Product?
    
    var indicatorValue: String = ""
    var indicatorUpdatedKey: String = ""
    var frequencyValue: String = ""
    var frequencyKey: String = ""
    
    var vizulizationUpdate: updateProductVisualizationDelegate?
    
    
    //This is only use for First Time....
    var frequencycheck: String = "first"
    var indicatorKey: String = ""
    
    
    var nmsLinkUrl: String = ""
    var esLinkUrl: String = ""
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.isHidden = true
        
        // Enable chart gestures if needed
        viewForLineChart.isUserInteractionEnabled = true
        viewForLineChart.dragEnabled = true
        viewForLineChart.scaleXEnabled = true
        viewForLineChart.scaleYEnabled = true
        
        // Set delegate for chartView's gestures
        for gesture in viewForLineChart.gestureRecognizers ?? [] {
            gesture.delegate = self  // This is safe
        }
        
        self.constraintsViewHeight.constant = 210
        self.viewFrequency.isHidden = false
        self.lblHorizentalChart.transform = CGAffineTransform(rotationAngle: 3 * .pi / 2) // 90 degrees
        
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
    @IBAction func indicatorClicked(_ sender: Any) {
        
        CustomMethods.openDropDownss(dropDown: dropDown, array: dropDownIndicatorArr, leading: 10, anchor: self.txtIndicator) { (dropDown) in
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
               // print("Selected item: \(item) at index: \(index)")
                self.txtIndicator.text = item
                self.indicatorUpdatedKey = item
                
                self.lblIndicatorName.text = item
                self.lblHorizentalChart.text = item + " ("+(productList[0].unit ?? "") + ")"
                
                if let indicators = self.productList.first?.indicators {
                    let sortedValues = indicators.sorted { $0.key < $1.key }.map { $0.value }
                    print(sortedValues)
                    if index < sortedValues.count {
                        self.indicatorValue = sortedValues[index]
                    }
                }
                
                self.vizulizationUpdate?.updateViziulization(indicatorValue: self.indicatorValue, indicatorKey: self.indicatorUpdatedKey, frequencyValue:self.frequencyValue, frequencyKey:self.frequencyKey)
                
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
                
                self.vizulizationUpdate?.updateViziulization(indicatorValue: self.indicatorValue, indicatorKey: self.indicatorUpdatedKey, frequencyValue:self.frequencyValue, frequencyKey:self.frequencyKey)
                
                self.getProductDetails()
            }
        }
    }
    
    func updateData(indicatorValue: String, indicatorKey: String, frequencyValue: String, frequencyKey: String) {
        self.txtIndicator.text = indicatorKey
        self.indicatorUpdatedKey = indicatorKey
        self.lblIndicatorName.text = indicatorKey
        self.lblHorizentalChart.text = indicatorKey + " ("+(productList[0].unit ?? "") + ")"
        self.indicatorValue = indicatorValue
        
        self.txtFrequency.text = frequencyKey
        self.frequencyValue = frequencyValue
        self.frequencyKey = frequencyKey
        
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
    
    //MARK: - Chart Set Up
    func setupChart() {
        let entries = buildEntriesAndLabels().entries
        let labels = buildEntriesAndLabels().labels
        
        let dataSet = createLineDataSet(entries: entries)
        
        let data = LineChartData(dataSet: dataSet)
        viewForLineChart.data = data
        
        configureChartAppearance(labels: labels)
        setupMarker(labels: labels)
        
        // Reset zoom and scaling to default after updating data
        viewForLineChart.fitScreen()
        viewForLineChart.notifyDataSetChanged()
    }
    
    func buildEntriesAndLabels() -> (entries: [ChartDataEntry], labels: [String]) {
        var entries: [ChartDataEntry] = []
        var labels: [String] = []
        
        guard let responseData = self.productList.first?.data?.response else {
            return (entries, labels) // return empty if response is nil
        }
        
        for (index, map) in responseData.enumerated() {
            let value = Double(map["Indicator1_val"] ?? "") ?? 0.0
            let year = map["financialyear"] ?? map["year"] ?? ""
            let monthOrQuarter = map["month"] ?? map["quarterly"] ?? ""
            let label = "\(monthOrQuarter) \(year)".trimmingCharacters(in: .whitespaces)
            
            entries.append(ChartDataEntry(x: Double(index), y: Double(value)))
            labels.append(label)
        }
        
        return (entries, labels)
    }
    
    
    func createLineDataSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries, label: indicatorKey)
        dataSet.colors = [NSUIColor.graphLine]
        dataSet.circleColors = [NSUIColor.graphLine]
        dataSet.circleHoleColor = .graphDot
        dataSet.circleHoleRadius = 2
        dataSet.circleRadius = 3.5
        dataSet.lineWidth = 2.0
        dataSet.drawCirclesEnabled = true
        dataSet.drawValuesEnabled = false
        dataSet.mode = .linear
        return dataSet
    }
    
    func configureChartAppearance(labels: [String]) {
        viewForLineChart.animate(xAxisDuration: 1.8, yAxisDuration: 1.8)
        viewForLineChart.pinchZoomEnabled = true
        viewForLineChart.doubleTapToZoomEnabled = true
        viewForLineChart.setScaleEnabled(true)
        viewForLineChart.legend.enabled = false
        viewForLineChart.chartDescription.enabled = false
        viewForLineChart.rightAxis.enabled = false
        
        
        // X Axis
        let xAxis = viewForLineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        xAxis.labelRotationAngle = -70
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.drawAxisLineEnabled = true
        xAxis.axisLineColor = .graphBottomLine
        xAxis.axisLineWidth = 1.0
        xAxis.granularity = 1
        xAxis.setLabelCount(labels.count, force: true)
        
        // Y Axis
        let yAxis = viewForLineChart.leftAxis
        yAxis.drawAxisLineEnabled = true
        yAxis.axisLineColor = .graphBottomLine
        yAxis.axisLineWidth = 1.0
        yAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, _ in
            return self.formatNumber(Int(value))
        })
        
        viewForLineChart.setExtraOffsets(left: 20, top: 0, right: 0, bottom: 20)
    }
    
    
    func setupMarker(labels: [String]) {
        let marker = CustomMarkerView(
            frame: CGRect(x: 0, y: 0, width: 140, height: 50),
            years: labels,
            chart: viewForLineChart,
            unit: productList[0].unit ?? ""
        )
        viewForLineChart.marker = marker
        marker.chartView = viewForLineChart
        viewForLineChart.marker = marker
    }
    
    func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    
}


extension ProductVisualizationVC{
    
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
           // print(params)
            
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
                   // print(str)
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
                    
                   // print("Decoded Response:", model)
                    
                    // Step 6: Use the decoded model
                    if status == StatusType.Success {
                        if let productList = model.productList {
                            self.productList = productList
                            
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
                                
                                self.lblHorizentalChart.text = self.indicatorKey + " ("+(productList[0].unit ?? "") + ")"
                                
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
                                    self.imgFrequecy.layer.cornerRadius = 10
                                    self.imgFrequecy.clipsToBounds = true
                                    self.imgFrequecy.isHidden = self.dropDownFrequencyArr.count != 1
                                    self.btnFrequency.isEnabled = self.dropDownFrequencyArr.count != 1
                                    
                                    self.constraintsViewHeight.constant = 200
                                    self.viewFrequency.isHidden = false
                                } else {
                                    self.constraintsViewHeight.constant = 175
                                    self.viewFrequency.isHidden = true
                                }
                                self.frequencycheck = ""
                            }
                            
                            //Chart Call
                            self.setupChart()
                            
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
}


extension ProductVisualizationVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
