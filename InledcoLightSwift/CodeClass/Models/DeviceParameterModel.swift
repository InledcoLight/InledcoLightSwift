//
//  DeviceParameterModel.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/17.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceParameterModel: NSObject {
    // 设备类型编码
    var typeCode: DeviceTypeData.DeviceTypeCode?
    // UUID
    var uuid: String?
    // 命令帧头
    var commandHeader: String! = ""
    // 命令码
    var commandCode: String! = ""
    // 通道数量
    var channelNum: Int8?
    // 运行模式
    var runMode: DeviceRunMode?
    // 开关状态
    var powerState: DeviceState?
    // 动态模式
    var dynamicMode: String?
    // 自动模式数据
    // 时间点个数
    var timePointNum: Int8?
    // 时间点数组
    var timePointArray: [String]! = [String]()
    // 自动模式时间点对应值
    var timePointValueDic: [Int: String]! = [Int: String]()
    // 手动模式各路数据
    var manualModeValueDic: [Int: String]! = [Int: String]()
    // 用户自定义数据
    var userDefinedValueDic: [Int: String]! = [Int: String]()
}































