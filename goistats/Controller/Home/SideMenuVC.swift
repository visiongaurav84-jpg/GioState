//
//  SideMenuVC.swift
//  goistats
//
//  Created by Admin on 14/02/25.
//

import UIKit
import FAPanels

class SideMenuVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tblMenu : UITableView!{
        didSet{
            tblMenu.register(UINib(nibName: "SideMenuTableCell", bundle: nil), forCellReuseIdentifier: "SideMenuTableCell")
            tblMenu.register(UINib(nibName: "SubMenuTableCell", bundle: nil), forCellReuseIdentifier: "SubMenuTableCell")
        }
    }
    
    @IBOutlet weak var lblAppVersion: UILabel!
    @IBOutlet weak var imgFacebook: UIImageView!
    @IBOutlet weak var imgTwitter: UIImageView!
    @IBOutlet weak var imgYouTube: UIImageView!
    @IBOutlet weak var imgInstagram: UIImageView!
    @IBOutlet weak var imgLinkedIn: UIImageView!
    @IBOutlet weak var imgHeaderLogo: UIImageView!
    
    
    //MARK:- Variables -
    let arrayMenu = SideMenuHelper.getSideMenuOptions()
    
    //MARK:- Life Cycle Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        //set App version in side menu.
        let info = Bundle.main.infoDictionary
        let currentVersion = info?["CFBundleShortVersionString"] as? String ?? ""
        lblAppVersion.text = "APP VERSION: \(currentVersion)"
        
        tblMenu.showsVerticalScrollIndicator = false
        tblMenu.showsHorizontalScrollIndicator = false
        
        // Enable user interaction
        imgFacebook.isUserInteractionEnabled = true
        imgTwitter.isUserInteractionEnabled = true
        imgYouTube.isUserInteractionEnabled = true
        imgInstagram.isUserInteractionEnabled = true
        imgLinkedIn.isUserInteractionEnabled = true
        
        // Add tap gesture
        let tapFacebookGesture = UITapGestureRecognizer(target: self, action: #selector(facebookTapped))
        imgFacebook.addGestureRecognizer(tapFacebookGesture)
        let tapTwitterGesture = UITapGestureRecognizer(target: self, action: #selector(twitterTapped))
        imgTwitter.addGestureRecognizer(tapTwitterGesture)
        let tapYoutubeGesture = UITapGestureRecognizer(target: self, action: #selector(youTubeTapped))
        imgYouTube.addGestureRecognizer(tapYoutubeGesture)
        let tapInstagramGesture = UITapGestureRecognizer(target: self, action: #selector(instagramTapped))
        imgInstagram.addGestureRecognizer(tapInstagramGesture)
        let tapLinkedInGesture = UITapGestureRecognizer(target: self, action: #selector(linkedInTapped))
        imgLinkedIn.addGestureRecognizer(tapLinkedInGesture)
        
        //change header logo image.
        if traitCollection.userInterfaceStyle == .dark {
            imgHeaderLogo.image = UIImage(named: "logo_mospi_dark")
        } else {
            imgHeaderLogo.image = UIImage(named: "logo_mospi")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        
        if traitCollection.userInterfaceStyle == .dark {
            imgHeaderLogo.image = UIImage(named: "logo_mospi_dark")
        } else {
            imgHeaderLogo.image = UIImage(named: "logo_mospi")
        }
    }
    
    @objc func facebookTapped() {
        openLink(SocialLinks.facebook)
    }
    
    @objc func twitterTapped() {
        openLink(SocialLinks.twitter)
    }
    
    @objc func youTubeTapped() {
        openLink(SocialLinks.youtube)
    }
    
    @objc func instagramTapped() {
        openLink(SocialLinks.instagram)
    }
    
    @objc func linkedInTapped() {
        openLink(SocialLinks.linkedin)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tblMenu.layoutIfNeeded()
    }
    
    
    static func getInstance() -> SideMenuVC{
        return MainStoryboard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
    }
    
    //MARK:- IBActions
    @IBAction func logoutAction(_ sender: Any) {
        
    }
    
    @IBAction func profileClicked(_ sender: Any) {
        
    }
    
    func logOutApi()  {
        logoutUser()
    }
    
    @IBAction func closedTheSideMenuClicked(_ sender: Any) {
        panel?.closeLeft()
    }
    
    @IBAction func logOutClicked(_ sender: Any) {
        showConfirmationAlert(vc: self, message: "Are you sure, you wants to logout?", btnOkTitle: "Yes", btnCancelTitle: "No") { (logout) in
            if logout{
                if #available(iOS 13.0, *) {
                    logoutUser()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    @IBAction func editProfile(_ sender: Any) {
        
    }
    
}

//MARK:- TableView Methods
extension SideMenuVC : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayMenu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenu[section].isOpen ? arrayMenu[section].subMenu.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubMenuTableCell", for: indexPath) as! SubMenuTableCell
        cell.lblTitle.text = arrayMenu[indexPath.section].subMenu[indexPath.row].title
        cell.imgView.image = UIImage(named: arrayMenu[indexPath.section].subMenu[indexPath.row].image)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = ["title" : arrayMenu[indexPath.section].subMenu[indexPath.row].title]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handleMenu"), object: nil, userInfo: detail)
        
        if arrayMenu[indexPath.section].subMenu[indexPath.row].title == "Organogram"{
            panel?.closeLeft()
            let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            vc.indexValue = 0
            self.navigationController?.pushViewController(vc, animated: true)
        }else if arrayMenu[indexPath.section].subMenu[indexPath.row].title == "Divisions of MoSPI"{
            panel?.closeLeft()
            let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            vc.indexValue = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }else if arrayMenu[indexPath.section].subMenu[indexPath.row].title == "Press Releases"{
            panel?.closeLeft()
            let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "WhatsNewVC") as! WhatsNewVC
            vc.indexValue = 0
            self.navigationController?.pushViewController(vc, animated: true)
        }else if arrayMenu[indexPath.section].subMenu[indexPath.row].title == "Announcements"{
            panel?.closeLeft()
            let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "WhatsNewVC") as! WhatsNewVC
            vc.indexValue = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableCell") as! SideMenuTableCell
        cell.imgView.image = UIImage(named: arrayMenu[section].image)
        cell.lblTitle.text = arrayMenu[section].title
        cell.imgArrow.isHidden = arrayMenu[section].subMenu.count > 0 ? false : true
        
        cell.btnTap.tag = section
        cell.btnTap.addTarget(self, action: #selector(headerTap(_:)), for: .touchUpInside)
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    @IBAction func headerTap(_ sender : UIButton){
        if arrayMenu[sender.tag].subMenu.count > 0{
            tblMenu.beginUpdates()
            arrayMenu[sender.tag].isOpen = arrayMenu[sender.tag].isOpen ? false : true
            tblMenu.reloadSections(IndexSet(integer: sender.tag), with: .none)
            tblMenu.endUpdates()
        }
        else{
            if sender.tag == 0{
                panel?.closeLeft()
                AppDelegate.shared.setupRootVC()
            }else if arrayMenu[sender.tag].title == "Reports and Publications"{
                panel?.closeLeft()
                let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "ReportAndPublicationsVC") as! ReportAndPublicationsVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else if arrayMenu[sender.tag].title == "Advance Release Calendar"{
                panel?.closeLeft()
                let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "AdvanceReleaseCalenderVC") as! AdvanceReleaseCalenderVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else if arrayMenu[sender.tag].title == "User Guide"{
                panel?.closeLeft()
                let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
                vc.type = "pdf"
                vc.pdfURL = ApiUrl.userGuideURL
                vc.headerTitle = "User Guide"
                self.navigationController?.pushViewController(vc, animated: true)
            }else if arrayMenu[sender.tag].title == "Contact Us"{
                panel?.closeLeft()
                let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else if arrayMenu[sender.tag].title == "Feedback"{
                panel?.closeLeft()
                let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else if arrayMenu[sender.tag].title == "Terms of Use & Privacy Policy"{
                panel?.closeLeft()
                let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
                vc.type = "web"
                vc.pdfURL = "https://goistatsapp.mospi.gov.in/uploads/about_app/tnc-1749026239229-459481913.html"
                vc.headerTitle = "Terms of Use & Privacy Policy"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

