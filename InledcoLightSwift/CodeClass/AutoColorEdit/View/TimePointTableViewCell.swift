//
//  TimePointTableViewCell.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/28.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class TimePointTableViewCell: UITableViewCell {
    @IBOutlet weak var timePointDatePicker: UIDatePicker!
    
    @IBOutlet weak var selectButton: UIButton!
    typealias PassButtonSelectedType = (Bool) -> Void
    var selectButtonSelectCallback: PassButtonSelectedType?
    typealias PassDatePickerDateType = (Date) -> Void
    var datePickerValueChangedCallback: PassDatePickerDateType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        let locale = Locale.init(identifier: "NL")
        timePointDatePicker.datePickerMode = .time
        timePointDatePicker.locale = locale
        
        selectButton.setBackgroundImage(UIImage.init(named: "unSelectDevice"), for: .normal)
        selectButton.setBackgroundImage(UIImage.init(named: "selectDevice"), for: .selected)
        selectButton.isSelected = false
    }

    @IBAction func timePointValueChanged(_ sender: UIDatePicker) {
        if datePickerValueChangedCallback != nil {
            datePickerValueChangedCallback!(sender.date)
        }
    }
    
    @IBAction func selectButtonAction(_ sender: UIButton) {
        if selectButtonSelectCallback != nil {
            sender.isSelected = !sender.isSelected
            selectButtonSelectCallback!(sender.isSelected)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
