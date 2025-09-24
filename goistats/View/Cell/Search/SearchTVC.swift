//
//  SearchTVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 03/08/25.
//

import UIKit

class SearchTVC: UITableViewCell {
    
    @IBOutlet weak var viewInfographics: UIView!
    @IBOutlet weak var viewData: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnVisualization: UIButton!
    @IBOutlet weak var btnData: UIButton!
    @IBOutlet weak var btnInfoGraphics: UIButton!
    @IBOutlet weak var viewVisualization: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: SearchSubResponse) {
        
        self.lblTitle.text = item.productName
        self.lblDescription.text = item.keyword
        
        
        
        if ((item.indicatorKey1?.isEmpty) != nil) {
            self.viewData.isHidden = false
        } else {
            self.viewData.isHidden = true
        }
        
        if ((item.indicatorKey2?.isEmpty) != nil) {
            self.viewVisualization.isHidden = false
        } else {
            self.viewVisualization.isHidden = true
        }
        
        if ((item.indicatorKey3?.isEmpty) != nil) {
            self.viewInfographics.isHidden = false
        } else {
            self.viewInfographics.isHidden = true
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
