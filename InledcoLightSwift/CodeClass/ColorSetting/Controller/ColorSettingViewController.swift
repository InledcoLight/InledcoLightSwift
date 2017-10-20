//
//  ColorSettingViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/17.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class ColorSettingViewController: UIViewController {

    var parameterModel: DeviceParameterModel?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let manualView = ManualCircleView(frame: CGRect(x:0, y:128, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width), channelNum: 4, colorArray: nil, colorPercentArray: nil, colorTitleArray: nil)
        
        self.view.addSubview(manualView)
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
