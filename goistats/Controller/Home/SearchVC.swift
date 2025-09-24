//
//  SearchVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 03/08/25.
//

import UIKit
import Speech
import AVFoundation

class SearchVC: UIViewController, UITextFieldDelegate {
    
    //MARK: - Outlets...
    @IBOutlet weak var imgMicClose: UIImageView!
    @IBOutlet weak var tblSearch: UITableView!{
        didSet{
            tblSearch.register(UINib(nibName: "SearchTVC", bundle: nil), forCellReuseIdentifier: "SearchTVC")        }
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnCloseSearch: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-IN"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechAlert: UIAlertController?
    
    //MARK: - Variable...
    var searchArr = [SearchSubResponse]()
    private var resultTimer: Timer?
    var finalResult: String = ""
    var apiResult = false
    
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        requestSpeechPermission()
        self.setupUI()
    }
    
    //MARK: - Custom Methods...
    func setupUI(){
        txtSearch.attributedPlaceholder = NSAttributedString(
            string: "Search Data",
            attributes: [.foregroundColor: UIColor.white]
        )
        
        tblSearch.showsVerticalScrollIndicator = false
        tblSearch.estimatedRowHeight = 100
        tblSearch.rowHeight = UITableView.automaticDimension
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        btnCloseSearch.addTarget(self, action: #selector(btnCloseSearchTapped(_:)), for: .touchUpInside)
        
        
        txtSearch.returnKeyType = .search
        txtSearch.delegate = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let searchText = textField.text ?? ""
        if searchText.count == 0 {
            imgMicClose.image = UIImage(systemName: "microphone")
        }else{
            imgMicClose.image = UIImage(named: "close")
        }
        
        imgMicClose.tintColor = .white
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.txtSearch.text!.count == 0 {
            AppNotification.showErrorMessage("Please enter some text!")
            return false
        }else{
            self.getSearch()
            textField.resignFirstResponder() // Hide the keyboard
            return true
        }
    }
    
    func performSearch(query: String) {
        //print("Searching for: \(query)")
        // Add your API call or search logic here
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnCloseSearchTapped(_ sender: UIButton) {
        if self.txtSearch.text!.count == 0 {
            presentSpeechDialog()
        }else{
            self.txtSearch.text?.removeAll()
            self.searchArr.removeAll()
            self.tblSearch.reloadData()
            self.apiResult = false
            imgMicClose.image = UIImage(systemName: "microphone")
        }
    }
    
    func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus != .authorized {
                    self.showAlert("Speech recognition permission denied.")
                }
            }
        }
    }
    
    
    
    func presentSpeechDialog() {
        speechAlert = UIAlertController(title: "Speak now...", message: nil, preferredStyle: .alert)
        present(speechAlert!, animated: true) {
            self.startRecording()
        }
    }
    
    func startRecording() {
        if audioEngine.isRunning {
            stopRecording()
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            self.dismissSpeechDialog()
            return
        }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                if let result = result {
                    let spokenText = result.bestTranscription.formattedString
                    // print("You said: \(spokenText)")
                    if spokenText.count > 0 {
                        self.finalResult = spokenText
                    }
                    self.txtSearch.text = self.finalResult
                    isFinal = result.isFinal
                    if spokenText != ""{
                        self.resetResultTimeout()
                    }
                    // Optionally update a label here with spokenText
                }
                
            }
        } catch {
            print("Audio engine error: \(error.localizedDescription)")
            self.dismissSpeechDialog()
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    func dismissSpeechDialog() {
        DispatchQueue.main.async {
            if let alert = self.speechAlert {
                alert.dismiss(animated: true, completion: nil)
                self.speechAlert = nil
            }
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Fallback Timer
    func resetResultTimeout() {
        resultTimer?.invalidate()
        resultTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
            self.dismissSpeechDialog()
            self.stopRecording()
            if self.apiResult == false && self.txtSearch.text != ""{
                self.getSearch()
            }
        }
    }
    
    
    
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let report = searchArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTVC", for: indexPath) as! SearchTVC
        cell.configure(with: report)
        
        cell.btnVisualization.tag = indexPath.row
        cell.btnData.tag = indexPath.row
        cell.btnInfoGraphics.tag = indexPath.row
        cell.btnVisualization.addTarget(self, action: #selector(VisualizationClicked(_:)), for: .touchUpInside)
        cell.btnData.addTarget(self, action: #selector(dataClicked(_:)), for: .touchUpInside)
        cell.btnInfoGraphics.addTarget(self, action: #selector(InfoGraphicsClicked(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @IBAction func VisualizationClicked(_ sender: UIButton) {
        
        let item = searchArr[sender.tag]
        let productDict = Product(
            productAggregateValue: "",
            productIcon: "",
            productName: item.productName ?? "",
            unit: "",
            productDescription: "",
            valueDate: "",
            indicators: item.indicators,
            frequency: [:],
        )
        
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.indexValue = 0
        vc.productDict = productDict
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func dataClicked(_ sender: UIButton) {
        let item = searchArr[sender.tag]
        let productDict = Product(
            productAggregateValue: "",
            productIcon: "",
            productName: item.productName ?? "",
            unit: "",
            productDescription: "",
            valueDate: "",
            indicators: item.indicators,
            frequency: [:],
        )
        
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.indexValue = 1
        vc.productDict = productDict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func InfoGraphicsClicked(_ sender: UIButton) {
        let item = searchArr[sender.tag]
        let productDict = Product(
            productAggregateValue: "",
            productIcon: "",
            productName: item.productName ?? "",
            unit: "",
            productDescription: "",
            valueDate: "",
            indicators: item.indicators,
            frequency: [:],
        )
        
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.indexValue = 2
        vc.productDict = productDict
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchVC {
    
    func getSearch() {
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
                "keyWord" : self.txtSearch.text ?? "",
            ]
            
            // Provide the desired order manually:
            let orderedKeys = ["deviceId","keyWord"]
            
            let json = EncryptionUtility.jsonStringPreservingKeyOrder(from: params, orderedKeys: orderedKeys)
            let checkSum = EncryptionUtility.sha256Checksum(json!)
            
            getSearchAPI(params: params, checkSum: checkSum)
        }
        
        
        func getSearchAPI(params: NSDictionary, checkSum:String)  {
            if !isConnectedToNetwork() {
                AppNotification.showErrorMessage(AppMessages.InternetError)
                return
            }
            
            ApiRequest.searchAPI(params: params, checkSum: checkSum, success: { (response, status) in
                // print("API response:\n", response)
                
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
                    let model = try decoder.decode(SearchResponse.self, from: jsonData)
                    
                    print("Decoded Response:", model)
                    
                    // 3. Use the decoded model here
                    if((StatusType.Success != 0) && model.statusCode == "02"){
                        // Show toast
                        self.showToast(message: "No information available with input keyword")
                        self.searchArr = []
                        self.tblSearch.reloadData()
                    }else if status == StatusType.Success {
                        if let searchList = model.response {
                            self.searchArr = searchList
                            self.imgMicClose.image = UIImage(named: "close")
                            self.apiResult = true
                            self.tblSearch.reloadData()
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
    
    func showToast(message: String, duration: Double = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        if let window = UIApplication.shared.windows.first {
            toastLabel.frame = CGRect(x: 20, y: window.frame.height - 100, width: window.frame.width - 40, height: 35)
            window.addSubview(toastLabel)
            UIView.animate(withDuration: 0.5, animations: {
                toastLabel.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                    toastLabel.alpha = 0.0
                }) { _ in
                    toastLabel.removeFromSuperview()
                }
            }
        }
    }
}

