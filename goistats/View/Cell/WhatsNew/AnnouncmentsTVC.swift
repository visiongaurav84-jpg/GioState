//
//  AnnouncmentsTVC.swift
//  Express Lite
//
//  Created by Gaurav Awasthi on 01/08/25.
//

import UIKit

class AnnouncmentsTVC: UITableViewCell {
    
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var toggleExpand: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with report: PressData) {
        self.lblTitle.text = report.documentTitle
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
