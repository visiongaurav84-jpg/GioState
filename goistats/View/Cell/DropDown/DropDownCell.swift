//
//  MyCell.swift
//  NTPC Samvaad
//
//  Created by EL Group on 16/01/21.
//  Copyright © 2021 Gaurav. All rights reserved.
//

import DropDown
import UIKit

class MyCell: DropDownCell {
    
    @IBOutlet weak var constranintsLeadingLbl: NSLayoutConstraint!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
