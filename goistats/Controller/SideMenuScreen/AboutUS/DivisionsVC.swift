//
//  DivisionsVC.swift
//  goistats
//
//  Created by Gaurav Awasthi on 02/08/25.
//

import UIKit

class DivisionsVC: UIViewController {
    
    //MARK: - Outlets...
    @IBOutlet weak var tblDivision: UITableView!{
        didSet{
            tblDivision.register(UINib(nibName: "AboutUsTVC", bundle: nil), forCellReuseIdentifier: "AboutUsTVC")        }
    }
    
    //MARK: - Variable...
    var divisionArr = [DivisionDetails]()
    
    //MARK: - Life Cycle Methods...
    override func viewDidLoad() {
        super.viewDidLoad()
        divisionArr.sort {
            $0.divisionTitle?.localizedCaseInsensitiveCompare($1.divisionTitle ?? "") == .orderedAscending
        }
        self.setupUI()
    }
    
    //MARK: - Custom Methods...
    func setupUI(){
        tblDivision.showsVerticalScrollIndicator = false
        tblDivision.estimatedRowHeight = 44
        tblDivision.rowHeight = UITableView.automaticDimension
    }
}


extension DivisionsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        divisionArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutUsTVC", for: indexPath) as! AboutUsTVC
        let dict = divisionArr[indexPath.row]
        cell.configure(with: dict)
        cell.toggleExpand = { [weak self] in
            guard let self = self else { return }
            self.divisionArr[indexPath.row].isExpanded?.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
}
