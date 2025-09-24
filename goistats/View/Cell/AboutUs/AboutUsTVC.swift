//
//  AboutUsTVC.swift
//  Express Lite
//
//  Created by Gaurav Awasthi on 01/08/25.
//

import UIKit

class AboutUsTVC: UITableViewCell {
    
    @IBOutlet weak var imgUpDown: UIImageView!
    @IBOutlet weak var btnMoreLess: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var toggleExpand: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblDescription.text = ""
        self.lblDescription.numberOfLines = 0 // allow multiline when expanded
        self.btnMoreLess.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
    }
    
    func configure(with report: DivisionDetails) {
        self.lblTitle.text = report.divisionTitle
        
        if report.isExpanded ?? false {
            setHTMLContent(html: report.divisionOverview ?? "", label: self.lblDescription, fontSize: 12)
            self.lblDescription.isHidden = false
            self.imgUpDown.image = UIImage(named: "down.png")
        } else {
            self.lblDescription.isHidden = true
            self.lblDescription.text = "" // clear old text from reused cell
            self.imgUpDown.image = UIImage(named: "next.png")
            
        }
    }
    
    
    @objc func handleMore() {
        toggleExpand?()
    }
}
