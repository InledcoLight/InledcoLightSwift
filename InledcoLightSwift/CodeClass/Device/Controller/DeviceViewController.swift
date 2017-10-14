//
//  DeviceViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/16.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import CoreData

class DeviceViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,BLEManagerDelegate {

    @IBOutlet weak var deviceTableView: UITableView!
    @IBOutlet weak var scanBarButtonItem: UIBarButtonItem!
    private var deviceDataSourceArray: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("ViewDideLoad")
        // 视图设置
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("")
        prepareData()
    }
    
    override func prepareData() {
        super.prepareData()
        self.bleManager.delegate = self
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
        self.deviceTableView.register(UINib.init(nibName: "DeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceDataSourceArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as! DeviceTableViewCell
        
        let deviceModel = deviceDataSourceArray[indexPath.row] as! DeviceModel
        
        cell.lightNameLabel.text = deviceModel.name
        cell.lightDetailLabel.text = deviceModel.typeCode
        
        return cell;
    }
    
    // 扫描跳转方法
    @IBAction func scanBarButtonAction(_ sender: UIBarButtonItem) {
        let scanDeviceViewController: ScanDeviceViewController! = ScanDeviceViewController();
        
        self.navigationController?.pushViewController(scanDeviceViewController, animated: true)
    }
    
    func connectDeviceSuccess(_ device: CBPeripheral!, error: Error!) {
        print("蓝牙连接成功!")
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
