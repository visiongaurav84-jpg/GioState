//
//  IndiaMapView.swift
//  goistats
//
//  Created by getitrent on 24/09/25.
//


import UIKit
import SVGKit

class IndiaMapView: UIView, UIGestureRecognizerDelegate {
    
    private var statePaths: [String: UIBezierPath] = [:]
    private var stateData: [String: (Int, String)] = [:]
    private var unit: String = ""
    
    private var selectedState: String?
    
    private var scale: CGFloat = 1.0
    private var offset: CGPoint = .zero
    
    private var tooltipLabel: UILabel?
    
    private var svgImage: SVGKImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
        loadSVG()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestures()
        loadSVG()
    }
    
    private func setupGestures() {
        // Pan
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)
        
        // Pinch
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        addGestureRecognizer(pinch)
        
        // Tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    private func loadSVG() {
        guard let svg = SVGKImage(named: "india_map") else { return }
        svgImage = svg
        
        // Traverse CALayerTree to extract <path> elements
        extractPaths(from: svg.caLayerTree)
    }
    
    private func extractPaths(from layer: CALayer) {
        if let shapeLayer = layer as? CAShapeLayer,
           let path = shapeLayer.path {
            let bezier = UIBezierPath(cgPath: path)
            if let layerId = layer.value(forKey: "SVGElementIdentifier") as? String {
                statePaths[layerId] = bezier
            }
        }
        // Recursively process sublayers
        layer.sublayers?.forEach { extractPaths(from: $0) }
    }
    
    func updateStateData(data: [String: (Int, String)], dataUnit: String) {
        unit = dataUnit
        stateData = data
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard !statePaths.isEmpty else { return }
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        // Apply pan + zoom
        context?.translateBy(x: offset.x, y: offset.y)
        context?.scaleBy(x: scale, y: scale)
        
        for (id, path) in statePaths {
            let (percent, _) = stateData[id] ?? (0, "")
            let color = getStepColor(value: percent)
            color.setFill()
            path.fill()
            
            if id == selectedState {
                UIColor.systemRed.setStroke()
                path.lineWidth = 2.0
                path.stroke()
            }
        }
        
        context?.restoreGState()
    }
    
    // MARK: - Gestures
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        if gesture.state == .changed {
            offset.x += translation.x
            offset.y += translation.y
            gesture.setTranslation(.zero, in: self)
            setNeedsDisplay()
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            scale = max(0.5, min(scale, 5.0))
            gesture.scale = 1.0
            setNeedsDisplay()
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let touch = gesture.location(in: self)
        let mapX = (touch.x - offset.x) / scale
        let mapY = (touch.y - offset.y) / scale
        let tapPoint = CGPoint(x: mapX, y: mapY)
        
        var tappedState: String?
        
        for (id, path) in statePaths {
            if path.contains(tapPoint) {
                tappedState = id
                selectedState = id
                let (value, label) = stateData[id] ?? (0, "N/A")
                showTooltip(at: touch, text: "\(label)\nValue: \(unit) \(value)")
                break
            }
        }
        
        if tappedState == nil {
            selectedState = nil
            hideTooltip()
        }
        
        setNeedsDisplay()
    }
    
    // MARK: - Tooltip
    
    private func showTooltip(at point: CGPoint, text: String) {
        hideTooltip()
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.frame = CGRect(x: point.x, y: point.y - label.bounds.height - 10,
                             width: label.bounds.width + 20,
                             height: label.bounds.height + 10)
        
        addSubview(label)
        tooltipLabel = label
    }
    
    private func hideTooltip() {
        tooltipLabel?.removeFromSuperview()
        tooltipLabel = nil
    }
    
    // MARK: - Helpers
    
    private func getStepColor(value: Int) -> UIColor {
        switch value {
        case 0...999: return UIColor(hex: "#bed9ea")
        case 1000...1999: return UIColor(hex: "#aac9e0")
        case 2000...2999: return UIColor(hex: "#93b7d1")
        case 3000...3999: return UIColor(hex: "#7fadcc")
        case 4000...4999: return UIColor(hex: "#6288b7")
        case 5000...5999: return UIColor(hex: "#406191")
        case 6000...6999: return UIColor(hex: "#355077")
        case 7000...7999: return UIColor(hex: "#253863")
        case 8000...8999: return UIColor(hex: "#0e1b3f")
        case 9000...10000: return UIColor(hex: "#020826")
        default: return .gray
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}