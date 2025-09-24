//
//  ZoomVC.swift
//  NTPC Samvaad
//
//  Created by EL Group on 29/04/21.
//  Copyright © 2021 Gaurav. All rights reserved.
//

import UIKit

class ZoomVC: UIViewController,UIScrollViewDelegate {
    
    //MARK: - Ibbullet
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewDownload: UIView!
    @IBOutlet weak var scroll1: UIScrollView!
    @IBOutlet weak var imgZoom: UIImageView!
    @IBOutlet weak var viewTopHeader: UIView!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgDownload: UIImageView!
    
    //MARK: - Variables
    var imgUrlStr:String?
    var imgLocal:UIImage?
    var downloadCheck:Bool?
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.downloadCheck == false{
            self.viewDownload.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if imgUrlStr == nil{
            print("nil")
            imgZoom.image = imgLocal
        }else{
            displayWebP(base64String: imgUrlStr ?? "", imageView: self.imgZoom)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        scroll1.minimumZoomScale = 1.0
        scroll1.maximumZoomScale = 6.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    //MARK: - Action Methods
    @IBAction func backClicked(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func downloadClicked(_ sender: Any) {
        saveWebPBase64ToPhotos(base64String: imgUrlStr ?? "", presentingViewController: self)
    }
    
    
    @IBAction func shareClicked(_ sender: Any) {
        shareWebPBase64Image(base64String: imgUrlStr ?? "", presentingViewController: self)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgZoom
    }
    
}
