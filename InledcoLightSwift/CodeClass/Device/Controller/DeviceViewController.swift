//
//  DeviceViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/16.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import CoreData
import LGAlertView

class DeviceViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var deviceTableView: UITableView!
    @IBOutlet weak var scanBarButtonItem: UIBarButtonItem!
    private var alertController: UIAlertController!
    private var connectAlertController: LGAlertView?
    private var connectFailedAlertController: LGAlertView?
    private var deviceDataSourceDic: [String: Array<DeviceModel>] = [String: Array<DeviceModel>]();
    private var selectDeviceModel: DeviceModel?
    private var deviceCodeInfo: DeviceCodeInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 视图设置
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.blueToothManager = BlueToothManager.sharedBluetoothManager()
        
        // 断开蓝牙
        if self.selectDeviceModel != nil && self.selectDeviceModel?.uuidString != nil {
            self.blueToothManager.disConnectDevice(uuid: self.selectDeviceModel?.uuidString)
        }
        
        // 准备数据
        prepareData()
    }
    
    /// 蓝牙初始化
    ///
    /// - returns: Void
    func prepareBluetoothData() -> Void {
        // 1.连接成功回调
        self.blueToothManager.completeReceiveDataCallback = {
            (receiveDataStr, commandType) in
            
            // 解析数据
            let parameterModel: DeviceParameterModel = DeviceParameterModel()
            parameterModel.channelNum = self.deviceCodeInfo?.channelNum
            
            parameterModel.typeCode = self.deviceCodeInfo?.deviceTypeCode
            parameterModel.uuid = self.selectDeviceModel?.uuidString
            
            // 这里可以根据设备编码解析调用不同的解析方法
            switch parameterModel.typeCode! {
                // 这里列出兼容旧设备
                case DeviceTypeCode.LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
                    parameterModel.parseOldDeviceDataFromReceiveStrToModel(receiveData: receiveDataStr!)
                default:
                    // 默认使用新设备解析数据
                    parameterModel.parseDeviceDataFromReceiveStrToModel(receiveData: receiveDataStr!)
            }
            
            // 2.同步时间回调
            self.blueToothManager.writeDataCallback = {
                (receiveDataStr, commandType) in
                self.blueToothManager.sendReadDeviceDataCommand(uuid: (self.selectDeviceModel?.uuidString)!)
            }
            
            self.connectAlertController?.dismiss(animated: true, completionHandler: nil)
            // 解析设备数据，跳转界面
            let colorSettingViewController = ColorSettingViewController(nibName: "ColorSettingViewController", bundle: Bundle.main)
            
            colorSettingViewController.devcieName = self.selectDeviceModel?.name
            colorSettingViewController.parameterModel = parameterModel
            colorSettingViewController.hidesBottomBarWhenPushed = true
        
            self.navigationController?.pushViewController(colorSettingViewController, animated: true)
        }
        
        // 2.连接失败回调
        self.blueToothManager.connectFailedCallback = {
            (receiveDataStr, commandType) in
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.connectFailed(timer:)), userInfo: nil, repeats: false)

            self.connectAlertController?.dismiss(animated: true, completionHandler: nil)
            self.connectFailedAlertController?.show(animated: true, completionHandler: nil)
        }
    }
    
    @objc func connectFailed(timer: Timer) -> Void {
        self.connectFailedAlertController?.dismiss(animated: true, completionHandler: nil)
    }
    
    /// 创建设备操作列表
    ///
    /// - returns: 空
    func createAlertController() {
        // 1.连接失败提示视图
        connectFailedAlertController = LGAlertView.init(title: languageManager.getTextForKey(key: "connectFailed"), message: nil, style: .alert, buttonTitles: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        // 2.操作弹出视图
        alertController = UIAlertController(title: self.selectDeviceModel?.name, message: nil, preferredStyle: .actionSheet)
        // 删除操作
        let deleteAction: UIAlertAction = UIAlertAction(title: languageManager.getTextForKey(key: "delete"), style: .destructive) { (alertAction) in
            let deleteAlertController = UIAlertController(title: self.languageManager.getTextForKey(key: "delete"), message: self.languageManager.getTextForKey(key: "confirmDelete") + String((self.selectDeviceModel?.name)!).trimmingCharacters(in: [" "]) + " ?", preferredStyle: .alert)
            
            let deleteCancelAction = UIAlertAction(title: self.languageManager.getTextForKey(key: "cancel"), style: .cancel, handler: nil)
            
            let deleteConfirmAction = UIAlertAction(title: self.languageManager.getTextForKey(key: "confirm"), style: .default, handler: { (action) in
                // 从数据库中删除设备
                DeviceDataCoreManager.deleteData(tableName: DeviceDataCoreManager.deviceTableName, uuidStr: (self.selectDeviceModel?.uuidString)!)
                
                self.queryDeviceDataFromDatabase()
            })
            
            deleteAlertController.addAction(deleteCancelAction)
            deleteAlertController.addAction(deleteConfirmAction)
            
            self.present(deleteAlertController, animated: true, completion: nil)
        }
        
        // 连接设备操作
        let connectAction: UIAlertAction = UIAlertAction(title: languageManager.getTextForKey(key: "connect"), style: .default) { (alertAction) in
            if self.selectDeviceModel != nil {
                if self.blueToothManager.connectDeviceWithUuid(uuid: self.selectDeviceModel?.uuidString) {
                    // 这里需要重新创建连接提示视图
                    self.connectAlertController = LGAlertView.init(activityIndicatorAndTitle: self.languageManager.getTextForKey(key: "connecting") + " " + (self.selectDeviceModel?.name)!, message: "", style: .alert, buttonTitles: nil, cancelButtonTitle: self.languageManager.getTextForKey(key: "cancel"), destructiveButtonTitle: nil)
                    
                    self.connectAlertController?.cancelHandler = {
                        (alertView) in
                        // 取消连接设备，也就是直接断开设备既可
                        self.blueToothManager.disConnectDevice(uuid: self.selectDeviceModel?.uuidString)
                    }
                    
                    self.connectAlertController?.show(animated: true, completionHandler: nil)
                }
            }
        }
        
        // 取消操作
        let cancalAction: UIAlertAction = UIAlertAction(title: languageManager.getTextForKey(key: "cancel"), style: .cancel) { (alertAction) in
            
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(connectAction)
        alertController.addAction(cancalAction)
    }
    
    override func prepareData() {
        // 这里只做从数据库中的操作
        super.prepareData()
        prepareBluetoothData()
        createAlertController()
        
        queryDeviceDataFromDatabase()
    }
    
    func queryDeviceDataFromDatabase() {
        self.deviceDataSourceDic.removeAll()
        
        // 1.获取品牌数据
        let brands = DeviceDataCoreManager.getDataWithFromTableWithCol(tableName: DeviceDataCoreManager.brandTableName, colName: DeviceDataCoreManager.brandTableBrandName, colVal: DeviceDataCoreManager.defaultBrandName)
        if brands.count == 0 {
            // 没有数据，直接返回
            return
        }
        
        // 2.获取分组数据：需要实现分组和设备按照名称进行排序
        let brand = brands.first as! BleBrand
        let groups = brand.brand_group
        for g in groups! {
            // 3.构建数据源
            let group = g as! BleGroup
            var deviceArray: [DeviceModel] = [DeviceModel]()
            for d in group.group_device! {
                let deviceInfo = d as! BleDevice
                let deviceModel = DeviceModel()
                
                deviceModel.name = deviceInfo.name
                deviceModel.typeCode = deviceInfo.typeCode
                deviceModel.uuidString = deviceInfo.uuid
                
                deviceArray.append(deviceModel)
            }
            
            self.deviceDataSourceDic[group.name!] = deviceArray
        }
        
        self.deviceTableView.reloadData()
    }
    
    override func setViews() {
        super.setViews()
        
        self.title = self.languageManager.getTextForKey(key: "home")
        self.automaticallyAdjustsScrollViewInsets = false
        self.deviceTableView.delegate = self
        self.deviceTableView.dataSource = self
        self.deviceTableView.backgroundColor = UIColor.clear
        self.deviceTableView.separatorStyle = .singleLine;
        self.deviceTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.deviceTableView.register(UINib.init(nibName: "DeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  deviceDataSourceDic.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = deviceDataSourceDic.keys.reversed()[section]
        return (self.deviceDataSourceDic[key]?.count)!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return deviceDataSourceDic.keys.reversed()[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as! DeviceTableViewCell
        
        let deviceModel = getDeviceModelFromDatasource(section: indexPath.section, row: indexPath.row)
        if deviceModel.name == nil {
            deviceModel.name = "Default"
        }
        
        let deviceInfo = DeviceTypeData.getDeviceInfoWithTypeCode(deviceTypeCode: DeviceTypeCode(rawValue: deviceModel.typeCode!) == nil ? DeviceTypeCode.NEW_DEVICE_LIGHT : DeviceTypeCode(rawValue: deviceModel.typeCode!)!)
        
        cell.lightNameLabel.text = deviceModel.name
        cell.lightDetailLabel.text = deviceInfo.deviceName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectDeviceModel = getDeviceModelFromDatasource(section: indexPath.section, row: indexPath.row)
        // 获取当前数据动态信息
        
        self.deviceCodeInfo = DeviceTypeData.getDeviceInfoWithTypeCode(deviceTypeCode: DeviceTypeCode(rawValue: (self.selectDeviceModel?.typeCode!)!) == nil ? DeviceTypeCode.NEW_DEVICE_LIGHT : DeviceTypeCode(rawValue: (self.selectDeviceModel?.typeCode!)!)!)
        self.blueToothManager.currentDeviceTypeCode = self.deviceCodeInfo?.deviceTypeCode
        alertController.title = self.selectDeviceModel?.name
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getDeviceModelFromDatasource(section: Int, row: Int) -> DeviceModel {
        let key = deviceDataSourceDic.keys.reversed()[section]
        let deviceModel = deviceDataSourceDic[key]?[row]
        
        return deviceModel!
    }
    
    // 扫描跳转方法
    @IBAction func scanBarButtonAction(_ sender: UIBarButtonItem) {
        let scanDeviceViewController: ScanDeviceViewController! = ScanDeviceViewController();
        
        scanDeviceViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(scanDeviceViewController, animated: true)
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
