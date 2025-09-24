//
//  TrendingProductCVC.swift
//  SII
//
//  Created by Admin on 11/04/25.
//

import UIKit
import DGCharts

class TrendingProductCVC: UICollectionViewCell {
    
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var viewForLineChart: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: TopProductListResponse) {
        
        //Shorting the indicator map alphabaticlly
        let indicatorValue = item.indicatorList?["Indicator1"] ?? ""
        
        lblProductName.text = indicatorValue
        lblPeriod.text = item.valueDate
        
        lblSource.text = "Source: \(item.productDescription ?? "")"
        
        let percentage = item.productAggregateValue ?? ""
        let components = percentage.components(separatedBy: ",")
        
        if components.count >= 2 {
            lblPercentage.text = components[0].trimmingCharacters(in: .whitespaces) + "\n" + components[1].trimmingCharacters(in: .whitespaces)
        } else {
            lblPercentage.text = percentage
        }
        
        //Disabled user interection with chart
        viewForLineChart.isUserInteractionEnabled = false
        
        // Enable and style Y-axis (left)
        viewForLineChart.leftAxis.enabled = true
        viewForLineChart.leftAxis.drawAxisLineEnabled = false // show Y axis line
        viewForLineChart.leftAxis.axisLineColor = .black
        viewForLineChart.leftAxis.axisLineWidth = 2.0  // <- Thicker line
        viewForLineChart.leftAxis.drawLabelsEnabled = false // hide Y-axis numbers
        viewForLineChart.leftAxis.drawGridLinesEnabled = false
        
        // Disable right Y-axis
        viewForLineChart.rightAxis.enabled = false
        
        // Enable and style X-axis
        viewForLineChart.xAxis.enabled = true
        viewForLineChart.xAxis.drawAxisLineEnabled = true // show X axis line
        viewForLineChart.xAxis.axisLineColor = .graphBottomLine
        viewForLineChart.xAxis.axisLineWidth = 1.0  // <- Thicker line
        viewForLineChart.xAxis.labelPosition = .bottom
        viewForLineChart.xAxis.drawLabelsEnabled = false // hide X-axis numbers
        viewForLineChart.xAxis.drawGridLinesEnabled = false
        
        // Keep the legend
        viewForLineChart.legend.enabled = true
        viewForLineChart.legend.textColor = NSUIColor.textColorThreeBlackToYellow
        viewForLineChart.legend.form = .circle
        
        // Animation
        viewForLineChart.animate(xAxisDuration: 1.5)
        
        var lineEntries: [ChartDataEntry] = []
        
        guard let responseList = item.data?.response else { return }
        
        for (index, item) in responseList.enumerated() {
            if let valueString = item["Indicator1_val"], let value = Float(valueString) {
                let x = Double(index)
                let y = Double(value)
                
                lineEntries.append(ChartDataEntry(x: x, y: y))
            }
        }
        
        
        let dataSet = LineChartDataSet(entries: lineEntries, label: indicatorValue)
        dataSet.colors = [NSUIColor.graphLine]
        dataSet.circleColors = [NSUIColor.graphLine]
        dataSet.circleHoleColor = .graphDot
        dataSet.circleHoleRadius = 2
        dataSet.circleRadius = 3.5
        dataSet.lineWidth = 2
        
        // Smooth curve
        dataSet.mode = .linear
        dataSet.drawValuesEnabled = false // Hide value labels on points
        
        let lineData = LineChartData(dataSet: dataSet)
        viewForLineChart.data = lineData
        
    }
    
}
