//
//  SubMenuTableCell.swift
//  USHA
//
//  Created by Hitesh Prajapati on 16/06/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import UIKit

class SubMenuTableCell: UITableViewCell {
    
    //MARK:- IBOutlets -
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle : UILabel!
    
    //MARK:- Methods -
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
