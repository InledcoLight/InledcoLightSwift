//
//  AutoColorEditViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/27.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import LGAlertView

class AutoColorEditViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var manualSliderView: ManualSliderView?
    var parameterModel: DeviceParameterModel?
    let editParameterModel: DeviceParameterModel! = DeviceParameterModel()
    var deviceCodeInfo: DeviceCodeInfo?
    var bottomView: LayoutToolsView?
    var timePointSelectTableView: UITableView! = UITableView()
    // 用来标记当前修改的是第几个时间段的颜色值
    var selectedTimePointIndex: Int? = 0
    var dateformatter: DateFormatter! = DateFormatter.init()
    typealias PassParameterType = (DeviceParameterModel) -> Void
    var passParameterModelCallback: PassParameterType?
    var addTimePoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareData()
        setViews()
    }

    override func prepareData() {
        super.prepareData()
        
        dateformatter.dateFormat = "HH:mm"
        
        timePointSelectTableView.delegate = self
        timePointSelectTableView.dataSource = self
        timePointSelectTableView.backgroundColor = UIColor.clear
        timePointSelectTableView.separatorStyle = .none
        timePointSelectTableView.tableFooterView = UIView(frame: CGRect.zero)
        timePointSelectTableView.register(UINib.init(nibName: "TimePointTableViewCell", bundle: nil), forCellReuseIdentifier: "TimePointTableViewCell")
        
        parameterModel?.parameterModelCopy(parameterModel: editParameterModel)
        
        deviceCodeInfo = DeviceTypeData.getDeviceInfoWithTypeCode(deviceTypeCode: (self.editParameterModel.typeCode)!)
    }
    
    override func setViews() {
        super.setViews()
        
        self.title = self.languageManager.getTextForKey(key: "timePoint24")
        self.navigationItem.hidesBackButton = true
        
        // 1.滑动条调光界面
        let manualSliderViewFrame = CGRect(x: 0, y: 64, width: SystemInfoTools.screenWidth, height: 240.0)
        let timeColorValue = self.editParameterModel.convertColorValue()
        
        manualSliderView = ManualSliderView(frame: manualSliderViewFrame, colorArray: deviceCodeInfo?.channelColorArray, colorTitleArray: deviceCodeInfo?.channelColorTitleArray, colorPercentArray: timeColorValue[self.selectedTimePointIndex!]!)
        
        manualSliderView?.passSliderValueCallback = {
            (index, colorValue) in
            // 根据时间点信息，把更改同步到模型中
            if self.selectedTimePointIndex != nil {
                switch (self.editParameterModel.typeCode)! {
                case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .SIXCHANNEL_LIGHT: // .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT,
                    if self.selectedTimePointIndex == 0 || (self.selectedTimePointIndex == (self.editParameterModel.timePointNum) - 1) {
                        self.editParameterModel.saveColorValueToModel(timePointIndex: 0, colorIndex: index, colorValue: colorValue)
                        self.editParameterModel.saveColorValueToModel(timePointIndex: (self.editParameterModel.timePointNum!) - 1, colorIndex: index, colorValue: colorValue)
                    } else if self.selectedTimePointIndex! % 2 != 0 {
                        self.editParameterModel.saveColorValueToModel(timePointIndex: self.selectedTimePointIndex, colorIndex: index, colorValue: colorValue)
                        self.editParameterModel.saveColorValueToModel(timePointIndex: self.selectedTimePointIndex! + 1, colorIndex: index, colorValue: colorValue)
                    } else {
                        self.editParameterModel.saveColorValueToModel(timePointIndex: self.selectedTimePointIndex, colorIndex: index, colorValue: colorValue)
                        self.editParameterModel.saveColorValueToModel(timePointIndex: self.selectedTimePointIndex! - 1, colorIndex: index, colorValue: colorValue)
                    }
                default:
                    self.editParameterModel.saveColorValueToModel(timePointIndex: self.selectedTimePointIndex, colorIndex: index, colorValue: colorValue)
                }
            }
        }
        self.view.addSubview(manualSliderView!)
        
        // 2.时间列表界面
        let timePointSelectTableViewY = (manualSliderView?.frame.origin.y)! + (manualSliderView?.frame.size.height)!
        let timePointSelectTableViewHeight = (SystemInfoTools.screenHeight - 64 - (manualSliderView?.frame.height)! - 50)
        let timePointSelectTableViewFrame = CGRect(x: 0, y: timePointSelectTableViewY, width: SystemInfoTools.screenWidth, height: timePointSelectTableViewHeight)
        
        timePointSelectTableView.frame = timePointSelectTableViewFrame
        
        self.view.addSubview(timePointSelectTableView)
        
        // 3.增加 删除 保存 取消
        let bottomViewFrame = CGRect(x: 0, y: SystemInfoTools.screenHeight - 50, width: SystemInfoTools.screenWidth, height: 50)
        bottomView = LayoutToolsView(viewNum: 4, viewWidth: (SystemInfoTools.screenWidth - 3.0 * 8 - 2 * 16) / 4.0, viewHeight: 40, viewInterval: 8, viewTitleArray: [self.languageManager.getTextForKey(key: "add"), self.languageManager.getTextForKey(key: "delete"), self.languageManager.getTextForKey(key: "save"), self.languageManager.getTextForKey(key: "cancel")], frame: bottomViewFrame)
        
        bottomView?.backgroundColor = UIColor.clear
        bottomView?.buttonActionCallback = {
            (button, index) in
            if index == 0 {
                // 1.增加按钮方法
                let datePicker = UIDatePicker()
                datePicker.date = Date()
                datePicker.datePickerMode = .time
                datePicker.locale = Locale.init(identifier: "NL")
                
                self.addTimePoint = self.dateformatter.string(from: datePicker.date).convertFormatTimeToHexTime()
                
                datePicker.addTarget(self, action: #selector(self.datePickerChanged(sender:)), for: .valueChanged)
                let datePickerAlert = LGAlertView.init(viewAndTitle: self.languageManager.getTextForKey(key: "timePoint"), message: self.languageManager.getTextForKey(key: "timePointMessage"), style: LGAlertViewStyle.alert, view: datePicker, buttonTitles: [self.languageManager.getTextForKey(key: "Done")], cancelButtonTitle: self.languageManager.getTextForKey(key: "Cancel"), destructiveButtonTitle: "")
                
                datePickerAlert?.actionHandler = {
                    (alertView, title, index) in
                    if index == 0 {
                        // 更新模型
                        var index = 0
                        for timeStr in self.editParameterModel.timePointArray {
                            if timeStr.converTimeStrToMinute(timeStr: timeStr)! > (self.addTimePoint?.converTimeStrToMinute(timeStr: self.addTimePoint))! {
                                break
                            }
                            
                            index = index + 1
                        }
                        
                        self.editParameterModel.timePointArray.insert(self.addTimePoint!, at: index)
                        self.editParameterModel.timePointNum = self.editParameterModel.timePointNum + 1
                        
                        for i in (0 ..< self.editParameterModel.timePointValueDic.keys.count).reversed()   {
                            if i > index {
                                self.editParameterModel.timePointValueDic[i + 1] = self.editParameterModel.timePointValueDic[i]
                            } else if i <= index {
                                // self.editParameterModel.timePointValueDic[i + 1] = self.editParameterModel.timePointValueDic[i]
                                self.editParameterModel.timePointValueDic[index] = ""
                                for _ in 0 ..< self.editParameterModel.channelNum! * 2 {
                                    self.editParameterModel.timePointValueDic[index]?.append("0")
                                }
                                
                                break
                            }
                        }
                        
                        // 更新视图
                        self.updateSliderColor(index: index)
                    }
                }
                
                datePickerAlert?.cancelHandler = {
                    (alertView) in
                }
                
                datePickerAlert?.show(animated: true, completionHandler: nil)
            } else if index == 1 {
                // 2.删除按钮方法
                let deleteAlertController = UIAlertController(title: self.languageManager.getTextForKey(key: "delete"), message: self.languageManager.getTextForKey(key: "delete") + " " +  self.editParameterModel.timePointArray[self.selectedTimePointIndex!].convertHexTimeToFormatTime() + "?", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: self.languageManager.getTextForKey(key: "confirm"), style: .default, handler: { (action) in
                    self.editParameterModel.timePointNum = self.editParameterModel.timePointNum - 1
                    self.editParameterModel.timePointArray.remove(at: self.selectedTimePointIndex!)
                    for i in (0 ..< self.editParameterModel.timePointValueDic.keys.count - 2).reversed() {
                        if i > self.selectedTimePointIndex! {
                            self.editParameterModel.timePointValueDic[i] = self.editParameterModel.timePointValueDic[i + 1]
                        }
                    }
                    
                    self.editParameterModel.timePointValueDic.removeValue(forKey: self.editParameterModel.timePointValueDic.keys.count - 1)
                    
                    self.updateSliderColor(index: 0)
                })
                
                let cancelAction = UIAlertAction(title: self.languageManager.getTextForKey(key: "cancel"), style: .cancel, handler: { (action) in
                    
                })
                deleteAlertController.addAction(confirmAction)
                deleteAlertController.addAction(cancelAction)
                
                self.present(deleteAlertController, animated: true, completion: nil)
            } else if index == 2 {
                // 3.保存按钮方法: 需要把更改后的设置发送到自动模式界面
                if self.passParameterModelCallback != nil {
                    self.passParameterModelCallback!(self.editParameterModel)
                }
                
                self.navigationController?.popViewController(animated: true)
            } else if index == 3 {
                // 4.取消按钮方法
                let connectAlertController = LGAlertView.init(title: self.languageManager.getTextForKey(key: "giveUpSave"), message: "", style: LGAlertViewStyle.alert, buttonTitles: nil, cancelButtonTitle: self.languageManager.getTextForKey(key: "cancel"), destructiveButtonTitle: self.languageManager.getTextForKey(key: "confirm"), delegate: nil)
                
                connectAlertController?.cancelHandler = {
                    (alertView) in
                }
                
                connectAlertController?.destructiveHandler = {
                    (alertView) in
                    self.navigationController?.popViewController(animated: true)
                }
                
                connectAlertController?.show(animated: true, completionHandler: nil)
            }
        }
        
        self.view.addSubview(bottomView!)
    }
    
    @objc func datePickerChanged(sender: UIDatePicker) -> Void {
        self.addTimePoint = dateformatter.string(from: sender.date).convertFormatTimeToHexTime()
    }
    
    func updateSliderColor(index: Int) -> Void {
        self.selectedTimePointIndex = index
        
        let timeColorValue = self.editParameterModel.timePointValueDic[index]?.convertColorStrToDoubleValue()
        
        self.manualSliderView?.updateManualSliderView(colorPercentArray: timeColorValue!)
        
        self.timePointSelectTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editParameterModel.timePointArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TimePointTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TimePointTableViewCell", for: indexPath) as! TimePointTableViewCell
        
        cell.timePointDatePicker.date = dateformatter.date(from: self.editParameterModel.timePointArray[indexPath.row].convertHexTimeToFormatTime())!
        
        cell.timePointDatePicker.isEnabled = self.selectedTimePointIndex == indexPath.row ? true : false
        
        cell.selectButton.isSelected = self.selectedTimePointIndex == indexPath.row ? true : false
        
        cell.datePickerValueChangedCallback = {
            (date) in
            let dateStr = self.dateformatter.string(from: date)
            
            switch (self.editParameterModel.typeCode)! {
            case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT,   .FOURCHANNEL_LIGHT,.FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
                self.editParameterModel.timePointArray[indexPath.row] = dateStr.convertFormatTimeToHexTime()
            default:
                break
            }
        }

        cell.selectButtonSelectCallback = {
            (selected) in
            if selected == true {
                self.selectedTimePointIndex = indexPath.row
                
                // 更新滑动条
                let timeColorValue = self.editParameterModel.timePointValueDic[indexPath.row]?.convertColorStrToDoubleValue()
                
                self.manualSliderView?.updateManualSliderView(colorPercentArray: timeColorValue!)
            } else {
                self.selectedTimePointIndex = nil
            }
            
            self.timePointSelectTableView.reloadData()
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
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
