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
    var editParameterModel: DeviceParameterModel?
    var manualAutoSwitchView: ManualAutoSwitchView?
    var manualModeView: UIView?
    var manualColorView: ManualCircleView?
    var manualPowerButton: UIButton?
    var manualAutoViewFrame: CGRect?
    var deviceInfo: DeviceCodeInfo?
    var isShowSaveSuccessful: Bool! = true
    var quickPreviewTimer: Timer?
    var previewCount: Int! = 0
    var autoModeView: UIView?
    var autoColorChartView: AutoColorChartView?
    var timeCountArray: [Int]! = [Int]()
    var timeCountIntervalArray: [Int]! = [Int]()
    var previewButton: UIButton?
    var devcieName: String?
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.cancelPreview()
    }
    
    override func prepareData() {
        super.prepareData()
        
        deviceInfo = DeviceTypeData.getDeviceInfoWithTypeCode(deviceTypeCode: (parameterModel?.typeCode)!)
        self.blueToothManager.completeReceiveDataCallback = {
            (receivedDataStr, commandType) in
            self.parameterModel?.parseOldDeviceDataFromReceiveStrToModel(receiveData: receivedDataStr!)
            
            // 提示保存当前设置成功
            if commandType == CommandType.SETTINGUSERDEFINED_COMMAND {
                // 用户自定义数据成功
                self.showMessageWithTitle(title: self.languageManager.getTextForKey(key: "saveUserDefinedSuccessful"), time: 1.5, isShow: true)
            } else if commandType == CommandType.SETTINGAUTOMODE_COMMAND {
                // 更新数据：发送自动模式数据成功
                self.parameterModel = self.editParameterModel
                self.showMessageWithTitle(title: self.languageManager.getTextForKey(key: "runSuccessful"), time: 1.5, isShow: true)
            }
            
            // 更新界面
            self.setManualAutoViews()
        }
    }
    
    override func setViews() {
        super.setViews()
        self.title = self.devcieName!
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
            self.cancelPreview()
            self.editParameterModel = nil
            self.blueToothManager.sendManualModeCommand(uuid: (self.parameterModel?.uuid)!)
        }
        
        manualAutoSwitchView?.autoModeAction = {
            self.cancelPreview()
            self.blueToothManager.sendAutoModeCommand(uuid: (self.parameterModel?.uuid)!)
        }
        
        manualAutoViewFrame = CGRect(x: 0, y: (manualAutoSwitchView?.frame.origin.y)! + (manualAutoSwitchView?.frame.size.height)! + 8, width: SystemInfoTools.screenWidth, height: SystemInfoTools.screenHeight - (manualAutoSwitchView?.frame.origin.y)! - (manualAutoSwitchView?.frame.size.height)! - 8)
        
        self.view.addSubview(manualAutoSwitchView!)
        
        setManualAutoViews()
    }
    
    @objc func findDeviceAction(sender: UIButton) -> Void {
        self.cancelPreview()
        self.blueToothManager.sendFindDeviceCommand(uuid: (self.parameterModel?.uuid)!)
    }
    
    @objc func renameDeviceAction(sender: UIButton) -> Void {
        self.cancelPreview()
        let renameDeviceAlert = LGAlertView.init(textFieldsAndTitle: self.languageManager.getTextForKey(key: "rename"), message: "", numberOfTextFields: 1, textFieldsSetupHandler: nil, buttonTitles: [self.languageManager.getTextForKey(key: "cancel"), self.languageManager.getTextForKey(key: "confirm")], cancelButtonTitle: "", destructiveButtonTitle: "")
        
        let nameTextField = renameDeviceAlert?.textFieldsArray[0] as! UITextField
        nameTextField.text = self.devcieName!
        
        renameDeviceAlert?.actionHandler = {
            (alertView, title, index) in
            switch index {
            case 0:
                return
            case 1:
                let textField = alertView?.textFieldsArray[0] as! UITextField
                // 1.同步到数据库
                DeviceDataCoreManager.setDataWithFromTableWithCol(tableName: DeviceDataCoreManager.deviceTableName, colConditionName: DeviceDataCoreManager.deviceTableUuidName, colConditionVal: (self.parameterModel?.uuid)!, colName: DeviceDataCoreManager.deviceTableNameName, newColVal: textField.text!)
                
                // 2.同步到设备
                self.blueToothManager.setDeviceName(uuid: (self.parameterModel?.uuid)!, name: textField.text)
                
                // 3.更改标题
                self.title = textField.text
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
        
        let manualPercentArray = getManualColorPercentArray(parameterModel: self.parameterModel)
        if manualModeView == nil {
            // 创建手动模式视图
            manualModeView = UIView(frame: manualAutoViewFrame!)
            manualModeView?.backgroundColor = UIColor.clear
            
            // 1.圆形调光视图
            let manualColorViewFrame = CGRect(x: 0, y: 16, width: SystemInfoTools.screenWidth - 50, height: SystemInfoTools.screenWidth - 50)
            manualColorView = ManualCircleView(frame: manualColorViewFrame, channelNum: (parameterModel?.channelNum)!, colorArray: deviceInfo?.channelColorArray, colorPercentArray: manualPercentArray, colorTitleArray: deviceInfo?.channelColorTitleArray)
            manualColorView?.passColorValueCallback = {
                (colorIndex, colorValue) in
                    var commandStr = ""

                    for i in 0 ..< (self.parameterModel?.channelNum)! {
                        if i == colorIndex {
                            commandStr = commandStr.appendingFormat("%04x", colorValue)
                        } else {
                            commandStr.append("FFFF")
                        }
                    }
                
                var commandHeader = CommandHeader.COMMANDHEAD_FOUR.rawValue
                switch (self.parameterModel?.typeCode)! {
                case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
                    break
                default:
                    commandHeader.append(String.init(format: "%02x", (self.parameterModel?.channelNum)!))
                    break
                }
                
                commandStr = commandHeader + commandStr
                // print("colorIndex = \(colorIndex), commandStr = \(commandStr)")
                
                self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: CommandType.UNKNOWN_COMMAND, isXORCommand: true)
                
                // 更新模型数据
                self.parameterModel?.manualModeValueDic[colorIndex] = String.init(format: "%04x", colorValue)
            }
            
            manualModeView?.addSubview(manualColorView!)
            
            // 2.用户自定义按钮
            let userDefineViewFrame = CGRect(x: 0, y: (manualAutoViewFrame?.height)! - 70, width: SystemInfoTools.screenWidth, height: SystemInfoTools.screenHeight)
            let userDefineView = LayoutToolsView(viewNum: 3, viewWidth: 80, viewHeight: 50, viewInterval: 8, viewTitleArray: ["M1", "M2", "M3"], frame: userDefineViewFrame)
            userDefineView.buttonActionCallback = {
                (button, index) in
                var commandStr = CommandHeader.COMMANDHEAD_FOUR.rawValue
                let userColorStr = self.parameterModel?.userDefinedValueDic[index]
                commandStr.append((userColorStr?.convertUserPercentToHexColorValue())!)
                
                self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: .UNKNOWN_COMMAND, isXORCommand: true)
                // 更新模型
                for i in 0 ..< (self.parameterModel?.channelNum)! {
                    let colorStr = userColorStr?.convertUserPercentToHexColorValue()
                    self.parameterModel?.manualModeValueDic[i] = (colorStr! as NSString).substring(with: NSRange.init(location: i * 4, length: 4))
                }
                
                // 更新圆盘
                self.manualColorView?.updateManualCircleView(colorPercentArray: self.getManualColorPercentArray(parameterModel: self.parameterModel))
            }
            
            userDefineView.buttonLongPressCallback = {
                (index) in
                let commandStr = String.init(format: "%@%02x", CommandHeader.COMMANDHEAD_SIX.rawValue, index)
                
                self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: CommandType.SETTINGUSERDEFINED_COMMAND, isXORCommand: true)
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
            manualColorView?.updateManualCircleView(colorPercentArray: manualPercentArray)
        }
    }
    
    /// 从参数模型中获取用户半分比
    /// - parameter one:
    /// - parameter two:
    ///
    /// - returns:
    func getManualColorPercentArray(parameterModel: DeviceParameterModel!) -> [Int] {
        var manualPercentArray = [Int]()
        
        for i in 0 ..< (parameterModel?.manualModeValueDic.keys.count)! {
            manualPercentArray.append((parameterModel?.manualModeValueDic[i]?.hexaToDecimal)!)
        }
        
        return manualPercentArray
    }
    
    /// 开关方法
    /// - parameter sender: 触发点击的按钮
    ///
    /// - returns: Void
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
    
    func setAutoModeViews() -> Void {
        if self.manualModeView != nil {
            print("隐藏手动模式界面")
            self.manualModeView?.isHidden = true
        }
        
        if autoModeView == nil {
            // 创建自动模式视图
            autoModeView = UIView(frame: manualAutoViewFrame!)
            autoModeView?.backgroundColor = UIColor.clear
            
            // 1.自动模式曲线图
            let autoColorChartViewFrame = CGRect(x: 0, y: 0, width: (autoModeView?.frame.size.width)!, height: (autoModeView?.frame.size.width)!)
            autoColorChartView = AutoColorChartView(frame: autoColorChartViewFrame, channelNum: (parameterModel?.channelNum)!, colorArray:deviceInfo?.channelColorArray, colorTitleArray: deviceInfo?.channelColorTitleArray, timePointArray: parameterModel?.timePointArray, timePointValueDic: parameterModel?.timePointValueDic)
            
            autoModeView?.addSubview(autoColorChartView!)
            
            // 2.底部按钮 预览 运行（发送设置的配置到设备）编辑
            let bottomViewFrame = CGRect(x: 0, y: (autoModeView?.frame.size.height)! - 70, width: SystemInfoTools.screenWidth, height: 70)
            let bottomView = LayoutToolsView(viewNum: 3, viewWidth: 70, viewHeight: 50, viewInterval: 30, viewTitleArray: [self.languageManager.getTextForKey(key: "preview"), self.languageManager.getTextForKey(key: "run"), self.languageManager.getTextForKey(key: "edit")], frame: bottomViewFrame)
            
            // 添加观察者
            previewButton = bottomView.viewWithTag(1001) as? UIButton
            
            bottomView.buttonActionCallback = {
                (button, index) -> Void in
                    if (index == 0) {
                        // 1.预览功能
                        if button.titleLabel?.text == self.languageManager.getTextForKey(key: "preview") {
                            button.setTitle(self.languageManager.getTextForKey(key: "stop"), for: .normal)
                            self.beginPreview()
                        } else {
                            button.setTitle(self.languageManager.getTextForKey(key: "preview"), for: .normal)
                            self.cancelPreview()
                        }
                        
                    } else if (index == 1) {
                        self.cancelPreview()
                        // 2.发送设置到设备
                        if self.editParameterModel != nil {
                            let commandStr = (self.editParameterModel?.generateOldSetAutoCommand())!

                            switch (self.deviceInfo?.deviceTypeCode)! {
                            case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
                                self.blueToothManager.sendCommandToDevice(uuid: (self.editParameterModel?.uuid)!, commandStr: commandStr, commandType: CommandType.SETTINGAUTOMODE_COMMAND, isXORCommand: true)
                                break
                            default:
                                self.blueToothManager.sendCommandToDevice(uuid: (self.editParameterModel?.uuid)!, commandStr: (self.editParameterModel?.generateSetAutoCommand())!, commandType: CommandType.SETTINGAUTOMODE_COMMAND, isXORCommand: true)
                            }
                        }
                    } else {
                        // 3.跳转到编辑界面
                        let autoColorEditViewController = AutoColorEditViewController(nibName: "AutoColorEditViewController", bundle: Bundle.main)
                        
                        autoColorEditViewController.passParameterModelCallback = {
                            (deviceParameterModel) in
                            self.autoColorChartView?.updateGraph(channelNum: deviceParameterModel.channelNum!, colorArray: self.deviceInfo?.channelColorArray, colorTitleArray: self.deviceInfo?.channelColorTitleArray, timePointArray: deviceParameterModel.timePointArray, timePointValueDic: deviceParameterModel.timePointValueDic)
                            
                            self.editParameterModel = deviceParameterModel
                        }
                        
                        if self.editParameterModel == nil {
                            autoColorEditViewController.parameterModel = self.parameterModel
                        } else {
                            autoColorEditViewController.parameterModel = self.editParameterModel
                        }
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
    
    /// 开始预览功能
    ///
    /// - returns: Void
    func beginPreview() -> Void {
        previewCount = 0
        
        if self.editParameterModel == nil {
            self.editParameterModel = DeviceParameterModel()
            
            parameterModel?.parameterModelCopy(parameterModel: self.editParameterModel!)
        }
        
        timeCountArray.removeAll()
        timeCountIntervalArray.removeAll()
        for index in 0 ..< (self.editParameterModel?.timePointArray)!.count {
            let timeStr = self.editParameterModel?.timePointArray[index]
            timeCountArray.append((timeStr?.converTimeStrToMinute(timeStr: timeStr)!)!)
            
            if index ==  ((self.editParameterModel?.timePointArray)!.count - 1) {
                timeCountIntervalArray.append(timeCountArray[index] - timeCountArray[index - 1])
                timeCountIntervalArray.append(timeCountArray[0] + 1440 - timeCountArray[index])
            } else if index > 0 {
                timeCountIntervalArray.append(timeCountArray[index] - timeCountArray[index - 1])
            }
        }

        quickPreviewTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sendQuickPreviewCommand(timer:)), userInfo: nil, repeats: true)
    }
    
    /// 取消预览功能
    ///
    /// - returns: Void
    func cancelPreview() -> Void {
        if quickPreviewTimer != nil {
            quickPreviewTimer?.invalidate()
            quickPreviewTimer = nil
            
            self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: CommandHeader.COMMANDHEAD_TWELVE.rawValue, commandType: CommandType.UNKNOWN_COMMAND, isXORCommand: true)
        }

        // 设置按钮文本
        previewButton?.setTitle(self.languageManager.getTextForKey(key: "preview"), for: .normal)
    }
    
    /// 快速预览发送命令方法
    /// - parameter timer: 定时器
    ///
    /// - returns: Void
    @objc func sendQuickPreviewCommand(timer: Timer) -> Void {
        var commandStr = String(CommandHeader.COMMANDHEAD_ELEVEN.rawValue)
        
        self.autoColorChartView?.hightValue(x: Double(previewCount), index: (self.parameterModel?.channelNum)! - 1)
        
        // 根据 previewCount 计算发送的数值
        commandStr.append((calculateColorValue(previewCount: previewCount)))
        self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: CommandType.UNKNOWN_COMMAND, isXORCommand: true)
        
        if Double(previewCount) >= (autoColorChartView?.lineChart?.chartXMax)! {
            cancelPreview()
        }
        
        previewCount = previewCount + 2
    }
    
    /// 根据数值计算当前的颜色值
    /// - parameter previewCount: 当前点数
    ///
    /// - returns: 命令字符串
    func calculateColorValue(previewCount: Int!) -> String {
        var colorValueStr: String! = ""
        var previewColorValueStr: String! = ""
        var nextColorValueStr: String! = ""
        
        var index = 0
        var isInFirst = true
        var isInLast = true
        for i in 0 ..< timeCountArray.count {
            if previewCount <= timeCountArray[i] {
                if i == 0 {
                    previewColorValueStr = self.editParameterModel?.timePointValueDic[timeCountArray.count - 1]
                    nextColorValueStr = self.editParameterModel?.timePointValueDic[0]
                    index = i
                    isInFirst = true
                    isInLast = false
                    break
                } else if i <= (timeCountArray.count - 1) {
                    previewColorValueStr = self.editParameterModel?.timePointValueDic[i - 1]
                    nextColorValueStr = self.editParameterModel?.timePointValueDic[i]
                    index = i - 1
                    isInFirst = false
                    isInLast = false
                    break
                }
            } else if previewCount >= timeCountArray[timeCountArray.count - 1] && previewCount <= 1440 {
                previewColorValueStr = self.editParameterModel?.timePointValueDic[timeCountArray.count - 1]
                nextColorValueStr = self.editParameterModel?.timePointValueDic[0]
                index = timeCountArray.count - 1
                isInFirst = false
                isInLast = true
                break
            }
        }
        
        // 计算值
        var previewColorDoubleArray = previewColorValueStr.convertColorStrToDoubleValue()
        var nextColorDoubleArray = nextColorValueStr.convertColorStrToDoubleValue()
        for j in 0 ..< (self.editParameterModel?.channelNum)! {
            var percent = 0.0
            if isInFirst == true {
                percent = 1.0 + Double((previewCount - timeCountArray[index])) / Double(timeCountIntervalArray[timeCountIntervalArray.count - 1])
            } else if isInLast == true {
                percent = Double((previewCount - timeCountArray[index])) / Double(timeCountIntervalArray[timeCountIntervalArray.count - 1])
            } else {
                percent = Double((previewCount - timeCountArray[index])) / Double(timeCountIntervalArray[index])
            }
            
            let colorValue = previewColorDoubleArray![j] / 100.0 * 1000 - ((previewColorDoubleArray![j] - nextColorDoubleArray![j])) / 100.0 * 1000.0 * percent
            
            colorValueStr = colorValueStr.appendingFormat("%04x", Int(colorValue))
        }
        
        return colorValueStr
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
