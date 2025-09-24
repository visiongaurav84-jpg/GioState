import UIKit
import WebKit

class ContentTVC: UITableViewCell, WKNavigationDelegate {
    
    @IBOutlet weak var constraintsHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    // This will be called after height is updated to refresh the table
    var onHeightChange: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false // Disable inner scroll
    }
    
    func configure(with report: String) {
        displayWebView(dataStr: report)
    }
    
    private func displayWebView(dataStr: String) {
        let htmlContent = dataStr
        
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
                html, body {
                    max-width: 100% !important;
                    overflow-x: hidden !important;
                    font-family: 'NotoSansCustom', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif !important;
                }
            </style>
            </head>
            <body>
            \(htmlContent)
            </body>
            </html>
            """
            
            webView.isOpaque = false               // removes the opaque white
            webView.backgroundColor = .clear       // Swift transparent
            webView.scrollView.backgroundColor = .clear
            
            webView.navigationDelegate = self
            webView.scrollView.showsHorizontalScrollIndicator = false
            webView.scrollView.alwaysBounceHorizontal = false
            webView.loadHTMLString(styledHTML, baseURL: Bundle.main.resourceURL)
            
        }
    }
    
    // This will run after the HTML is fully loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let adaptiveColor = UIColor(named: "TextColorThreeBlackToYellow")!
        let resolvedColor = adaptiveColor.resolvedColor(with: traitCollection)
        let darkLightColor = resolvedColor.toHexString()
        
        // Use documentElement.scrollHeight for more accurate results
        webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] (result, error) in
            guard let self = self, let height = result as? CGFloat, error == nil else { return }
            
            // Update constraint with padding
            self.constraintsHeight.constant = height-0
            self.layoutIfNeeded()
            
            // Notify tableView to refresh layout
            self.onHeightChange?()
        }
        
        
        let js = """
        document.querySelectorAll('*').forEach(function(el) {
            el.style.fontSize = '14px';
            el.style.lineHeight = '1.4';
            el.style.color = '\(darkLightColor)';
            el.style.fontFamily = 'NotoSansCustom, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif';
        });
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    
}

