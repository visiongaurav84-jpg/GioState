//
//  PressReleaseTVC.swift
//  Express Lite
//
//  Created by Gaurav Awasthi on 01/08/25.
//

import UIKit

class NotificationTVC: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var toggleExpand: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with dict: NotificationItem) {
        self.lblTitle.text = dict.messageText
        self.lblDescription.text = dict.dateCreated
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
