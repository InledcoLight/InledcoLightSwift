//
//  DeviceModel.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/9/29.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceModel: NSObject {
    // 设备品牌
    var brand: String! = "defaultBrand"
    // 分组名称
    var group: String! = "defaultGroup"
    // 用户定义名称
    var name: String?
    // 设备名称
    var deviceName: String?
    // 设备类型编码
    var typeCode: String?
    // 设备
    var device: CBPeripheral?
    // MAC地址
    var macAddress: String?
    // UUID
    var uuidString: String?
    // RSSI
    var rssi: Int?
    // 是否被选择，扫描时用来标记设备是否被选择
    var isSelected: Bool?
}
