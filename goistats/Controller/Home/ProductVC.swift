//
//  HomeVC.swift
//  SII
//
//  Created by Admin on 14/02/25.
//

import UIKit
import FSPagerView
import WebKit

class ProductVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var productCollectionView: UICollectionView! {
        didSet {
            productCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        }
    }
    
    @IBOutlet weak var pageControllerForColl: UIPageControl!
    
    // MARK: - Variables
    var currentIndex = 0
    var productList: [Product] = []
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    // MARK: - Setup Method
    func setUp() {
        Constant.currentView = "2"
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        productCollectionView.collectionViewLayout = createCompositionalLayout()
        
        self.indicatorListing()
    }
    
    // MARK: - Compositional Layout
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { environment in
            var frames: [NSCollectionLayoutGroupCustomItem] = []
            
            let containerWidth = environment.container.contentSize.width
            let containerHeight = environment.container.contentSize.height
            
            let itemWidth = containerWidth / 2
            let itemHeight = containerHeight / 3
            
            for index in 0..<6 {
                let row = index / 2
                let column = index % 2
                
                let originX = CGFloat(column) * itemWidth
                let originY = CGFloat(row) * itemHeight
                
                let frame = CGRect(x: originX, y: originY, width: itemWidth, height: itemHeight)
                let customItem = NSCollectionLayoutGroupCustomItem(frame: frame)
                frames.append(customItem)
            }
            
            return frames
        }
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        
        // 🔥 Update PageControl when scrolling
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, environment) in
            guard let self = self else { return }
            let page = round(offset.x / environment.container.contentSize.width)
            self.pageControllerForColl.currentPage = Int(page)
            self.currentIndex = Int(page) * 6
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    
    // MARK: - Page Tracking
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let index = scrollView.contentOffset.x / width
        let roundedIndex = round(index)
        self.pageControllerForColl.currentPage = Int(roundedIndex)
    }
    
    // MARK: - Navigation
    static func getInstance() -> ProductVC {
        return MainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! ProductVC
    }
    
    // MARK: - Actions
    @IBAction func seeMoreClicked(_ sender: Any) {
        let totalItems = productCollectionView.numberOfItems(inSection: 0)
        let nextIndex = currentIndex + 6
        
        if nextIndex < totalItems {
            currentIndex = nextIndex
            let indexPath = IndexPath(item: currentIndex, section: 0)
            productCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ProductVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        let item = productList[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = productList[indexPath.row]
        let vc: UIViewController

        if product.productName == "HCES" {
            let mapVC = MainStoryboard.instantiateViewController(withIdentifier: "MapDetailsVC") as! MapDetailsVC
            mapVC.indexValue = 0
            mapVC.productDict = product
            vc = mapVC
        } else {
            let detailsVC = MainStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
            detailsVC.indexValue = 0
            detailsVC.productDict = product
            vc = detailsVC
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProductVC {
    
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
            
            // 5. AES encrypt the version code using the derived key.
            let info = Bundle.main.infoDictionary
            let currentVersion = info?["CFBundleShortVersionString"] as? String ?? ""
            let encryptedVersionCode = EncryptionUtility.encrypt(plainText: currentVersion, password: derivedKeyHex!)
            
            // 6. Model Name
            let modelName = EncryptionUtility.deviceModelName()
            
            let params: NSDictionary = [
                "deviceId": encryptedDeviceId!,
                "versionCode": encryptedVersionCode!,
            ]
            
            // Provide the desired order manually:
            let orderedKeys = ["deviceId", "versionCode"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            let salt = UserDefaults.standard.string(forKey: "ivKey") ?? ""
            
            indicatorListingAPI(params: params, checkSum: checkSum)
        }
        
        
        func indicatorListingAPI(params: NSDictionary, checkSum: String = "") {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.indicatorListingAPI(params: params, checkSum: checkSum, success: { (response, status) in
                print("API response:\n", response)
                
                // Pretty print the response JSON
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
                    let model = try decoder.decode(IndicatorListResponse.self, from: jsonData)
                    
                    //print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if status == StatusType.Success {
                        if let productList = model.productList {
                            self.productList.append(contentsOf: productList)
                            self.pageControllerForColl.numberOfPages = Int(ceil(Double(self.productList.count) / 6.0))
                            self.productCollectionView.reloadData()
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
}


