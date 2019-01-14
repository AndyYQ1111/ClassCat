//
//  Global.swift
//  THSmart
//
//  Created by YueAndy on 2018/3/29.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit

let kS_W = UIScreen.main.bounds.size.width
let kS_H = UIScreen.main.bounds.size.height

var globalCity:String?
var globalProvince:String?

import Toast_Swift

class Global: NSObject {
    @objc static let shared = Global()
    
}



extension Global {
    @objc func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}
