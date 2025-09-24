//
//  ContactUsHeaderTVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class ContactUsHeaderTVC: UITableViewCell {
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var viewMain: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewMain.layer.cornerRadius = 12  // or any value you prefer
        viewMain.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewMain.clipsToBounds = true
    }
    
    func configure(with report: String) {
        self.lblHeader.text = report
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
