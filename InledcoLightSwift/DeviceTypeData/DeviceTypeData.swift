//
//  DeviceTypeData.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceTypeData {    
    // 颜色值数组
    static let fourColorArray: [UIColor]! = [UIColor.red,UIColor.green,UIColor.blue,UIColor.white]
    static let fourColorTitleArray: [String]! = ["Red","Green","Blue","White"]
    
    ///  根据设备类型编码获取设备信息
    /// - parameter deviceTypeCode: 设备类型编码
    ///
    /// - returns: 设备相关信息
    static func getDeviceInfoWithTypeCode(deviceTypeCode: DeviceTypeCode) -> DeviceCodeInfo {
        let deviceCodeInfo: DeviceCodeInfo = DeviceCodeInfo()
        
        switch deviceTypeCode {
        case .LIGHT_CODE_STRIP_III:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "HAGEN Strip III"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 4
            deviceCodeInfo.channelColorArray = fourColorArray
            deviceCodeInfo.channelColorTitleArray = fourColorTitleArray
        default:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "NEW DEVICE"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 4
            deviceCodeInfo.channelColorArray = fourColorArray
            deviceCodeInfo.channelColorTitleArray = fourColorTitleArray
            break
        }
        
        return deviceCodeInfo
    }
}






















