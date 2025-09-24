//
//  HomeProductsCVCell.swift
//  goistats
//
//  Created by getitrent on 25/07/25.
//

import UIKit

class HomeProductsCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProduct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with item: Product) {
        displaySVG(from: item.productIcon, in: imgProduct)
        lblProduct.text = item.productDescription
    }
    
}
