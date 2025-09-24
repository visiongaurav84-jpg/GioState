//
//  InfographicsTVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 03/08/25.
//

import UIKit

class InfographicsTVC: UITableViewCell {
    
    @IBOutlet weak var LblInfographicsHeading: UILabel!
    @IBOutlet weak var ImgInfographics: UIImageView!
    @IBOutlet weak var BtnDownload: UIButton!
    @IBOutlet weak var LblCounts: UILabel!
    @IBOutlet weak var BtnShare: UIButton!
    @IBOutlet weak var constraintImgHeight: NSLayoutConstraint!
    
    // Store item and view controller
    private var item: InfoGraphicsListResponse?
    private weak var presentingViewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Choose height based on device
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let imageHeight: CGFloat = isIpad ? 900 : 500
        constraintImgHeight.constant = imageHeight
    }
    
    func configure(with item: InfoGraphicsListResponse, presentingViewController: UIViewController) {
        self.item = item
        self.presentingViewController = presentingViewController
        
        displayWebP(base64String: item.imageIcon ?? "", imageView: ImgInfographics)
        LblInfographicsHeading.text = item.title
        LblCounts.text = String(item.viewCount ?? 0)+" Views"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func downloadClicked(_ sender: UIButton) {
        guard let item = item,
              let base64 = item.imageIcon,
              let vc = presentingViewController else { return }
        
        saveWebPBase64ToPhotos(base64String: base64, presentingViewController: vc)
    }
    
    @IBAction func shareClicked(_ sender: UIButton) {
        guard let item = item,
              let base64 = item.imageIcon,
              let vc = presentingViewController else { return }
        
        shareWebPBase64Image(base64String: base64, presentingViewController: vc)
    }
    
}
