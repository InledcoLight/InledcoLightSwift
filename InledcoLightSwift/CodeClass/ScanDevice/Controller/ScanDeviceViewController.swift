//
//  ScanDeviceViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/16.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import CoreData
import LGAlertView

class ScanDeviceViewController: BaseViewController,BLEManagerDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var scanActivity: UIActivityIndicatorView?
    private var isScan: Bool! = false
    private let scanInterval = 3  // 扫描时间
    private var scanAndConnectInterval = 10
    private var connectIndex = 0
    // 1.第一个定时器用来启用什么时候开始连接那些没有类型编码的设备
    private var connectTimer: Timer?  // 不能在这使用类中的方法直接初始化定时器，因为这时定时器方法还未初始化
    // 2.用来设置扫描按钮的文本信息
    private var scanTimer: Timer?
    private let deviceDataSourceArray: NSMutableArray = []
    private let deviceNeedConnectDataSourceArray: NSMutableArray = []
    var scanBarButtonItem: UIBarButtonItem?
    private let bleManager: BLEManager! = BLEManager<AnyObject, AnyObject>.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化工作
        self.prepareData()
        self.setViews()
        
        // 开始扫描
        scanDevice()
    }

    override func viewWillDisappear(_ animated: Bool) {
        releaseTimer();
        self.isScan = false
    }
    
    @objc func scanDevice() -> Void {
        if !isScan {
            isScan = true
            prepareTimer()
            self.scanActivity?.startAnimating()
            self.scanBarButtonItem?.title = self.languageManager.getTextForKey(key: "stop")
            self.deviceDataSourceArray.removeAllObjects()
            self.deviceNeedConnectDataSourceArray.removeAllObjects()
            self.tableView.reloadData()
            // 开始扫描
            self.bleManager.scanDeviceTime(self.scanInterval)
        } else {
            isScan = false
            self.scanActivity?.stopAnimating()
            self.scanBarButtonItem?.title = self.languageManager.getTextForKey(key: "scan")
            self.bleManager.manualStopScanDevice()
            // 设置为超长时间，则不会执行
            self.scanTimer?.fireDate = Date(timeIntervalSinceNow: 100000000000000.0)
            self.connectTimer?.fireDate = Date(timeIntervalSinceNow: 100000000000000.0)
        }
    }
    
    override func prepareData() {
        super.prepareData()
        
        // 蓝牙代理
        self.bleManager.delegate = self
        
        // 检测手机蓝牙的状态
        if self.bleManager.centralManager.state != .poweredOn {
            let bluetoothAlert = LGAlertView.init(title: self.languageManager.getTextForKey(key: "bluetoothError"), message: self.languageManager.getTextForKey(key: "blueErrorMessage"), style: .alert, buttonTitles: nil, cancelButtonTitle: self.languageManager.getTextForKey(key: "confirm"), destructiveButtonTitle: nil, delegate: nil)
            
            bluetoothAlert?.show(animated: true, completionHandler: nil)
            
            return
        }
        
        // prepareTimer()
    }
    
    func prepareTimer() -> Void {
        // 初始化扫描定时器和连接定时器
        // 注意：
        // 由于一些蓝牙模块需要连接后才能获取到设备的类型所以对这部分蓝牙设备，需要做特殊处理
        // 1.正常的蓝牙模块：在扫描后直接获取类型信息
        // 2.不正常的蓝牙模块：需要连接后获取设备类型信息
        // 两个定时器直接有一个间隔：这个时间间隔用来连接不正常的蓝牙模块
        // 首先是开始执行连接设备，此时取消扫描设备，然后开始连接设备
        releaseTimer();
        self.scanTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.scanInterval + scanAndConnectInterval), target: self, selector: #selector(scanDevice), userInfo: nil, repeats: false)
        self.connectTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.scanInterval + 1), target: self, selector: #selector(connectToDevice), userInfo: nil, repeats: false)
    }
    
    func releaseTimer() -> Void {
        if self.scanTimer != nil {
            self.scanTimer?.invalidate()
            self.scanTimer = nil
        }
        
        if self.connectTimer != nil {
            self.connectTimer?.invalidate()
            self.connectTimer = nil
        }
    }
    
    override func setViews() {
        super.setViews()
        
        self.title = languageManager.getTextForKey(key: "scanTitle")
        
        scanActivity = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        scanBarButtonItem = UIBarButtonItem.init(title: languageManager.getTextForKey(key: "scan"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(scanBarButtonItemClickAction(barButtonItem:)))
        
        let scanActivityItem = UIBarButtonItem.init(customView: scanActivity!)
        
        self.navigationItem.rightBarButtonItems = [scanBarButtonItem!, scanActivityItem]
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.register(UINib.init(nibName: "ScanDeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "ScanDeviceTableViewCell")
    }
    
    // 扫描按钮方法
    @objc func scanBarButtonItemClickAction(barButtonItem: UIBarButtonItem) -> Void {
        scanDevice()
    }
    
    // 蓝牙扫描代理方法
    func scanDeviceRefrash(_ array: NSMutableArray!) {
        self.deviceDataSourceArray.removeAllObjects()
        self.deviceNeedConnectDataSourceArray.removeAllObjects()
        
        for device in array {
            let deviceInfo: DeviceInfo = device as! DeviceInfo
            print("MAC地址:" + deviceInfo.macAddrss)
            // 查询数据库中是否
            let result = DeviceDataCoreManager.getDataWithFromTableWithCol(tableName: DeviceDataCoreManager.deviceTableName, colName: DeviceDataCoreManager.deviceTableUuidName, colVal: deviceInfo.uuidString)
            if result.count > 0 {
                continue
            }
            
            // 打印扫描到的信息
            // printDeviceInfo(deviceInfo: deviceInfo)
            // 打印扫描到的信息
            let scanDeviceModel = DeviceModel()
            
            scanDeviceModel.name = deviceInfo.name
            scanDeviceModel.deviceName = deviceInfo.localName
            scanDeviceModel.uuidString = deviceInfo.uuidString
            scanDeviceModel.isSelected = false
            
            /**
             * 这里需要处理的是：
             * 1.如果广播数据有编码，则直接获取编码
             * 2.如果广播数据没有类型编码，则需要连接设备获取编码
             */
            let isSuccess = getDeviceTypeCode(deviceInfo: deviceInfo, deviceModel: scanDeviceModel)
            if isSuccess {
                // print("添加完整设备")
                self.deviceDataSourceArray.add(scanDeviceModel)
                
                self.tableView.reloadData()
            }else{
                // 需要连接设备获取类型编码的设备
                self.deviceNeedConnectDataSourceArray.add(scanDeviceModel)
            }
        }
    }
    
    func getDeviceTypeCode(deviceInfo: DeviceInfo!, deviceModel: DeviceModel!) -> Bool {
        if !deviceInfo.advertisementDic.keys.contains("kCBAdvDataManufacturerData"){
            return false
        }
        
        let deviceTypeCode = NSString.init(data: (deviceInfo.advertisementDic["kCBAdvDataManufacturerData"] as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)!
        
        if deviceTypeCode.length < 4 {
            return false
        }
        deviceModel.typeCode = deviceTypeCode.substring(to: 4)
        
        return true
    }
    
    @objc func connectToDevice() -> Void {
        if !self.isScan {
            return
        }
        
        // 连接那些没有广播数据的设备
        // 1.手动停止扫描
        self.bleManager.manualStopScanDevice()
        self.connectIndex = 0
        if self.deviceNeedConnectDataSourceArray.count > self.connectIndex {
            let deviceModel: DeviceModel = self.deviceNeedConnectDataSourceArray.object(at: self.connectIndex) as! DeviceModel
            // 2.开始连接设备
            self.bleManager.connect(toDevice: self.bleManager.getDeviceByUUID(deviceModel.uuidString))
        }
    }
    
    func connectDeviceSuccess(_ device: CBPeripheral!, error: Error!) {
        if !self.isScan {
            return
        }
        // 读取广播数据
        self.bleManager.readDeviceAdvertData(device)
    }
    
    func receiveDeviceAdvertData(_ dataStr: String!, device: CBPeripheral!) {
        if !self.isScan {
            return
        }
        if (self.connectIndex >= self.deviceNeedConnectDataSourceArray.count){
            //print("接收到广播数据，索引大于数组长度！")
            return;
        }
        let deviceModel: DeviceModel = self.deviceNeedConnectDataSourceArray.object(at: self.connectIndex) as! DeviceModel
        
        // 解析广播数据
        parsekCBAdvDataManufacturerData(dataString: dataStr, deviceModel: deviceModel)
        
        self.bleManager.disconnectDevice(device)
    }
    
    func didDisconnectDevice(_ device: CBPeripheral!, error: Error!) {
        // 断开设备成功，连接下一个设备
        self.connectIndex = self.connectIndex + 1
        if self.deviceNeedConnectDataSourceArray.count > self.connectIndex{
            let deviceModel: DeviceModel = self.deviceNeedConnectDataSourceArray.object(at: self.connectIndex) as! DeviceModel

            self.bleManager.connect(toDevice: self.bleManager.getDeviceByUUID(deviceModel.uuidString))
        }
    }
    
    func parsekCBAdvDataManufacturerData(dataString: String, deviceModel: DeviceModel) -> Void {
        if dataString.count < 4 {
            return
        }
        
        deviceModel.name = deviceModel.name!
        deviceModel.typeCode = (dataString as NSString).substring(to: 4)
        
        self.deviceDataSourceArray.add(deviceModel)
        self.tableView.reloadData()
    }
    
    // 保存设备
    @IBAction func saveDeviceAction(_ sender: UIButton) {
        saveCoreData()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // 创建CoreData栈
    func saveCoreData() -> Void {
        let context = DeviceDataCoreManager.getDataCoreContext()
        
        for device in self.deviceDataSourceArray {
            let deviceModel = device as! DeviceModel
            
            if !deviceModel.isSelected! {
                continue
            }
            
            // 1.先判断数据库中是否有品牌
            let brands = DeviceDataCoreManager.getDataWithFromTableWithCol(tableName: DeviceDataCoreManager.brandTableName, colName: DeviceDataCoreManager.brandTableBrandName, colVal: DeviceDataCoreManager.defaultBrandName)
            var defaultBrand: BleBrand?
            var defaultGroup: BleGroup?
            if brands.count == 0 {
                // 1.创建品牌
                defaultBrand = (NSEntityDescription.insertNewObject(forEntityName: DeviceDataCoreManager.brandTableName, into: context) as! BleBrand)
                
                defaultBrand?.name = DeviceDataCoreManager.defaultBrandName
                
                // 2.新建默认分组
                defaultGroup = (NSEntityDescription.insertNewObject(forEntityName: DeviceDataCoreManager.groupTableName, into: context) as! BleGroup)
                
                defaultGroup?.name = DeviceDataCoreManager.defaultGroupName
                
                defaultBrand?.addToBrand_group(defaultGroup!)
            } else {
                // 1.获取品牌
                defaultBrand = (brands[0] as! BleBrand)
                
                // 2.获取第一个分组作为默认分组
                defaultGroup = defaultBrand?.brand_group?.first(where: {($0 as! BleGroup).name == DeviceDataCoreManager.defaultGroupName}) as? BleGroup
            }
            
            // 3.添加设备
            let saveDevice = NSEntityDescription.insertNewObject(forEntityName: DeviceDataCoreManager.deviceTableName, into: context) as! BleDevice
            
            saveDevice.name = deviceModel.name
            saveDevice.typeCode = deviceModel.typeCode
            saveDevice.uuid = deviceModel.uuidString
            saveDevice.macAddress = deviceModel.macAddress
            
            defaultGroup?.addToGroup_device(saveDevice)
            
            do {
                try context.save()
                //print("保存成功!")
            }catch{
                //print("保存出错，\(error)")
            }
        }
    }
    
    // TableView代理方法
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceDataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanDeviceTableViewCell", for: indexPath) as! ScanDeviceTableViewCell
        let deviceModel = self.deviceDataSourceArray.object(at: indexPath.row) as! DeviceModel
        
        cell.selectionStyle = .none
        // 闭包，也就是使用大括号括起来，实现闭包的方法
        cell.selectCallBack = {
            (sender)->() in
            if deviceModel.isSelected! {
                deviceModel.isSelected = false
            } else{
                deviceModel.isSelected = true
            }
            sender.isSelected = deviceModel.isSelected!
        }
        
        cell.deviceSelectButton.isSelected = deviceModel.isSelected!
        cell.deviceNameLabel.text = deviceModel.name!
        cell.deviceDetailLabel.text = deviceModel.typeCode
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
