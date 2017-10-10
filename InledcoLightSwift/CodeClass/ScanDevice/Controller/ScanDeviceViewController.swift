//
//  ScanDeviceViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/16.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import CoreData

class ScanDeviceViewController: BaseViewController,BLEManagerDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var isScan: Bool! = false
    private let scanInterval = 3
    private var connectIndex = 0
    private var scanItemTitle = "扫描"
    // 1.第一个定时器用来启用什么时候开始连接那些没有类型编码的设备
    private var connectTimer: Timer?  // 不能在这使用类中的方法直接初始化定时器，因为这时定时器方法还未初始化
    // 2.用来设置扫描按钮的文本信息
    private var scanTimer: Timer?
    private let deviceDataSourceArray: NSMutableArray = []
    private let deviceNeedConnectDataSourceArray: NSMutableArray = []
    var scanBarButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareData()
        self.setViews()
        
        // 开始扫描
        scanDevice()
    }

    @objc func scanDevice() -> Void {
        if !isScan {
            isScan = true
            self.scanBarButtonItem?.title = "停止"
            self.bleManager.scanDeviceTime(self.scanInterval)
            self.scanTimer?.fireDate = Date(timeIntervalSinceNow: TimeInterval(self.scanInterval))
        } else {
            isScan = false
            self.scanBarButtonItem?.title = "扫描"
            self.bleManager.manualStopScanDevice()
            self.scanTimer?.fireDate = Date(timeIntervalSinceNow: 100000000000000.0)
        }
    }
    
    override func prepareData() {
        super.prepareData()
        
        self.connectTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.scanInterval), target: self, selector: #selector(connectToDevice), userInfo: nil, repeats: false)
        self.scanTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.scanInterval), target: self, selector: #selector(scanDevice), userInfo: nil, repeats: true)

        self.bleManager.delegate = self
    }
    
    override func setViews() {
        super.setViews()
        
        scanBarButtonItem = UIBarButtonItem.init(title: "Scan", style: UIBarButtonItemStyle.plain, target: self, action: #selector(scanBarButtonItemClickAction(barButtonItem:)))
        
        self.navigationItem.rightBarButtonItem = scanBarButtonItem
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
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
        
        let dataCoreContext = DeviceDataCoreManager.getDataCoreContext()
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BleDevice")
        for device in array {
            let deviceInfo: DeviceInfo = device as! DeviceInfo
            // 判断是否在数据库中存在，每次只是改变谓词就行
            fetch.predicate = NSPredicate(format: "uuid == %@", deviceInfo.uuidString)
            
            do {
                let results = try dataCoreContext.fetch(fetch)
                if results.count > 0 {
                    continue
                }
            }catch{
                print("查询出错!")
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
            }else{
                // print("添加不完整设备")
                // 需要连接设备获取类型编码的设备
                self.deviceNeedConnectDataSourceArray.add(scanDeviceModel)
            }
        }
        
        self.tableView.reloadData()
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
        print("deviceModel.typeCode = \(String(describing: deviceModel.typeCode))")
        return true
    }
    
    @objc func connectToDevice() -> Void {
        if !self.isScan {
            return
        }
        
        // 连接那些没有广播数据的设备
        print("开始连接设备,一共有\(self.deviceNeedConnectDataSourceArray.count)个设备")
        self.bleManager.manualStopScanDevice()
        self.connectIndex = 0
        if self.deviceNeedConnectDataSourceArray.count > self.connectIndex {
            let deviceModel: DeviceModel = self.deviceNeedConnectDataSourceArray.object(at: self.connectIndex) as! DeviceModel
            print("开始连接\(String(describing: deviceModel.name))")
            self.bleManager.connect(toDevice: self.bleManager.getDeviceByUUID(deviceModel.uuidString))
        }
    }
    
    func connectDeviceSuccess(_ device: CBPeripheral!, error: Error!) {
        if !self.isScan {
            return
        }
        
        print("连接设备成功")
        // 读取广播数据
        self.bleManager.readDeviceAdvertData(device)
    }
    
    func receiveDeviceAdvertData(_ dataStr: String!, device: CBPeripheral!) {
        if !self.isScan {
            return
        }
        
        let deviceModel: DeviceModel = self.deviceNeedConnectDataSourceArray.object(at: self.connectIndex) as! DeviceModel
        
        // 解析广播数据
        parsekCBAdvDataManufacturerData(dataString: dataStr, deviceModel: deviceModel)
        
        self.bleManager.disconnectDevice(device)
    }
    
    func didDisconnectDevice(_ device: CBPeripheral!, error: Error!) {
        // 断开设备成功，连接下一个设备
        print("设备断开成功")
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
        
        deviceModel.name = deviceModel.name! + "不完整设备"
        deviceModel.typeCode = (dataString as NSString).substring(to: 4)
        
        self.deviceDataSourceArray.add(deviceModel)
        self.tableView.reloadData()
    }
    
    func printDeviceInfo(deviceInfo: DeviceInfo) -> Void {
        print(deviceInfo.cb)
        print(deviceInfo.advertisementDic.keys)

        print("""

macAddrss = \(deviceInfo.macAddrss)\r\n UUIDString = \(deviceInfo.uuidString)\r\n localName = \(deviceInfo.localName)\r\n name = \(deviceInfo.name) \r\n RSSI = \(deviceInfo.rssi) \r\n

""")

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
            
            let saveDevice = NSEntityDescription.insertNewObject(forEntityName: "BleDevice", into: context) as! BleDevice
            saveDevice.name = deviceModel.name
            saveDevice.uuid = deviceModel.uuidString
            
            do {
                try context.save()
                print("保存成功!")
            }catch{
                print("保存出错，\(error)")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
