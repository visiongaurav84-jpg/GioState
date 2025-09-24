//
//  HomeVC.swift
//  goistats
//
//  Created by Admin on 14/02/25.
//

import UIKit
import DGCharts
import CoreData

class HomeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var lblLastUpdateDate: UILabel!
    @IBOutlet weak var constraintsHeightTrendingProduct: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightProducts: NSLayoutConstraint!
    @IBOutlet weak var lblAllProducts: UILabel!
    
    @IBOutlet weak var homeProductsCollectionView: UICollectionView!{
        didSet {
            homeProductsCollectionView.register(UINib(nibName: "HomeProductsCVCell", bundle: nil), forCellWithReuseIdentifier: "HomeProductsCVCell")
        }
    }
    
    @IBOutlet weak var collTrendingProduct: UICollectionView!{
        didSet{
            collTrendingProduct.register(UINib(nibName: "TrendingProductCVC", bundle: nil), forCellWithReuseIdentifier: "TrendingProductCVC")
        }
    }
    
    @IBOutlet weak var viewLineChart: LineChartView!
    
    
    //MARK: - variables....
    var scrollTimer: CADisplayLink?
    var productList: [Product] = []
    var topProductList: [TopProductListResponse] = []
    private var didShowNotificationPrompt = false
    
    
    //MARK: - Life Cycle Methods....
    override func viewDidLoad() {
        super.viewDidLoad()
        self.constraintsHeightTrendingProduct.constant = 0
        self.constraintHeightProducts.constant = 0
        self.lblAllProducts.isHidden = true
        Constant.currentView = "1"
        startSmoothAutoScroll()
        topProducts()
        indicatorListing()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkPendingNotification),
                                               name: .pendingNotificationUpdated,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPendingNotification() // Immediate check on appear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    @objc private func checkPendingNotification() {
        if let pending = AppDelegate.shared.pendingNotification {
            showDialog(title: pending.title, message: pending.message)
            AppDelegate.shared.pendingNotification = nil
        }
    }
    
    //MARK: - Custom Methods....
    func startSmoothAutoScroll() {
        scrollTimer = CADisplayLink(target: self, selector: #selector(handleAutoScroll))
        scrollTimer?.add(to: .main, forMode: .default)
    }
    
    @objc func handleAutoScroll() {
        let scrollSpeed: CGFloat = 0.5 // adjust for faster or slower scrolling
        let currentOffset = homeProductsCollectionView.contentOffset.x
        let maxOffset = homeProductsCollectionView.contentSize.width - homeProductsCollectionView.frame.width
        
        if currentOffset >= maxOffset {
            // Reset to beginning when end is reached
            homeProductsCollectionView.setContentOffset(.zero, animated: false)
        } else {
            let newOffset = CGPoint(x: currentOffset + scrollSpeed, y: 0)
            homeProductsCollectionView.setContentOffset(newOffset, animated: false)
        }
    }
    
    @IBAction func seeMoreClicked(_ sender: Any) {
        if !isConnectedToNetwork() {
            AppNotification.showErrorMessage(AppMessages.InternetError)
            return
        }
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "AboutUsHomeVC") as! AboutUsHomeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func designedAndDevelopedClick(_ sender: Any) {
        if !isConnectedToNetwork() {
            AppNotification.showErrorMessage(AppMessages.InternetError)
            return
        }
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "web"
        vc.pdfURL = ApiUrl.mospiWebsiteURL
        vc.headerTitle = "MoSPI Website"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Show Notification Dialog
    func showDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true)
    }
    
}

// MARK: - UICollectionView DataSource & Delegate
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == homeProductsCollectionView{
            return self.productList.count
        }else{
            return topProductList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == homeProductsCollectionView{
            let cell: HomeProductsCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeProductsCVCell", for: indexPath) as! HomeProductsCVCell
            let item = productList[indexPath.row]
            cell.configure(with: item)
            return cell
        }else{
            let cell : TrendingProductCVC  = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingProductCVC", for: indexPath) as! TrendingProductCVC
            let item = topProductList[indexPath.row]
            cell.configure(with: item)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isConnectedToNetwork() {
            AppNotification.showErrorMessage(AppMessages.InternetError)
            return
        }
        
        if collectionView == homeProductsCollectionView{
            let vc = MainStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
            vc.indexValue = 0
            vc.productDict = productList[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let item = topProductList[indexPath.row]
            let productDict = Product(
                productAggregateValue: item.productAggregateValue ?? "",
                productIcon: "",
                productName: item.productName ?? "",
                unit: "",
                productDescription: item.productDescription ?? "",
                valueDate: item.valueDate ?? "",
                indicators: item.indicators,
                frequency: item.frequency,
            )
            
            let vc = MainStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
            vc.indexValue = 0
            vc.productDict = productDict
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.homeProductsCollectionView {
            let width = 150.0
            let height = 175.0
            return CGSize(width: width, height: height)
        }else{
            let width = collectionView.frame.width
            let height = 188.0
            return CGSize(width: width, height: height)
        }
    }
    
}


extension HomeVC {
    
    func indicatorListing() {
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
            
            indicatorListingAPI(params: params)
        }
        
        
        func indicatorListingAPI(params: NSDictionary) {
            if !isConnectedToNetwork() {
                //AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.indicatorListingAPI(params: params, checkSum: "", success: { (response, status) in
                //print("API response:\n", response)
                
                // 1. Convert response dictionary to JSON Data
                guard let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
                    print("Failed to serialize response")
                    return
                }
                
                // 2. Decode into IndicatorListResponse model
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(IndicatorListResponse.self, from: jsonData)
                    
                    //print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let productList = model.productList {
                            self.productList.append(contentsOf: productList)
                            self.constraintHeightProducts.constant = CGFloat(175)
                            self.lblAllProducts.isHidden = false
                            self.homeProductsCollectionView.reloadData()
                            self.startSmoothAutoScroll()
                        }
                    } else if status == StatusType.TokenExpired {
                        AppNotification.showErrorMessage("Error!")                    } else {
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
    
    
    func topProducts() {
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
            //print(params)
            // Provide the desired order manually:
            let orderedKeys = ["deviceId"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            let salt = UserDefaults.standard.string(forKey: "ivKey") ?? ""
            
            topProductsAPI(params: params)
        }
        
        
        func topProductsAPI(params: NSDictionary) {
            if isConnectedToNetwork() {
                // Online: fetch API
                ApiRequest.topProductsAPI(params: params, checkSum: "", success: { (response, status) in
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(ProductListResponse.self, from: jsonData)
                        
                        // Check if we should update DB
                        if self.shouldUpdateFromApi() {
                            self.clearCachedProducts() // delete old
                            self.saveProductsToCoreData(model.productList) // insert new
                        }
                        
                        // Update UI
                        self.topProductList = model.productList
                        self.constraintsHeightTrendingProduct.constant = CGFloat(197*(self.topProductList.count))
                        self.collTrendingProduct.reloadData()
                        
                    } catch {
                        print("Decode error:", error)
                    }
                    
                }) { (error, status) in
                    print("API error:", error)
                }
            } else {
                // Offline: Load from Core Data
                let cachedProducts = fetchProductsFromCache()
                if cachedProducts.isEmpty {
                    AppNotification.showErrorMessage("No offline data available")
                } else {
                    self.topProductList = cachedProducts
                    self.constraintsHeightTrendingProduct.constant = CGFloat(197*(self.topProductList.count))
                    self.collTrendingProduct.reloadData()
                    self.lblLastUpdateDate.text = "Last Updated: \(String(describing: getLastUpdatedDate()))"
                }
            }
        }
        
    }
    
    
    
    
    
    
    //MARK: - Core Date Methods
    func shouldUpdateFromApi() -> Bool {
        let context = CoreDataStack.shared.context
        let request: NSFetchRequest<TrendingProduct> = TrendingProduct.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 { return true }
            
            // Get latest date
            request.sortDescriptors = [NSSortDescriptor(key: "lastUpdatedDate", ascending: false)]
            request.fetchLimit = 1
            
            if let latest = try context.fetch(request).first?.lastUpdatedDate {
                let calendar = Calendar.current
                return !calendar.isDateInToday(latest)
            }
            
            return true
        } catch {
           // print("Update check error:", error)
            return true
        }
    }
    
    func saveProductsToCoreData(_ products: [TopProductListResponse]) {
        let context = CoreDataStack.shared.context
        let currentDate = Date()
        
        for product in products {
            let entity = TrendingProduct(context: context)
            
            entity.productName = product.productName
            entity.productRank = Int32(product.productRank ?? 0)
            entity.productAggregateValue = product.productAggregateValue
            entity.productIcon = product.productIcon
            entity.valueDate = product.valueDate
            entity.productDescription = product.productDescription
            entity.unit = product.unit
            
            // Serialize nested objects
            if let metaData = try? JSONEncoder().encode(product.metaData) {
                entity.metaDataJSON = String(data: metaData, encoding: .utf8)
            }
            
            if let indicators = try? JSONEncoder().encode(product.indicators) {
                entity.indicatorsJSON = String(data: indicators, encoding: .utf8)
            }
            
            if let frequency = try? JSONEncoder().encode(product.frequency) {
                entity.frequencyJSON = String(data: frequency, encoding: .utf8)
            }
            
            if let data = try? JSONEncoder().encode(product.data) {
                entity.dataJSON = String(data: data, encoding: .utf8)
            }
            
            if let indicatorList = try? JSONEncoder().encode(product.indicatorList) {
                entity.indicatorListJSON = String(data: indicatorList, encoding: .utf8)
            }
            
            // Set last updated date
            entity.lastUpdatedDate = currentDate
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save products: \(error)")
        }
    }
    
    
    func fetchProductsFromCache() -> [TopProductListResponse] {
        let context = CoreDataStack.shared.context
        let request: NSFetchRequest<TrendingProduct> = TrendingProduct.fetchRequest()
        // Add sort descriptor by rank to main tain the product sequence.
            request.sortDescriptors = [NSSortDescriptor(key: "productRank", ascending: true)]
        
        do {
            let cached = try context.fetch(request)
            
            return cached.map { product in
                // Decode nested JSON fields safely
                let metaData: MetaData? = {
                    guard let json = product.metaDataJSON,
                          let data = json.data(using: .utf8) else { return nil }
                    return try? JSONDecoder().decode(MetaData.self, from: data)
                }()
                
                let dataObj: DataRequest? = {
                    guard let json = product.dataJSON,
                          let data = json.data(using: .utf8) else { return nil }
                    return try? JSONDecoder().decode(DataRequest.self, from: data)
                }()
                
                let indicators: [String: String]? = {
                    guard let json = product.indicatorsJSON,
                          let data = json.data(using: .utf8) else { return nil }
                    return try? JSONDecoder().decode([String: String].self, from: data)
                }()
                
                let frequency: [String: String]? = {
                    guard let json = product.frequencyJSON,
                          let data = json.data(using: .utf8) else { return nil }
                    return try? JSONDecoder().decode([String: String].self, from: data)
                }()
                
                let indicatorList: [String: String]? = {
                    guard let json = product.indicatorListJSON,
                          let data = json.data(using: .utf8) else { return nil }
                    return try? JSONDecoder().decode([String: String].self, from: data)
                }()
                
                return TopProductListResponse(
                    productName: product.productName,
                    productRank: Int(product.productRank),
                    productAggregateValue: product.productAggregateValue,
                    productIcon: product.productIcon,
                    valueDate: product.valueDate,
                    productDescription: product.productDescription,
                    data: dataObj,
                    indicators: indicators,
                    indicatorList: indicatorList,
                    frequency: frequency,
                    metaData: metaData,
                    unit: product.unit
                )
            }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func clearCachedProducts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TrendingProduct.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try CoreDataStack.shared.context.execute(deleteRequest)
            try CoreDataStack.shared.context.save()
        } catch {
            print("Failed to clear cache:", error)
        }
    }
}

extension Notification.Name {
    static let pendingNotificationUpdated = Notification.Name("pendingNotificationUpdated")
}



