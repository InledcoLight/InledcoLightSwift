//
//  LanguageViewController.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/13.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class LanguageViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    private var languageTitleArray: Array<LanguageManager.LanguageFlag>?
    private var selectLanguage: LanguageManager.LanguageFlag?
    private var currentSelectLanguageIndex: Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        prepareData()
        setViews()
    }

    override func setViews() {
        super.setViews()
        
        let leftBarButtonItem = UIBarButtonItem()
        
        leftBarButtonItem.title = languageManager.getTextForKey(key: "cancel")
        leftBarButtonItem.target = self
        leftBarButtonItem.action = #selector(cancelAction)
        
        let rightBarButtonItem = UIBarButtonItem()
        rightBarButtonItem.target = self
        rightBarButtonItem.action = #selector(doneAction)
        
        rightBarButtonItem.title = languageManager.getTextForKey(key: "done")
        
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "LanguageTableViewCell", bundle: nil), forCellReuseIdentifier: "LanguageTableViewCell")
    }
    
    @objc func cancelAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneAction() -> Void {
        self.languageManager.setUserLanguage(language: self.languageTitleArray![self.currentSelectLanguageIndex])
    }
    
    override func prepareData() {
        super.prepareData()
        
        languageTitleArray = [.auto, .english, .french, .chinese]
        // 读取用户当前设置
        selectLanguage = languageManager.getCurrentLanguageFlag()
        
        switch selectLanguage {
        case .auto?:
            currentSelectLanguageIndex = 0
        case .english?:
            currentSelectLanguageIndex = 1
        case .french?:
            currentSelectLanguageIndex = 2
        case .chinese?:
            currentSelectLanguageIndex = 3
        default:
            currentSelectLanguageIndex = 0
        }
        
        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageTitleArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell", for: indexPath) as! LanguageTableViewCell
        
        cell.languageSelectAction = {
            (isSelected: Bool) -> Void in
            if isSelected {
                self.currentSelectLanguageIndex = indexPath.row
            }
            self.tableView.reloadData()
        }
        
        if self.currentSelectLanguageIndex == indexPath.row {
            cell.languageSelectButton.isSelected = true
        } else {
            cell.languageSelectButton.isSelected = false
        }
        
        cell.languageNameLabel.text = languageManager.getTextForKey(key: (languageTitleArray?[indexPath.row].rawValue)!)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
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
