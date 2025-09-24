//
//  UIButton+Extension.swift
//  USHA
//
//  Created by Hitesh Prajapati on 25/05/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import UIKit

extension UIButton{
    
    func setButtonTheme(size : CGFloat = 16){
        self.backgroundColor = AppColor.PrimaryColor
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont(name: AppFont.Regular, size: size)
        self.cornerRadius = 8
    }
    
    func setLinkButtonTheme(size : CGFloat = 15){
        self.backgroundColor = .clear
        self.setTitleColor(AppColor.LinkButtonColor, for: .normal)
        self.titleLabel?.font = UIFont(name: AppFont.Regular, size: size)
    }
    
    
}
