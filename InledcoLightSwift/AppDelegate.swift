//
//  AppDelegate.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/7/31.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchImageView: UIImageView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 实现启动动画，多张图片变换
        self.window?.makeKeyAndVisible()
        launchImageView = UIImageView.init(frame: (self.window?.bounds)!)
        
        launchImageView?.animationImages = [UIImage.init(named: "launch1.png")!, UIImage.init(named: "launch2.png")!, UIImage.init(named: "launch3.png")!, UIImage.init(named: "launch3.png")!, UIImage.init(named: "launch3.png")!] // 最后的图片多放几张可以让图片
        launchImageView?.animationDuration = 2.0  // 隐藏视图时，延迟时间和持续时间之和应该和这个持续时间相等
        launchImageView?.animationRepeatCount = 1
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveLinear, animations: {
            self.launchImageView?.stopAnimating()
            self.launchImageView?.alpha = 0.0
        }) { (finished) in
            self.launchImageView?.removeFromSuperview()
        }
        
        launchImageView?.startAnimating()
        
        self.window?.addSubview(launchImageView!)
        self.window?.bringSubview(toFront: launchImageView!)
        
        // 重置tab栏，防止tab栏语言出现问题
        LanguageManager.shareInstance().resetRootViewController()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

