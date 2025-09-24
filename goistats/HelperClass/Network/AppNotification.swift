//
//  AppNotification.swift
//  USHA
//
//  Created by Hitesh Prajapati on 25/05/20.
//  Copyright © 2020 Devstree. All rights reserved.
//

import NotificationBannerSwift

class AppNotification {
    
    static var isDisplaying: Bool {
        get {
            return currentBanner?.isDisplaying ?? false
        }
    }
    
    static weak var currentBanner: FloatingNotificationBanner?
    
    static func showBanner(_ banner: FloatingNotificationBanner) {
        //banner.show(queuePosition: QueuePosition.front, bannerPosition: BannerPosition.top, cornerRadius: 10, shadowBlurRadius: 10, shadowCornerRadius: 10)
        banner.show()
    }
    
    static func showWarningMessage(title: String? = nil, _ message: String) {
        let banner = FloatingNotificationBanner(title: title, subtitle: message, style: .warning)
        currentBanner?.dismiss()
        currentBanner = banner
        showBanner(banner)
    }
    
    static func showSuccessMessage(title: String? = nil, _ message: String) {
        let banner = FloatingNotificationBanner(title: title, subtitle: message, style: .success)
        currentBanner?.dismiss()
        currentBanner = banner
        showBanner(banner)
    }
    
    static func showInfoMessage(title: String? = nil, _ message: String) {
        let banner = FloatingNotificationBanner(title: title, subtitle: message, style: .info)
        currentBanner?.dismiss()
        currentBanner = banner
        showBanner(banner)
    }
    
    static func showErrorMessage(title: String? = nil, _ message: String) {
        let banner = FloatingNotificationBanner(title: title, subtitle: message, style: .danger)
        currentBanner?.dismiss()
        currentBanner = banner
        showBanner(banner)
    }
}
