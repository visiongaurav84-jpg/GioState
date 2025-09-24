//
//  PressReleasesVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class PressReleasesVC: UIViewController {
    
    //MARK: - Outlets...
    @IBOutlet weak var tblPressReleases: UITableView!{
        didSet{
            tblPressReleases.register(UINib(nibName: "PressReleaseTVC", bundle: nil), forCellReuseIdentifier: "PressReleaseTVC")        }
    }
    
    //MARK: - Variable...
    var pressReleaseArr = [PressData]()
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Custom Methods...
    func setupUI(){
        tblPressReleases.showsVerticalScrollIndicator = false
        tblPressReleases.estimatedRowHeight = 100
        tblPressReleases.rowHeight = UITableView.automaticDimension
    }
    
}


extension PressReleasesVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pressReleaseArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PressReleaseTVC", for: indexPath) as! PressReleaseTVC
        let report = pressReleaseArr[indexPath.row]
        cell.configure(with: report)
        cell.toggleExpand = { [weak self] in
            guard let self = self else { return }
            self.pressReleaseArr[indexPath.row].isExpanded?.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.btnView.tag = indexPath.row
        cell.btnView.addTarget(self, action: #selector(ViewTap(_:)), for: .touchUpInside)
        return cell
    }
    
    @IBAction func ViewTap(_ sender : UIButton){
        let vc = SideMenuStoryboard.instantiateViewController(withIdentifier: "PdfViewVC") as! PdfViewVC
        vc.type = "pdf"
        vc.pdfURL = pressReleaseArr[sender.tag].documentPath ?? ""
        vc.headerTitle = "View Pdf"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

