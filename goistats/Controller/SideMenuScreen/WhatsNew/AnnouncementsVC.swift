//
//  AnnouncementsVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class AnnouncementsVC: UIViewController {
    
    //MARK: - Outlets...
    @IBOutlet weak var tblAnnouncments: UITableView!{
        didSet{
            tblAnnouncments.register(UINib(nibName: "AnnouncmentsTVC", bundle: nil), forCellReuseIdentifier: "AnnouncmentsTVC")        }
    }
    
    //MARK: - Variable...
    var announcementsArr = [PressData]()
    
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Custom Methods...
    func setupUI(){
        tblAnnouncments.showsVerticalScrollIndicator = false
        tblAnnouncments.estimatedRowHeight = 100
        tblAnnouncments.rowHeight = UITableView.automaticDimension
    }
    
}


extension AnnouncementsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        announcementsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncmentsTVC", for: indexPath) as! AnnouncmentsTVC
        let report = announcementsArr[indexPath.row]
        cell.configure(with: report)
        cell.btnView.tag = indexPath.row
        cell.btnView.addTarget(self, action: #selector(ViewTap(_:)), for: .touchUpInside)
        return cell
    }
    
    @IBAction func ViewTap(_ sender : UIButton){
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "pdf"
        vc.pdfURL = announcementsArr[sender.tag].documentPath ?? ""
        vc.headerTitle = "View Pdf"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
