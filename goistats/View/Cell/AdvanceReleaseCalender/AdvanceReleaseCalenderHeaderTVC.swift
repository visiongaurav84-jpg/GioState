//
//  AdvanceReleaseCalenderHeaderTVC.swift
//  Express Lite
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class AdvanceReleaseCalenderHeaderTVC: UITableViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with report: String) {
        self.lblDate.text = report
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
