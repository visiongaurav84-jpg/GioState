//
//  UIView+Extension.swift
//  USHA
//
//  Created by Hitesh Prajapati on 25/05/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import UIKit

extension UIView{
    
    var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    func setBorder(cornerRadius: CGFloat, borderColor : UIColor, borderWidth : CGFloat){
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.frame = self.bounds
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    func setAlpha(value : CGFloat, duration : TimeInterval = 0.3){
        UIView.animate(withDuration: duration) {
            self.alpha = value
        }
    }
    
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
    }
    
    func setThemeShadow() {
        layer.masksToBounds = false
        layer.shadowColor = AppColor.ShadowColor.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 5
    }
    
    func setGradient(colors : [CGColor]) {
        let gradient = CAGradientLayer()
        gradient.frame = self.frame
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.colors = colors
        self.layer.addSublayer(gradient)
    }
    
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
