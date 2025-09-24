//
//  PdfViewVC.swift
//  NTPC Samvaad
//
//  Created by PECS IOS on 07/04/21.
//  Copyright © 2021 Gaurav. All rights reserved.
//

import UIKit
import PDFKit
import WebKit
import SVProgressHUD
import Alamofire

class PdfViewVC: UIViewController, WKNavigationDelegate {
    
    //MARK: - Ibbullet
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var imgDownloadShare: UIImageView!
    
    //MARK: - Variable
    var pdfURL:String?
    var type:String?
    var loadCount: Int = 0
    var progressBarTimer: Timer!
    var headerTitle:String?
    
    //MARK: - Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayWebView()
        
        //Change icon base on the type
        if (type == "pdf"){
            imgDownloadShare.image = UIImage(named: "download")
        }else{
            imgDownloadShare.image = UIImage(named: "share")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    private func displayWebView() {
        self.lblHeader.text = headerTitle
        self.progressView.progress = 0.0
        self.progressView.height = 20
        if pdfURL ?? "" == ""{
            AppNotification.showErrorMessage("PDF URL not found!")
            return
        }else{
            let link = URL(string:pdfURL ?? "")!
            let request = URLRequest(url: link)
            webView.load(request)
            self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        }
    }
    
    // Observe value
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let stringValue = String(format: "%.2f", self.webView.estimatedProgress)
            let intValue = Int((Float(stringValue) ?? 0.0)*100)
            self.lblProgress.text = String(intValue)+"%"
            self.progressView.progress = Float(self.webView.estimatedProgress);
        }
        if Float(self.webView.estimatedProgress) == 1.0{
            self.progressView.isHidden = true
            self.lblProgress.isHidden = true
        }
    }
    
    
    //MARK: - Action Methods
    
    @IBAction func downLoadClicked(_ sender: Any) {
        let str = String(format: "%@", self.pdfURL!)
        let trimmedURL = str.replacingOccurrences(of: " ", with: "%20")
       // print(trimmedURL)
        let urlStr = URL(string: trimmedURL)!
        
        if (type == "pdf"){
            downloadPDF(url: urlStr, vc: self)
        }else{
            shareURL(urlString: trimmedURL, from: self)
        }
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
