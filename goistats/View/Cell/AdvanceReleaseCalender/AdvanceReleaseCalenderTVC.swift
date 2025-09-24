//
//  AdvanceReleaseCalenderTVC.swift
//  Express Lite
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class AdvanceReleaseCalenderTVC: UITableViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with report: ReleaseData) {
        self.lblDate.text = report.dateOfRelease
        setHTMLContent(html: report.releaseData ?? "", label: self.lblDescription, fontSize: 14)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
