import UIKit
import WebKit

class InfoTVC: UITableViewCell, WKNavigationDelegate {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var constraintsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    
    private var htmlString: String?
    var onHeightChange: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
        // Make background transparent
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        viewMain.layer.cornerRadius = 12  // Set your desired radius
        viewMain.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        viewMain.clipsToBounds = true
        
    }
    
    func configure(with html: String) {
        let trimmed = html.trimmingCharacters(in: .whitespacesAndNewlines)
        if htmlString != trimmed {
            htmlString = trimmed
            loadHTML(trimmed)
        }
    }
    
    private func loadHTML(_ _: String) {
        // Completely rebuild HTML to avoid inherited styles
        let styledHTML = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Arial;
                font-size: 16px;
                font-weight: 500;
                color: #333333;
                margin: 0;
                padding: 0;
                line-height: 1.4;
                text-align: center;
            }
            p {
                margin: 0;
                padding: 0;
            }
            a {
                color: #007AFF;
                text-decoration: none;
                font-weight: 500;
            }
        </style>
        </head>
        <body>
        <p>Data Informatics and Innovation Division(DIID)</p>
        <p>Ministry of Statistics and Programme Implementation</p>
        <p>East Block-10, R K Puram</p>
        <p>New Delhi- 110066</p>
        <p>Email: <a href="mailto:webunit.diid@mospi.gov.in">webunit.diid@mospi.gov.in</a></p>
        <p>Phone: <a href="tel:01126194203">011-26194203</a></p>
        </body>
        </html>
        """
        
        webView.loadHTMLString(styledHTML, baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let adaptiveColor = UIColor(named: "TextColorThreeBlackToYellow")!
        let resolvedColor = adaptiveColor.resolvedColor(with: traitCollection)
        let darkLightColor = resolvedColor.toHexString()
        
        webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] (result, error) in
            guard let self = self, let height = result as? CGFloat, error == nil else { return }
            self.constraintsViewHeight.constant = height-40
            self.layoutIfNeeded()
            self.onHeightChange?()
        }
        
        let js = """
        document.querySelectorAll('*').forEach(function(el) {
            el.style.fontSize = '14px';
            el.style.lineHeight = '1.0';
            el.style.color = '\(darkLightColor)';
        });
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
