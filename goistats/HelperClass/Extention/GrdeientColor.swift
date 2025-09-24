//
//  GrdeientColor.swift
//  SII
//
//  Created by Admin on 17/02/25.
//

import UIKit

class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        animateGradientColors()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
        animateGradientColors()
    }
    
    private func setupGradient() {
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.orange.cgColor, UIColor.orange.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
    }
    
    private func animateGradientColors() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = [UIColor.orange.cgColor, UIColor.white.cgColor]
        animation.toValue = [UIColor.white.cgColor, UIColor.orange.cgColor]
        animation.duration = 3.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "colorAnimation")
    }
}
