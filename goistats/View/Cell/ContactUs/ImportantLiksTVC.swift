//
//  ImportantLiksTVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class ImportantLiksTVC: UITableViewCell {
    
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var lblUrlName: UILabel!
    @IBOutlet weak var viewSubMain: UIView!
    @IBOutlet weak var viewMain: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewSubMain.layer.shadowColor = UIColor.black.cgColor
        viewSubMain.layer.shadowOpacity = 0.3
        viewSubMain.layer.shadowOffset = CGSize(width: 0, height: 4)
        viewSubMain.layer.shadowRadius = 5
        viewSubMain.layer.masksToBounds = false
        viewSubMain.layer.cornerRadius = 8
    }
    
    func configure(with dict: Urls) {
        self.lblUrlName.text = dict.urlKey
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
