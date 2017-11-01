//
//  SettingViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/13.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var settingArray: Array<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareData()
        
        setViews()
        // Do any additional setup after loading the view.
    }
    
    override func setViews() {
        super.setViews()
        
        self.title = self.languageManager.getTextForKey(key: "settingTitle")
    }
    
    override func prepareData() {
        super.prepareData()
        
        settingArray = [self.languageManager.getTextForKey(key: "settingLanguage")]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.backgroundColor = UIColor.clear
        cell?.contentView.backgroundColor = UIColor.clear
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = settingArray[indexPath.row]
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let languageViewController = LanguageViewController()
        
        languageViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(languageViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
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
