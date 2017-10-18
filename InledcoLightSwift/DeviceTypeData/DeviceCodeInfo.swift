//
//  DeviceCodeInfo.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceCodeInfo: NSObject {
    var deviceTypeCode: DeviceTypeData.DeviceTypeCode?
    var deviceName: String?
    var pictureName: String?
    var channelNum: Int8?
    var firmwaredId: Int?
    var channelColorArray: [UIColor]?
    var channelColorTitleArray: [String]?
}
