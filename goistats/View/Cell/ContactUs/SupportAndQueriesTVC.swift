//
//  SupportAndQueriesTVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class SupportAndQueriesTVC: UITableViewCell {
    
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblNodelDevision: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblSubject: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewMain.layer.shadowColor = UIColor.black.cgColor
        viewMain.layer.shadowOpacity = 0.3
        viewMain.layer.shadowOffset = CGSize(width: 0, height: 4)
        viewMain.layer.shadowRadius = 5
        viewMain.layer.masksToBounds = false
        viewMain.layer.cornerRadius = 8
    }
    
    func configure(with dict: SupportQueries) {
        self.lblSubject.text = dict.subject
        self.lblNodelDevision.text = dict.contactPerson?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lblEmail.text = dict.contactEmail
        self.lblPhone.text = dict.contactPhone
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
