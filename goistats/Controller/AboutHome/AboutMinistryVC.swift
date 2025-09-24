//
//  AboutMinistryVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 03/08/25.
//

import UIKit
import WebKit

class AboutMinistryVC: UIViewController, WKNavigationDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var webView: WKWebView!
    
    //MARK: - Variable
    var ministryProfile: MinistryProfile?
    var darkLightColor = ""
    
    //MARK: - Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "linkClicked")
        
        self.displayWebView()
    }
    
    @IBAction func btnMoreDetailsClicked(_ sender: Any) {
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "web"
        vc.pdfURL = ApiUrl.mospiWebsiteURL
        vc.headerTitle = "MoSPI Website"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func displayWebView() {
        let htmlContent = ministryProfile?.aboutMinistry ?? ""
        
        if let fontURL = Bundle.main.url(forResource: "NotoSans-Regular", withExtension: "ttf") {
            let styledHTML = """
            <html>
            <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                @font-face {
                    font-family: 'NotoSansCustom';
                    src: url('NotoSans-Regular.ttf') format('truetype');
                }
                body, p, span, div, li, h1, h2, h3, h4, h5, h6, a {
                    font-family: 'NotoSansCustom', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif !important;
                    max-width: 100% !important;
                    overflow-x: hidden !important;
                }
            </style>
            </head>
            <body>
            \(htmlContent)
            </body>
            </html>
            """
            
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
            
            webView.navigationDelegate = self
            webView.scrollView.showsHorizontalScrollIndicator = false
            webView.scrollView.alwaysBounceHorizontal = false
            webView.loadHTMLString(styledHTML, baseURL: Bundle.main.resourceURL)
        }
    }
    
    // Run after the HTML is fully loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let adaptiveColor = UIColor(named: "TextColorThreeBlackToYellow")!
        let resolvedColor = adaptiveColor.resolvedColor(with: traitCollection)
        darkLightColor = resolvedColor.toHexString()

        let js = """
        document.querySelectorAll('body, p, span, div, li, summary, h1, h2, h3, h4, h5, h6, a').forEach(function(el) {
            el.style.setProperty('font-family', 'NotoSansCustom, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif', 'important');
            el.style.setProperty('font-size', '14px', 'important');
            el.style.setProperty('line-height', '1.4', 'important');
            el.style.setProperty('color', '\(darkLightColor)', 'important');
        });
        
        // Fix details background
        document.querySelectorAll('details').forEach(function(el) {
            el.style.backgroundColor = 'transparent';
            el.style.border = '1px solid #ccc';
            el.style.borderRadius = '5px';
            el.style.padding = '0.8rem';
        });

        // Intercept link clicks
        document.querySelectorAll('a').forEach(function(el) {
            el.addEventListener('click', function(event) {
                event.preventDefault(); // stop WKWebView navigation
                window.webkit.messageHandlers.linkClicked.postMessage(el.href);
            });
        });
        """

        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}

extension AboutMinistryVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "linkClicked",
           let urlString = message.body as? String,
           let url = URL(string: urlString) {
            
            let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
            vc.type = "web"
            vc.pdfURL = url.absoluteString
            vc.headerTitle = "Website"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
