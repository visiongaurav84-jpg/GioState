//
//  AboutUsLederShip.swift
//  goistats
//
//  Created by Gaurav Awasthi on 09/08/25.
//

import UIKit

class SecretaryTVC: UITableViewCell {
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblDesignation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with report: Secretary) {
        self.lblDesignation.text = report.secretaryDesignation?.uppercased()
        displayWebP(base64String: report.secretaryImage ?? "", imageView: imgProfile)
        self.lblName.text = report.secretaryName
        setHTMLContent(html: report.aboutSecretary ?? "", label: self.lblDescription, fontSize: 14)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
