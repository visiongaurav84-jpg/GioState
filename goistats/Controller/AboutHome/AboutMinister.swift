//
//  AboutMinister.swift
//  goistats
//
//  Created by Gaurav Awasthi on 03/08/25.
//

import UIKit

class AboutMinister: UIViewController {
    
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblDesignation: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    var ministryProfile: MinistryProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayWebP(base64String: ministryProfile?.ministerImage ?? "", imageView: imgProfile)
        self.lblName.text = ministryProfile?.ministerName
        self.lblDesignation.text = ministryProfile?.ministerDesignation
        setHTMLContent(html: ministryProfile?.aboutMinister ?? "", label: self.lblAbout, fontSize: 14)
    }
    
    @IBAction func viewClicked(_ sender: Any) {
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "pdf"
        vc.pdfURL = ministryProfile?.ministerProfilePath
        vc.headerTitle = "View Profile"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMoreDetailsClicked(_ sender: Any) {
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "web"
        vc.pdfURL = ApiUrl.mospiWebsiteURL
        vc.headerTitle = "MoSPI Website"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
