//
//  ColorSettingViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/17.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import LGAlertView

class ColorSettingViewController: BaseViewController {

    var parameterModel: DeviceParameterModel?
    var manualAutoSwitchView: ManualAutoSwitchView?
    var manualModeView: UIView?
    var manualColorView: ManualCircleView?
    var manualPowerButton: UIButton?
    var manualAutoViewFrame: CGRect?
    var deviceInfo: DeviceCodeInfo?
    
    var autoModeView: UIView?
    var autoColorChartView: AutoColorChartView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /**
         * 布局划分
         * 1.手动和自动模式切换按钮
         * 2.手动界面
         * 3.自动界面
         */
        
        // Do any additional setup after loading the view.
        prepareData()
        setViews()
    }
    
    override func setViews() {
        super.setViews()
        // 1.查找和重命名
        let findButton = UIButton(frame: CGRect(x: 0, y: 2, width: 40, height: 40))
        findButton.setImage(UIImage.init(named: "findDevice"), for: .normal)
        findButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        findButton.addTarget(self, action: #selector(findDeviceAction(sender:)), for: .touchUpInside)
        let findItem = UIBarButtonItem.init(customView: findButton)
        
        let renameButton = UIButton(frame: CGRect(x: 0, y: 2, width: 40, height: 40))
        renameButton.setImage(UIImage.init(named: "rename"), for: .normal)
        renameButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        renameButton.addTarget(self, action: #selector(renameDeviceAction(sender:)), for: .touchUpInside)
        let renameItem = UIBarButtonItem.init(customView: renameButton)
        
        self.navigationItem.rightBarButtonItems = [findItem,renameItem];
        
        // 2.手动自动切换按钮
        let manualAutoSwitchViewFrame = CGRect(x: 0, y: 72, width: 150, height: 75)
        manualAutoSwitchView = ManualAutoSwitchView(frame: manualAutoSwitchViewFrame, manualTitle: self.languageManager.getTextForKey(key: "manualMode"), autoTitle: self.languageManager.getTextForKey(key: "autoMode"))
        
        manualAutoSwitchView?.center = CGPoint(x: SystemInfoTools.screenWidth / 2, y: (manualAutoSwitchView?.center.y)!)
        
        manualAutoSwitchView?.manualModeAction = {
            self.blueToothManager.sendManualModeCommand(uuid: (self.parameterModel?.uuid)!)
        }
        
        manualAutoSwitchView?.autoModeAction = {
            self.blueToothManager.sendAutoModeCommand(uuid: (self.parameterModel?.uuid)!)
        }
        
        manualAutoViewFrame = CGRect(x: 0, y: (manualAutoSwitchView?.frame.origin.y)! + (manualAutoSwitchView?.frame.size.height)! + 8, width: SystemInfoTools.screenWidth, height: SystemInfoTools.screenHeight - (manualAutoSwitchView?.frame.origin.y)! - (manualAutoSwitchView?.frame.size.height)! - 8)
        
        self.view.addSubview(manualAutoSwitchView!)
        
        setManualAutoViews()
    }
    
    @objc func findDeviceAction(sender: UIButton) -> Void {
        self.blueToothManager.sendFindDeviceCommand(uuid: (self.parameterModel?.uuid)!)
    }
    
    @objc func renameDeviceAction(sender: UIButton) -> Void {
        let renameDeviceAlert = LGAlertView.init(textFieldsAndTitle: self.languageManager.getTextForKey(key: "rename"), message: "", numberOfTextFields: 1, textFieldsSetupHandler: nil, buttonTitles: [self.languageManager.getTextForKey(key: "cancel"), self.languageManager.getTextForKey(key: "confirm")], cancelButtonTitle: "", destructiveButtonTitle: "")
        
        renameDeviceAlert?.actionHandler = {
            (alertView, title, index) in
            switch index {
            case 0:
                return
            case 1:
                // 1.同步到数据库
                
                // 2.同步到设备
                let textField = alertView?.textFieldsArray[0] as! UITextField
                self.blueToothManager.setDeviceName(uuid: (self.parameterModel?.uuid)!, name: textField.text)
                return
            default:
                return
            }
        }
        
        renameDeviceAlert?.show(animated: true, completionHandler: nil)
    }
    
    func setManualAutoViews() -> Void {
        if parameterModel?.runMode == DeviceRunMode.MANUAL_RUN_MODE {
            print("当前运行模式手动！")
            manualAutoSwitchView?.updateManualAutoSwitchView(index: 0)
            setManualModeViews()
        } else {
            print("当前运行模式自动！")
            manualAutoSwitchView?.updateManualAutoSwitchView(index: 1)
            setAutoModeViews()
        }
    }
    
    func setManualModeViews() -> Void {
        if self.autoModeView != nil {
            // 隐藏自动模式界面
            self.autoModeView?.isHidden = true
        }
        
        if manualModeView == nil {
            // 创建手动模式视图
            manualModeView = UIView(frame: manualAutoViewFrame!)
            manualModeView?.backgroundColor = UIColor.gray
            
            // 1.圆形调光视图
            let manualColorViewFrame = CGRect(x: 0, y: 16, width: SystemInfoTools.screenWidth - 50, height: SystemInfoTools.screenWidth - 50)
            var manualPercentArray = [Int]()
            for key in (parameterModel?.manualModeValueDic.keys)! {
                manualPercentArray.append((parameterModel?.manualModeValueDic[key]?.hexaToDecimal)!)
            }
            manualColorView = ManualCircleView(frame: manualColorViewFrame, channelNum: (parameterModel?.channelNum)!, colorArray: deviceInfo?.channelColorArray, colorPercentArray: manualPercentArray, colorTitleArray: deviceInfo?.channelColorTitleArray)
            manualColorView?.passColorValueCallback = {
                (colorIndex, colorValue) in
                    var commandStr = CommandHeader.COMMANDHEAD_FOUR.rawValue
                    for i in 0 ..< (self.parameterModel?.channelNum)! {
                        if i == colorIndex {
                            commandStr = commandStr.appendingFormat("%04x", colorValue)
                        } else {
                            commandStr.append("FFFF")
                        }
                    }
                self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: CommandType.UNKNOWN_COMMAND, isXORCommand: true)
            }
            
            manualModeView?.addSubview(manualColorView!)
            
            // 2.用户自定义按钮
            let userDefineViewFrame = CGRect(x: 0, y: (manualAutoViewFrame?.height)! - 70, width: SystemInfoTools.screenWidth, height: SystemInfoTools.screenHeight)
            let userDefineView = LayoutToolsView(viewNum: 3, viewWidth: 80, viewHeight: 50, viewInterval: 8, viewTitleArray: ["M1", "M2", "M3"], frame: userDefineViewFrame)
            userDefineView.buttonActionCallback = {
                (index) in
                var commandStr = CommandHeader.COMMANDHEAD_FOUR.rawValue
                let userColorStr = self.parameterModel?.userDefinedValueDic[index]
                commandStr.append((userColorStr?.convertUserPercentToHexColorValue())!)
                
                self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: .UNKNOWN_COMMAND, isXORCommand: true)
            }
            manualModeView?.addSubview(userDefineView)
            
            // 3.开关按钮
            let manualPowerButtonCenterY = (userDefineViewFrame.origin.y - manualColorViewFrame.origin.y - manualColorViewFrame.size.height) / 2.0
            manualPowerButton = UIButton(frame: CGRect(x: 0, y: manualColorViewFrame.origin.y + manualColorViewFrame.size.height + 8, width: 50, height: 50))
            manualPowerButton?.center = CGPoint(x: SystemInfoTools.screenWidth / 2.0, y: ((userDefineView.frame.origin.y) - manualPowerButtonCenterY))
            manualPowerButton?.setBackgroundImage(UIImage.init(named: "powerOff"), for: .normal)
            manualPowerButton?.setBackgroundImage(UIImage.init(named: "powerOn"), for: .selected)
            manualPowerButton?.addTarget(self, action: #selector(powerAction(sender:)), for: UIControlEvents.touchUpInside)
            if parameterModel?.powerState == DeviceState.POWER_ON {
                manualPowerButton?.isSelected = true
            } else {
                manualPowerButton?.isSelected = false
            }
            
            manualModeView?.addSubview(manualPowerButton!)

            self.view.addSubview(manualModeView!)
        } else {
            // 更新视图
            manualModeView?.isHidden = false
        }
    }
    
    /// 开关方法
    /// - parameter sender: 触发点击的按钮
    ///
    /// - returns:
    @objc func powerAction(sender: UIButton) -> Void {
        sender.isSelected = !sender.isSelected
        if parameterModel?.powerState == DeviceState.POWER_ON {
            self.blueToothManager.sendPowerOffCommand(uuid: (parameterModel?.uuid)!)
            parameterModel?.powerState = DeviceState.POWER_OFF
        } else {
            self.blueToothManager.sendPowerOnCommand(uuid: (parameterModel?.uuid)!)
            parameterModel?.powerState = DeviceState.POWER_ON
        }
    }
    
    /// 用户自定义方法:点击后把用户对应的设置设置到灯体
    /// - parameter sender:
    ///
    /// - returns:
    @objc func userDefineAction(sender: UIButton) -> Void {
        
    }
    
    func setAutoModeViews() -> Void {
        if self.manualModeView != nil {
            print("隐藏手动模式界面")
            self.manualModeView?.isHidden = true
        }
        
        if autoModeView == nil {
            // 创建自动模式视图
            autoModeView = UIView(frame: manualAutoViewFrame!)
            autoModeView?.backgroundColor = UIColor.gray
            
            // 1.自动模式曲线图
            let autoColorChartViewFrame = CGRect(x: 0, y: 0, width: (autoModeView?.frame.size.width)!, height: (autoModeView?.frame.size.width)!)
            autoColorChartView = AutoColorChartView(frame: autoColorChartViewFrame, channelNum: (parameterModel?.channelNum)!, colorArray:deviceInfo?.channelColorArray, colorTitleArray: deviceInfo?.channelColorTitleArray, timePointArray: parameterModel?.timePointArray, timePointValueDic: parameterModel?.timePointValueDic)
            
            autoModeView?.addSubview(autoColorChartView!)
            
            // 2.底部按钮 预览 运行（发送设置的配置到设备）编辑
            let bottomViewFrame = CGRect(x: 0, y: (autoModeView?.frame.size.height)! - 70, width: SystemInfoTools.screenWidth, height: 70)
            let bottomView = LayoutToolsView(viewNum: 3, viewWidth: 70, viewHeight: 50, viewInterval: 30, viewTitleArray: [self.languageManager.getTextForKey(key: "preview"), self.languageManager.getTextForKey(key: "run"), self.languageManager.getTextForKey(key: "edit")], frame: bottomViewFrame)
            
            bottomView.buttonActionCallback = {
                (buttonTag) -> Void in
                    if (buttonTag == 0) {
                        
                    } else if (buttonTag == 1) {
                        
                    } else {
                        // 3.跳转到编辑界面
                        let autoColorEditViewController = AutoColorEditViewController(nibName: "AutoColorEditViewController", bundle: Bundle.main)
                        
                        autoColorEditViewController.passParameterModelCallback = {
                            (deviceParameterModel) in
                            self.autoColorChartView?.updateGraph(channelNum: deviceParameterModel.channelNum!, colorArray: self.deviceInfo?.channelColorArray, colorTitleArray: self.deviceInfo?.channelColorTitleArray, timePointArray: deviceParameterModel.timePointArray, timePointValueDic: deviceParameterModel.timePointValueDic)
                        }
                        
                        autoColorEditViewController.parameterModel = self.parameterModel
                        self.navigationController?.pushViewController(autoColorEditViewController, animated: true)
                    }
            }
            
            autoModeView?.addSubview(bottomView)
            
            self.view.addSubview(autoModeView!)
        } else {
            // 更新自动模式视图
            autoModeView?.isHidden = false
        }
    }
    
    override func prepareData() {
        super.prepareData()
        deviceInfo = DeviceTypeData.getDeviceInfoWithTypeCode(deviceTypeCode: (parameterModel?.typeCode)!)
        self.blueToothManager.completeReceiveDataCallback = {
            (receivedDataStr) in
            self.blueToothManager.parseDeviceDataFromReceiveStrToModel(receiveData: receivedDataStr!, parameterModel: self.parameterModel!)
            // 更新界面
            self.setManualAutoViews()
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
