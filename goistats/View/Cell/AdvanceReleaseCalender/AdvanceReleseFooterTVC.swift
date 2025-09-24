//
//  AdvanceReleseFooterTVC.swift
//  goistats
//
//  Created by getitrent on 11/08/25.
//

import UIKit

class AdvanceReleseFooterTVC: UITableViewCell {
    
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewFooter.layer.cornerRadius = 10
        viewFooter.layer.masksToBounds = true
        viewFooter.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]    }
    
    func configure(with footerData: String) {
        setHTMLContent(html: footerData, label: self.lblDescription, fontSize: 14)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
