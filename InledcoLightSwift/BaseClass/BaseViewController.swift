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
    var bleManager: BLEManager<AnyObject, AnyObject>! = BLEManager<AnyObject, AnyObject>.default()
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
