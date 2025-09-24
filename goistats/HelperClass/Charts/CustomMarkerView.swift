//
//  CustomMarkerView.swift
//  goistats
//
//  Created by getitrent on 05/08/25.
//


import UIKit
import DGCharts

class CustomMarkerView: MarkerView {
    
    private var labelYear: UILabel!
    private var labelValue: UILabel!
    private var backgroundCard: UIView!
    
    private let years: [String]
    private let chart: LineChartView
    private let unit: String
    
    init(frame: CGRect, years: [String], chart: LineChartView, unit: String) {
        self.years = years
        self.chart = chart
        self.unit = unit
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundCard = UIView(frame: bounds)
        backgroundCard.backgroundColor = UIColor.textColorOneBlueToYellow
        backgroundCard.layer.cornerRadius = 8
        backgroundCard.layer.masksToBounds = true
        addSubview(backgroundCard)
        
        labelYear = UILabel()
        labelYear.font = .systemFont(ofSize: 10, weight: .semibold)
        labelYear.textColor = UIColor.textColorSixWhiteToBlack
        
        labelValue = UILabel()
        labelValue.font = .systemFont(ofSize: 10, weight: .semibold)
        labelValue.textColor = UIColor.textColorSixWhiteToBlack
        
        let stack = UIStackView(arrangedSubviews: [labelYear, labelValue])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundCard.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: backgroundCard.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: backgroundCard.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: backgroundCard.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: backgroundCard.trailingAnchor, constant: -12)
        ])
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(entry.x.rounded())
        let rawData = entry.data
        let doubleValue: Double
        
        if let num = rawData as? NSNumber {
            doubleValue = num.doubleValue
        } else if let str = rawData as? String, let val = Double(str) {
            doubleValue = val
        } else {
            doubleValue = entry.y
        }
        
        if years.indices.contains(index) {
            labelYear.text = "Year: \(years[index])"
            labelValue.text = "Value: \(formatNumber(doubleValue)) \(unit)"
            
            // Match dataset color
            if let dataSet = chart.data?.dataSets[highlight.dataSetIndex] {
                backgroundCard.backgroundColor = dataSet.colors.first ?? .systemBlue
            }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let markerWidth = self.bounds.size.width
        let markerHeight = self.bounds.size.height
        let chartWidth = chart.bounds.size.width
        let chartHeight = chart.bounds.size.height
        
        let offsetX: CGFloat
        if point.x + markerWidth / 2 > chartWidth {
            offsetX = -markerWidth // Right edge
        } else if point.x - markerWidth / 2 < 0 {
            offsetX = 0 // Left edge
        } else {
            offsetX = -markerWidth / 2 // Centered
        }
        
        let offsetY: CGFloat = point.y < markerHeight ? 0 : -markerHeight
        return CGPoint(x: offsetX, y: offsetY)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundCard.frame = bounds
    }
    
    // Indian-style number formatter (e.g., 12,34,567.89)
    func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_IN")
        formatter.numberStyle = .decimal
        
        // Show up to 3 decimal places if needed
        let decimals = String(format: "%.6f", value)
            .split(separator: ".")
            .last?
            .prefix(3)
            .trimmingCharacters(in: CharacterSet(charactersIn: "0")) ?? ""
        
        formatter.maximumFractionDigits = decimals.count
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
