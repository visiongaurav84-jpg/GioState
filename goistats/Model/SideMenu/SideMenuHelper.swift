//
//  SideMenuHelper.swift
//  goistats
//
//  Created by Mahendra Bohra on 18/07/25.
//

import Foundation

class SideMenuHelper {
    
    static let arraySideMenu: [NSDictionary] = [
        [
            "title": "Home",
            "image": "home",
            "subMenu": []
        ],
        [
            "title": "About Us",
            "image": "about_us",
            "subMenu": [
                ["title": "Organogram", "image": "organogram"],
                ["title": "Divisions of MoSPI", "image": "divisions_of_mospi"]
            ]
        ],
        [
            "title": "Reports and Publications",
            "image": "reports_and_publications",
            "subMenu": []
        ],
        [
            "title": "What's New",
            "image": "whats_new",
            "subMenu": [
                ["title": "Press Releases", "image": "press_release"],
                ["title": "Announcements", "image": "announcement"]
            ]
        ],
        [
            "title": "Advance Release Calendar",
            "image": "advance_calender",
            "subMenu": []
        ],
        [
            "title": "User Guide",
            "image": "user_guide",
            "subMenu": []
        ],
        [
            "title": "Contact Us",
            "image": "contact_us",
            "subMenu": []
        ],
        [
            "title": "Feedback",
            "image": "feedback",
            "subMenu": []
        ],
        [
            "title": "Terms of Use & Privacy Policy",
            "image": "terms_and_condition",
            "subMenu": []
        ]
    ]
    
    class func getSideMenuOptions() -> [SideMenu]{
        return arraySideMenu.map(SideMenu.init)
    }
}

class SideMenu: NSObject {
    let title : String
    let image : String
    var subMenu = [SubMenu]()
    var isOpen = false  //to handle toggle section
    
    init(dict : NSDictionary) {
        self.title = dict["title"] as! String
        self.image = dict["image"] as! String
        if let subMenu = dict["subMenu"] as? [NSDictionary]{
            self.subMenu = subMenu.map(SubMenu.init)
        }
    }
}

class SubMenu: NSObject {
    let title : String
    let image : String
    
    init(dict : NSDictionary) {
        self.title = dict["title"] as! String
        self.image = dict["image"] as! String
    }
}










