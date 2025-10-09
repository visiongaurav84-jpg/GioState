//
//  ProductDataTVC.swift
//  goistats
//
//  Created by getitrent on 01/08/25.
//

import UIKit

class MapDataTVC: UITableViewCell {
    
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblPeriod: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with item: ResponseItem) {
        self.lblPeriod.text = item.state ?? "--"
        
        if let indicatorValueStr = item.indicator1Val,
           let indicatorValue = Double(indicatorValueStr) {
            self.lblValue.text = formatNumber(indicatorValue)
        } else {
            self.lblValue.text = formatNumber(0.0)
        }
        
        self.lblUnit.text = item.unit ?? "--"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func safeString(_ value: Any?) -> String? {
        guard let str = value as? String else { return nil }
        let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    
    func formatNumber(_ value: Double) -> String {
        // Determine decimal part length
        let decimalPart = String(value).split(separator: ".").dropFirst().first
        let decimalDigits = decimalPart?.count ?? 0
        
        let maxDecimals = min(decimalDigits, 3)
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_IN")
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        // Correct grouping for Indian format
        formatter.groupingSize = 3               // rightmost group (321)
        formatter.secondaryGroupingSize = 2      // groups to the left (1,55,321)
        
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = maxDecimals
        formatter.minimumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
}
