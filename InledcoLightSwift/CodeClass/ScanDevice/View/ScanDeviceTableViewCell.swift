//
//  ScanDeviceTableViewCell.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/16.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class ScanDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceDetailLabel: UILabel!
    @IBOutlet weak var deviceSelectButton: UIButton!
    public typealias callBackFunc = (_ sender: UIButton) ->Void
    var selectCallBack: callBackFunc?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        // Initialization code
        self.deviceSelectButton.setBackgroundImage(UIImage.init(named: "unSelectDevice"), for: .normal)
        self.deviceSelectButton.setBackgroundImage(UIImage.init(named: "selectDevice"), for: .selected)
        self.deviceSelectButton.isSelected = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectDeviceAction(_ sender: UIButton) {
        if (selectCallBack != nil) {
            selectCallBack!(sender)
        }
    }
}
