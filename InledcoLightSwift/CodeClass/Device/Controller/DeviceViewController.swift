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
    private var deviceDataSourceArray: NSMutableArray = []
    private var selectDeviceModel: DeviceModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 视图设置
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 断开蓝牙
        if self.selectDeviceModel != nil && self.selectDeviceModel?.uuidString != nil {
            self.blueToothManager.disConnectDevice(uuid: self.selectDeviceModel?.uuidString)
        }
        
        // 准备数据
        prepareData()
    }
    
    /// 蓝牙初始化
    ///
    /// - returns:
    func prepareBluetoothData() -> Void {
        // 1.连接成功回调
        self.blueToothManager.completeReceiveDataCallback = {
            (receiveDataStr, commandType) in
            // 获取当前数据动态信息
            let deviceCodeInfo = DeviceTypeData.getDeviceInfoWithTypeCode(deviceTypeCode: DeviceTypeData.DeviceTypeCode(rawValue: (self.selectDeviceModel?.typeCode)!)!)
            
            // 解析数据
            let parameterModel: DeviceParameterModel = DeviceParameterModel()
            parameterModel.channelNum = deviceCodeInfo.channelNum
            
            parameterModel.typeCode = deviceCodeInfo.deviceTypeCode
            parameterModel.uuid = self.selectDeviceModel?.uuidString
            
            // 这里可以根据设备编码解析调用不同的解析方法
            switch parameterModel.typeCode! {
                // 这里列出兼容旧设备
            case DeviceTypeData.DeviceTypeCode.LIGHT_CODE_STRIP_III:
                parameterModel.parseOldDeviceDataFromReceiveStrToModel(receiveData: receiveDataStr!)
            default:
                // 默认使用新设备解析数据
                parameterModel.parseDeviceDataFromReceiveStrToModel(receiveData: receiveDataStr!)
            }
            
            
            self.connectAlertController?.dismiss(animated: true, completionHandler: nil)
            // 解析设备数据，跳转界面
            let colorSettingViewController = ColorSettingViewController(nibName: "ColorSettingViewController", bundle: Bundle.main)
            
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
    
    func createAlertController() {
        // 1.连接提示视图
        connectAlertController = LGAlertView.init(activityIndicatorAndTitle: languageManager.getTextForKey(key: "connecting"), message: "", style: .alert, buttonTitles: nil, cancelButtonTitle: languageManager.getTextForKey(key: "cancel"), destructiveButtonTitle: nil)
        
        connectAlertController?.cancelHandler = {
            (alertView) in
            // 取消连接设备
            
        }
        
        // 2.连接失败提示视图
        connectFailedAlertController = LGAlertView.init(title: languageManager.getTextForKey(key: "connectFailed"), message: nil, style: .alert, buttonTitles: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        
        // 3.操作弹出视图
         alertController = UIAlertController(title: self.selectDeviceModel?.name, message: nil, preferredStyle: .actionSheet)
        // 删除操作
        let deleteAction: UIAlertAction = UIAlertAction(title: languageManager.getTextForKey(key: "delete"), style: .destructive) { (alertAction) in
        }
        
        // 重命名操作
        let connectAction: UIAlertAction = UIAlertAction(title: languageManager.getTextForKey(key: "connect"), style: .default) { (alertAction) in
            if self.selectDeviceModel != nil {
                self.connectAlertController?.show(animated: true, completionHandler: nil)
                self.blueToothManager.connectDeviceWithUuid(uuid: self.selectDeviceModel?.uuidString)
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
        
        self.deviceDataSourceArray.removeAllObjects()
        
        // 从数据库中读取数据
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BleDevice")
        let deviceMOC = DeviceDataCoreManager.getDataCoreContext()
        do {
            // 使用这个获取到的数据局不能直接当做数据源，这些事内存中的数据
            let dataArray = try deviceMOC.fetch(fetch)
            for dev in dataArray {
                
                let deviceInfo = dev as! BleDevice
                let deviceModel = DeviceModel()
                
                deviceModel.name = deviceInfo.name
                deviceModel.typeCode = deviceInfo.typeCode
                deviceModel.uuidString = deviceInfo.uuid
                
                self.deviceDataSourceArray.add(deviceModel)
            }
            
        }catch{
            print("读取数据库出错\(error)")
        }
        
        self.deviceTableView.reloadData()
    }
    
    override func setViews() {
        super.setViews()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.deviceTableView.delegate = self
        self.deviceTableView.dataSource = self
        self.deviceTableView.backgroundColor = UIColor.clear
        self.deviceTableView.separatorStyle = .singleLine;
        self.deviceTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.deviceTableView.register(UINib.init(nibName: "DeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceDataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as! DeviceTableViewCell
        
        let deviceModel = deviceDataSourceArray[indexPath.row] as! DeviceModel
        
        cell.lightNameLabel.text = deviceModel.name
        cell.lightDetailLabel.text = deviceModel.typeCode
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectDeviceModel = self.deviceDataSourceArray.object(at: indexPath.row) as? DeviceModel
        self.present(alertController, animated: true, completion: nil)
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
