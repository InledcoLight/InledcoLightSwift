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
    var timePointArray: [String]! = [String]()
    // 用来标记当前修改的是第几个时间段的颜色值
    var selectedTimePointIndex: Int? = 0
    var dateformatter: DateFormatter! = DateFormatter.init()
    typealias PassParameterType = (DeviceParameterModel) -> Void
    var passParameterModelCallback: PassParameterType?
    
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
        timePointSelectTableView.backgroundColor = UIColor.gray
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
        let timeColorValue = String.convertColorValue(timePointArray: editParameterModel.timePointArray, timePointColorDic: editParameterModel.timePointValueDic)
        
        manualSliderView = ManualSliderView(frame: manualSliderViewFrame, colorArray: deviceCodeInfo?.channelColorArray, colorTitleArray: deviceCodeInfo?.channelColorTitleArray, colorPercentArray: timeColorValue![0]!)
        
        manualSliderView?.passSliderValueCallback = {
            (index, colorValue) in
            // 根据时间点信息，把更改同步到模型中
            if self.selectedTimePointIndex != nil {
                String.saveColorValueToModel(timePointCount: self.editParameterModel?.timePointArray.count, timePointIndex: self.selectedTimePointIndex, colorIndex: index, colorValue: colorValue, parameterModel: self.editParameterModel)
                print(self.editParameterModel?.timePointValueDic[0] ?? "a")
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
        
        bottomView?.backgroundColor = UIColor.gray
        bottomView?.buttonActionCallback = {
            (index) in
            if index == 0 {
                // 1.增加按钮方法
            } else if index == 1 {
                // 2.删除按钮方法
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editParameterModel.timePointArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TimePointTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TimePointTableViewCell", for: indexPath) as! TimePointTableViewCell
        
        cell.timePointDatePicker.date = dateformatter.date(from: self.editParameterModel.timePointArray[indexPath.row].convertHexTimeToFormatTime())!;
        
        cell.timePointDatePicker.isEnabled = self.selectedTimePointIndex == indexPath.row ? true : false
        cell.selectButton.isSelected = self.selectedTimePointIndex == indexPath.row ? true : false
        cell.backgroundColor = UIColor.gray
        
        cell.datePickerValueChangedCallback = {
            (date) in
            let dateStr = self.dateformatter.string(from: date)
            self.editParameterModel.timePointArray[self.selectedTimePointIndex!] = dateStr.convertFormatTimeToHexTime()
        }
        
        cell.selectButtonSelectCallback = {
            (selected) in
            if selected == true {
                self.selectedTimePointIndex = indexPath.row
                
                // 更新滑动条
                let timeColorValue = String.convertColorValue(timePointArray: self.editParameterModel.timePointArray, timePointColorDic: self.editParameterModel.timePointValueDic)
                
                self.manualSliderView?.updateManualSliderView(colorPercentArray: timeColorValue![indexPath.row]!)
            } else {
                self.selectedTimePointIndex = nil
            }
            
            self.timePointSelectTableView.reloadData()
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
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
