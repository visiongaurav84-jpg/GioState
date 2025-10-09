import UIKit
import PocketSVG

class IndiaMapView: UIView, UIGestureRecognizerDelegate {

    private var statePaths: [String: SVGBezierPath] = [:]
    private var stateData: [String: (Int, String)] = [:]
    private var unit: String = ""

    private var selectedState: String?

    private var scale: CGFloat = 0.1  // initial 10%
    private var offset: CGPoint = .zero

    private var tooltipLabel: UILabel?
    
    private var mapBounds: CGRect = .zero
    
    private var isScrollable: Bool = false

    // MARK: - Init
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

    // MARK: - Gesture Setup
    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        addGestureRecognizer(pinch)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    // MARK: - Load SVG via PocketSVG
    private func loadSVG() {
        guard let svgURL = Bundle.main.url(forResource: "india_map", withExtension: "svg") else { return }

        let paths = SVGBezierPath.pathsFromSVG(at: svgURL)
        statePaths.removeAll()

        for path in paths {
            if let id = path.svgAttributes["id"] as? String {
                statePaths[id] = path
            }
        }

        guard !statePaths.isEmpty else { return }

        // Combine all paths to get map bounds
        let combined = UIBezierPath()
        for path in statePaths.values { combined.append(path) }
        mapBounds = combined.bounds

        let padding: CGFloat = 20
        let viewWidth = bounds.width - 2 * padding
        let viewHeight = bounds.height - 2 * padding

        // Scale to fit both width and height
        let scaleX = viewWidth / mapBounds.width
        let scaleY = viewHeight / mapBounds.height
        let fitScale = min(scaleX, scaleY)

        // Apply optional zoom factor (like 1.2)
        scale = fitScale * 1.2

        // Now calculate offset to center the scaled map
        let mapWidthScaled = mapBounds.width * scale
        let mapHeightScaled = mapBounds.height * scale

        // Horizontal offset: center the map inside the view width
        let offsetX: CGFloat
        if mapWidthScaled <= bounds.width {
            // If map smaller than view, center it
            offsetX = (bounds.width - mapWidthScaled) / 2 - mapBounds.minX * scale
        } else {
            // If map larger than view, allow it to start from padding
            offsetX = padding - mapBounds.minX * scale
        }

        // Vertical offset: center inside view height
        let offsetY: CGFloat
        if mapHeightScaled <= bounds.height {
            offsetY = (bounds.height - mapHeightScaled) / 2 - mapBounds.minY * scale
        } else {
            offsetY = padding - mapBounds.minY * scale
        }

        offset = CGPoint(x: offsetX, y: offsetY)

        setNeedsDisplay()
    }

    // MARK: - Update state data
    func updateStateData(data: [String: (Int, String)], dataUnit: String) {
        unit = dataUnit
        stateData = data
        setNeedsDisplay()
    }

    // MARK: - Draw map
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        
        context.saveGState()
        context.translateBy(x: offset.x, y: offset.y)
        context.scaleBy(x: scale, y: scale)

        for (id, path) in statePaths {
            let (value, _) = stateData[id] ?? (0, "")
            let color = getStepColor(value: value)
            color.setFill()
            path.fill()

            if id == selectedState {
                if let highlightColor = UIColor(named: "map_line_color") {
                    highlightColor.setStroke()
                } else {
                    UIColor.red.setStroke() // fallback if asset not found
                }
                path.lineWidth = 1.0 / scale
                path.stroke()
            }
        }

        context.restoreGState()
    }

    // MARK: - Gestures
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard isScrollable else { return } // only allow if zoomed

        let translation = gesture.translation(in: self)
        offset.x += translation.x
        offset.y += translation.y
        gesture.setTranslation(.zero, in: self)
        setNeedsDisplay()
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let location = gesture.location(in: self)
        let oldScale = scale
        scale *= gesture.scale

        let fitScale = min((bounds.width - 40)/mapBounds.width,
                           (bounds.height - 40)/mapBounds.height)

        // Limit zoom
        scale = max(fitScale, min(scale, 10.0))
        
        // Enable scroll only if zoomed in
        isScrollable = scale > fitScale

        let deltaScale = scale / oldScale
        offset.x = location.x - deltaScale * (location.x - offset.x)
        offset.y = location.y - deltaScale * (location.y - offset.y)

        gesture.scale = 1.0
        setNeedsDisplay()
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        let mapX = (point.x - offset.x) / scale
        let mapY = (point.y - offset.y) / scale
        let tapPoint = CGPoint(x: mapX, y: mapY)

        var tapped: String?
        for (id, path) in statePaths {
            if path.contains(tapPoint) {
                tapped = id
                selectedState = id
                let (value, label) = stateData[id] ?? (0, "N/A")
                showTooltip(at: point, text: "\(label)\nValue: \(unit) \(value)")
                break
            }
        }

        if tapped == nil {
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
        // Fetch colors from assets
           if let textColor = UIColor(named: "TextColorSixWhiteToBlack") {
               label.textColor = textColor
           } else {
               label.textColor = .white // fallback
           }

           if let bgColor = UIColor(named: "tool_tip_color") {
               label.backgroundColor = bgColor
           } else {
               label.backgroundColor = UIColor.black.withAlphaComponent(0.8) // fallback
           }
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true

        let padding: CGFloat = 10
        let tooltipWidth = label.bounds.width + padding
        let tooltipHeight = label.bounds.height + padding

        // Fixed position: 50 from top, 180 from right
        let xPosition = bounds.width - tooltipWidth - 50
        let yPosition: CGFloat = 50

        label.frame = CGRect(
            x: xPosition,
            y: yPosition,
            width: tooltipWidth,
            height: tooltipHeight
        )

        addSubview(label)
        tooltipLabel = label
    }

    private func hideTooltip() {
        tooltipLabel?.removeFromSuperview()
        tooltipLabel = nil
    }

    // MARK: - Color Helper
    private func getStepColor(value: Int) -> UIColor {
        switch value {
        case 0...999: return UIColor(hex: "#b7ebf7")       // light blue
        case 1000...1999: return UIColor(hex: "#92d9ea")
        case 2000...2999: return UIColor(hex: "#74c3e2")
        case 3000...3999: return UIColor(hex: "#5caed6")
        case 4000...4999: return UIColor(hex: "#4b99c9")
        case 5000...5999: return UIColor(hex: "#327ead")
        case 6000...6999: return UIColor(hex: "#296499")
        case 7000...7999: return UIColor(hex: "#1c4e84")
        case 8000...8999: return UIColor(hex: "#113468")
        case 9000...10000: return UIColor(hex: "#0b2256")
        case 10000...11000: return UIColor(hex: "#08153a") // dark blue
        default: return UIColor(hex: "#020826")            // dark blue fallback
        }
    }
    
    func resetZoom() {
        guard !statePaths.isEmpty else { return }

        let padding: CGFloat = 20
        let scaleX = (bounds.width - 2*padding) / mapBounds.width
        let scaleY = (bounds.height - 2*padding) / mapBounds.height
        let fitScale = min(scaleX, scaleY)

        scale = fitScale * 1.0 // match your initial zoom factor

        let mapWidthScaled = mapBounds.width * scale
        let mapHeightScaled = mapBounds.height * scale

        // Center map
        offset = CGPoint(
            x: (bounds.width - mapWidthScaled) / 2 - mapBounds.minX * scale,
            y: (bounds.height - mapHeightScaled) / 2 - mapBounds.minY * scale
        )

        // Disable scroll since map fits inside view
        isScrollable = false

        setNeedsDisplay()
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


