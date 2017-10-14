//
//  LanguageTableViewCell.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/13.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var languageNameLabel: UILabel!
    @IBOutlet weak var languageSelectButton: UIButton!
    typealias buttonSelect = (_ isSelected: Bool) -> Void
    var languageSelectAction: buttonSelect?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.languageSelectButton.setBackgroundImage(UIImage.init(named: "languageUnSelect"), for: .normal)
        self.languageSelectButton.setBackgroundImage(UIImage.init(named: "languageSelect"), for: .selected)
        languageSelectButton.isSelected = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func languageSelectAction(_ sender: UIButton) {
        sender.isSelected = !(sender.isSelected)
        if languageSelectAction != nil {
            languageSelectAction!(sender.isSelected)
        }
    }
}
