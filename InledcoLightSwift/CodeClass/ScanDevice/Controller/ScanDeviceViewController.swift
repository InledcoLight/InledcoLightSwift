//
//  ScanDeviceViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/16.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class ScanDeviceViewController: BaseViewController,BLEManagerDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var isScan: Bool! = false
    private let scanInterval = 10
    private var connectTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(connectToDevice), userInfo: nil, repeats: false)
    private let deviceDataSourceArray: NSMutableArray = []
    private let deviceNeedConnectDataSourceArray: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareData()
        self.setViews()
        
        scanDevice(scanInterval: self.scanInterval)
    }

    func scanDevice(scanInterval: Int) -> Void {
        if !isScan {
            isScan = true
            self.bleManager.scanDeviceTime(scanInterval)
        } else {
            isScan = false
            self.bleManager.manualStopScanDevice()
        }
    }
    
    override func prepareData() {
        super.prepareData()
        
        self.bleManager.delegate = self
    }
    
    override func setViews() {
        super.setViews()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ScanDeviceTableViewCell.self, forCellReuseIdentifier: "ScanDeviceTableViewCell")
    }
    
    // 蓝牙代理方法
    func scanDeviceRefrash(_ array: NSMutableArray!) {
        self.deviceDataSourceArray.removeAllObjects()
        self.deviceNeedConnectDataSourceArray.removeAllObjects()
        
        for device in array {
            let deviceInfo: DeviceInfo = device as! DeviceInfo
            // 判断是否在数据库中存在
            
            // 打印扫描到的信息
            printDeviceInfo(deviceInfo: deviceInfo)
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
            if (isSuccess){
                self.deviceDataSourceArray.add(scanDeviceModel)
            }else{
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
    
    @objc func connectToDevice() {
        
    }
    
    func printDeviceInfo(deviceInfo: DeviceInfo) -> Void {
        print(deviceInfo.cb)
        print(deviceInfo.advertisementDic.keys)
        
        print("""

macAddrss = \(deviceInfo.macAddrss)\r\n UUIDString = \(deviceInfo.uuidString)\r\n localName = \(deviceInfo.localName)\r\n name = \(deviceInfo.name) \r\n RSSI = \(deviceInfo.rssi) \r\n

""")
        
    }
    
    // TableView代理方法
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceDataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanDeviceTableViewCell", for: indexPath)
        
        let deviceModel = self.deviceDataSourceArray.object(at: indexPath.row) as! DeviceModel
        
        cell.textLabel?.text = deviceModel.name
        
        return cell
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
