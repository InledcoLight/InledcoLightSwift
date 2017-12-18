//
//  LanguageManager.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/12.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class LanguageManager {
    
    // 语言定义
    enum LanguageFlag: String {
        case auto = "auto"
        case english = "en"
        case french = "fr"
        case chinese = "zh-Hans"
    }
    
    // 用户保存标记
    private var languageFilePath: String?
    private var bundle: Bundle?
    private var currentLanguageFlag: LanguageFlag! = .auto
    static var single: LanguageManager!
    private let userLangDefineFlag: String = "userLangSetFlag"
    
    /// 语言管理工具单利类
    ///
    /// - returns: 语言管理对象
    static func shareInstance() -> LanguageManager {
        if single === nil {
            single = initLanguageToolManager()
        }
        
        return single
    }
    
    /// 初始化语言管理配置
    ///
    /// - returns: 语言管理对象
    static func initLanguageToolManager() -> LanguageManager {
        // 初始化单例对象
        single = LanguageManager()

        // 用户已设置，或者已读取当前系统语言
        single.currentLanguageFlag = single.getCurrentLanguageFlag()
        single.languageFilePath = Bundle.main.path(forResource: single.currentLanguageFlag.rawValue, ofType: "lproj")
        if single.languageFilePath == nil {
            single.bundle = nil
        } else {
            single.bundle = Bundle.init(path: single.languageFilePath!)
        }

        return single
    }
    
    /// 获取当前语言标记
    ///
    /// - returns: 当前语言标记
    func getCurrentLanguageFlag() -> LanguageFlag! {
        // 1.获取用户设置的语言
        let languageStr = UserDefaults.standard.object(forKey: self.userLangDefineFlag) as? String
        switch languageStr {
        case LanguageFlag.auto.rawValue?:
            return LanguageFlag.auto
        case LanguageFlag.english.rawValue?:
            return LanguageFlag.english
        case LanguageFlag.french.rawValue?:
            return LanguageFlag.french
        case LanguageFlag.chinese.rawValue?:
            return LanguageFlag.chinese
        default:
            return LanguageFlag.auto
        }
    }
    
    /// 获取语言文件中键值对应的文本
    /// - parameter key: 键值
    ///
    /// - returns: 键值对应的文本
    func getTextForKey(key: String) -> String {
        return getTextForKeyAndTable(key: key, table: nil);
    }
    
    /// 根据文件文件名和键值获取对应语言文本
    /// - parameter key: 语言文本键值
    /// - parameter table: 本地化语言文件名称
    ///
    /// - returns: 键值对应的文本信息
    func getTextForKeyAndTable(key: String, table: String?) -> String {
        if self.bundle != nil {
            return (self.bundle?.localizedString(forKey: key, value: nil, table: table))!
        }
        
        return Bundle.main.localizedString(forKey: key, value: nil, table: table)
    }
    
    /// 设置用户语言
    /// - parameter language: 表示语言的枚举
    ///
    /// - returns: void
    func setUserLanguage(language: LanguageFlag!) -> Void {
        // 1.如果用户设置和当前设置相同，则直接返回
        if language == self.currentLanguageFlag {
            resetRootViewController()
            return
        }
        
        // 2.如果不同，则设置新语言
        if language.rawValue == LanguageFlag.auto.rawValue {
            // 如果选择的是自动，则删除用户的设置
            UserDefaults.standard.removeObject(forKey: self.userLangDefineFlag)
            self.languageFilePath = nil
            self.bundle = nil
        } else {
            self.languageFilePath = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
            self.bundle = Bundle.init(path: self.languageFilePath!)
            UserDefaults.standard.setValue(language.rawValue, forKey: self.userLangDefineFlag)
        }
        
        UserDefaults.standard.synchronize()
        
        // 3.重新获取当前设置
        self.currentLanguageFlag = self.getCurrentLanguageFlag()
        // 4.重置视图控制器
        resetRootViewController()
    }
    
    /// 设置语言后，重置根视图控制器
    //
    /// - returns:
    func resetRootViewController() {
        // 获取应用程序代理
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // 获取主应用程序代理
        let mainStoryboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        // 获取tabcontroller
        let tabViewController = appDelegate.window?.rootViewController as! UITabBarController
        // 获取各个导航控制器
        let homeNav = mainStoryboard.instantiateViewController(withIdentifier: "homeNav")
        homeNav.title = getTextForKey(key: "home")
        let settingNav = mainStoryboard.instantiateViewController(withIdentifier: "settingNav")
        settingNav.title = getTextForKey(key: "settingTitle")
        tabViewController.viewControllers = [homeNav, settingNav]
    }
}
