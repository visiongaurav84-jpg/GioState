//
//  OrganogramVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class OrganogramVC: UIViewController, UIScrollViewDelegate {
    
    //MARK: - Outlets...
    @IBOutlet weak var scroll1: UIScrollView!
    @IBOutlet weak var imgOrganogram: UIImageView!
    
    //MARK: - Variable...
    var organogramDetails: OrganogramDetails?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayOrganogram()
        //displaySVG(from: (organogramDetails?.organogramImage)!, in: imgOrganogram)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) == true {
            displayOrganogram() // reload correct SVG
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        scroll1.minimumZoomScale = 1.0
        scroll1.maximumZoomScale = 6.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgOrganogram
    }
    
    func displayOrganogram() {
        guard let details = organogramDetails else { return }
        
        let imageURL = (traitCollection.userInterfaceStyle == .dark)
            ? (details.organogramImageDark ?? details.organogramImage)
            : details.organogramImage
        
        if let url = imageURL {
            displaySVG(from: url, in: imgOrganogram)
        }
    }
}
