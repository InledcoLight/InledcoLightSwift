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
    private var deviceDataSourceArray = [BleDevice]();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 视图设置
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareData()
    }
    
    override func prepareData() {
        super.prepareData()
        self.bleManager.delegate = self
        
        deviceDataSourceArray.removeAll()
        // 从数据库中读取数据
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BleDevice")
        let deviceMOC = DeviceDataCoreManager.getDataCoreContext()
        do {
            self.deviceDataSourceArray = try deviceMOC.fetch(fetch) as! [BleDevice]
            
        }catch{
            print("读取数据库出错\(error)")
        }
        
        self.deviceTableView.reloadData()
    }
    
    override func setViews() {
        super.setViews()
        
        self.automaticallyAdjustsScrollViewInsets = false
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceDataSourceArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let deviceModel = deviceDataSourceArray[indexPath.row]
        cell.textLabel?.text = deviceModel.name
        
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
