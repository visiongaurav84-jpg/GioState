//
//  UIViewController+Extension.swift
//  USHA
//
//  Created by Hitesh Prajapati on 26/05/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import UIKit
extension UIViewController{
    
    open override func awakeFromNib() {
        //Hide default back button title.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }
}

extension UIAlertController {
    @objc func isEmpty(){
        actions[0].isEnabled = !(textFields?[0].text!.isBlank)!
    }
}
