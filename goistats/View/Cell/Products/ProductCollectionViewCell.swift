//
//  CollectionViewCell.swift
//  goistats
//
//  Created by getitrent on 23/07/25.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var lblProduct: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bottomView.layer.cornerRadius = 10
        bottomView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bottomView.clipsToBounds = true
    }
    
    func configure(with item: Product) {
        displaySVG(from: item.productIcon, in: imgProduct)
        lblProduct.text = item.productDescription
    }
}
