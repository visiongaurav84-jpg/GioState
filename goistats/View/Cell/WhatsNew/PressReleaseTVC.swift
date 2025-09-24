//
//  PressReleaseTVC.swift
//  Express Lite
//
//  Created by Gaurav Awasthi on 01/08/25.
//

import UIKit

class PressReleaseTVC: UITableViewCell {
    
    @IBOutlet weak var lblMoreLess: UILabel!
    @IBOutlet weak var btnMoreLess: UIButton!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var toggleExpand: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblMoreLess.text = "More"
        self.btnMoreLess.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
    }
    
    func configure(with report: PressData) {
        self.lblTitle.text = report.documentTitle
        self.lblDescription.text = report.documentOverview
        self.lblMoreLess.text = report.isExpanded ?? false ? "less" : "more"
        self.lblDescription.numberOfLines = report.isExpanded ?? false ? 0 : 1
    }
    
    @objc func handleMore() {
        toggleExpand?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
