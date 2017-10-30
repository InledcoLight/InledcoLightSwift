//
//  BaseViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/4.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // 声明为不会为空
    let blueToothManager: BlueToothManager! = BlueToothManager.sharedBluetoothManager()
    let languageManager: LanguageManager! = LanguageManager.shareInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // 声明两个方法，控制器重写
    func prepareData(){
        // 不能写任何代码，供子类重写使用
    }
    
    func setViews() {
        // 不能写任何代码，供子类重写使用
    }
    
    /// 显示指定时间的提示框
    /// - parameter title: 标题
    /// - parameter time: 显示时间
    /// - parameter isShow: 是否显示提示
    ///
    /// - returns:
    func showMessageWithTitle(title: String!, time: Double!, isShow: Bool!) -> Void {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        backView.tag = 10000001
        if self.view.viewWithTag(10000001) != nil {
            return
        }
        
        let titleLabel = UILabel(frame: backView.frame)
        
        titleLabel.text = title;
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        titleLabel.textAlignment = .center;
        backView.addSubview(titleLabel)
        
        backView.layer.cornerRadius = 3;
        backView.backgroundColor = UIColor.gray
        backView.center = self.view.center;
        
        self.view.addSubview(backView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            backView.removeFromSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
