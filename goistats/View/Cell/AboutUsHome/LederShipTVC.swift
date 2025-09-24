//
//  AboutUsLederShip.swift
//  goistats
//
//  Created by Gaurav Awasthi on 09/08/25.
//

import UIKit

class LederShipTVC: UITableViewCell {
    
    @IBOutlet weak var lblSeprater: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblDesignation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configure(with report: NSOLeadership) {
        self.lblDesignation.text = report.dgStatus
        displayWebP(base64String: report.dgImage ?? "", imageView: imgProfile)
        self.lblName.text = report.dgName
        setHTMLContent(html: report.dgProfile ?? "", label: self.lblDescription, fontSize: 14)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
