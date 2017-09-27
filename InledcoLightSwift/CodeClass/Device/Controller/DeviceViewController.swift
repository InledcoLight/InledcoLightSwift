//
//  DeviceViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/16.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var deviceTableView: UITableView!
    private lazy var deviceDataSourceArray:NSMutableArray = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 蓝牙设置代理
        self.bleManager.delegate = self
        
        // 视图设置
        setViews()
    }
    
    func setViews() {
        self.automaticallyAdjustsScrollViewInsets = false
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell");
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        return cell;
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
