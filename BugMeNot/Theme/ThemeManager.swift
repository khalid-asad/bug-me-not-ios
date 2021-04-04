//
//  ThemeManager.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import Foundation
import PlatformCommon
import UIKit

struct ThemeManager {
        
    static var overrideDarkModeFlag: Bool? { true }
    
    static var isDarkMode: Bool {
        if let overrideDarkModeFlag = overrideDarkModeFlag {
            return overrideDarkModeFlag
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let sceneDelegate = windowScene.delegate as? SceneDelegate
        else { return false }
        let window = sceneDelegate.window
        return window?.traitCollection.userInterfaceStyle == .light || window?.traitCollection.userInterfaceStyle == .unspecified
    }
    
    // MARK: - Fonts
    static var headerFont: UIFont {
        guard let font = UIFont(name: "Helvetica-Bold", size: 32) else { return UIFont.systemFont(ofSize: 32, weight: .bold)}
        return font
    }
    
    static var subHeaderFont: UIFont {
        guard let font = UIFont(name: "Helvetica", size: 20) else { return UIFont.systemFont(ofSize: 20) }
        return font
    }
    
    static var titleFont: UIFont {
        guard let font = UIFont(name: "Avenir-Light", size: 18) else { return UIFont.systemFont(ofSize: 20, weight: .bold)}
        return font
    }
    
    static var boldTitleFont: UIFont {
        guard let font = UIFont(name: "Avenir-Medium", size: 18) else { return UIFont.systemFont(ofSize: 20, weight: .bold)}
        return font
    }
    
    static var subTitleFont: UIFont {
        guard let font = UIFont(name: "Avenir-Light", size: 14) else { return UIFont.systemFont(ofSize: 16)}
        return font
    }
    
    static var smallTitleFont: UIFont {
        guard let font = UIFont(name: "Avenir-Light", size: 12) else { return UIFont.systemFont(ofSize: 12)}
        return font
    }
    
    // MARK: - Colors
    static var darkColor: UIColor {
        UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0) /* #212121 */
    }
    
    static var lightColor: UIColor { .white }
        
    static var backgroundColor: UIColor {
        isDarkMode ? ThemeManager.darkColor : ThemeManager.lightColor
    }
    
    static var complementedColor: UIColor {
        isDarkMode ? ThemeManager.lightColor : ThemeManager.darkColor
    }
    
    static var navigationBarColor: UIColor {
        MaterialColor.red[.a700]
    }
    
    static var navigationBarTextColor: UIColor { .white }
    
    static var borderColor: UIColor { complementedColor }
    
    static var textColor: UIColor { complementedColor }
    
    static var tableViewCellColor: UIColor { .white }
}
