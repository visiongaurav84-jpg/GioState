//
//  SideMenuTableCell.swift
//  USHA
//
//  Created by Hitesh Prajapati on 16/06/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import UIKit

class SideMenuTableCell: UITableViewCell {
    
    //MARK:- IBOutlets -
    
    @IBOutlet weak var lblSeprater: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var btnTap : UIButton!
    
    //MARK:- Methods -
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
