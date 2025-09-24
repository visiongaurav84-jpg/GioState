//
//  NsoVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 03/08/25.
//

import UIKit

class NsoVC: UIViewController {
    
    @IBOutlet weak var tblNso: UITableView!{
        didSet{
            tblNso.register(UINib(nibName: "LeftHeaderTVC", bundle: nil), forCellReuseIdentifier: "LeftHeaderTVC")
            tblNso.register(UINib(nibName: "SecretaryTVC", bundle: nil), forCellReuseIdentifier: "SecretaryTVC")
            tblNso.register(UINib(nibName: "MiddleHeaderTVC", bundle: nil), forCellReuseIdentifier: "MiddleHeaderTVC")
            tblNso.register(UINib(nibName: "LederShipTVC", bundle: nil), forCellReuseIdentifier: "LederShipTVC")
            tblNso.register(UINib(nibName: "ContentTVC", bundle: nil), forCellReuseIdentifier: "ContentTVC")
        }
    }
    
    var secretary: Secretary?
    var aboutNSO: AboutNSO?
    var nsoLeadership: [NSOLeadership]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblNso.showsVerticalScrollIndicator = false
        tblNso.showsHorizontalScrollIndicator = false
    }
    
    @IBAction func moreDetailsClick(_ sender: Any) {
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "web"
        vc.pdfURL = ApiUrl.mospiWebsiteURL
        vc.headerTitle = "MoSPI Website"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension NsoVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 1
        }else{
            return nsoLeadership?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTVC", for: indexPath) as! ContentTVC
            cell.onHeightChange = { [weak self] in
                self?.tblNso.beginUpdates()
                self?.tblNso.endUpdates()
            }
            cell.configure(with: self.aboutNSO?.aboutNSO ?? "")
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecretaryTVC", for: indexPath) as! SecretaryTVC
            if let secretary = self.secretary {
                cell.configure(with: secretary)
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LederShipTVC", for: indexPath) as! LederShipTVC
            let dict = self.nsoLeadership![indexPath.row]
            cell.configure(with: dict)
            if indexPath.row == (nsoLeadership?.count ?? 0)-1{
                cell.lblSeprater.isHidden = true
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeftHeaderTVC") as! LeftHeaderTVC
            cell.configure(with: "NATIONAL STATISTICS OFFICE")
            return cell.contentView
        }else if section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeftHeaderTVC") as! LeftHeaderTVC
            cell.configure(with: "")
            return cell.contentView
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MiddleHeaderTVC") as! MiddleHeaderTVC
            cell.configure(with: "DIRECTORS GENERAL")
            return cell.contentView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 30
        }else if section == 1{
            return 0
        }else{
            return 50
        }
    }
    
    
}
