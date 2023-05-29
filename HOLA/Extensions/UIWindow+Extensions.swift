//
//  UIWindow+Extensions.swift
//  HOLY
//
//  Created by Клим Бакулин on 27.01.2023.
//


import UIKit

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
