//
//  CommonData.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/11/1.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

// 公共数据
public class CommomData {
    let defaultGroupName = "Default Group"
}

// 通知类型
enum InledcoNotification: String {
    case CANCELPREVIEW_NOTIFICATION = "Cancel Preview"
}

// 所有类型编码
enum DeviceTypeCode: String {
    // 旧协议设备类型编码
    case LIGHT_CODE_STRIP_III = "0111"
    case ONECHANNEL_LIGHT = "0001"
    case TWOCHANNEL_LIGHT = "0002"
    case THREECHANNEL_LIGHT = "0003"
    case FOURCHANNEL_LIGHT = "0004"
    case FIVECHANNEL_LIGHT = "0005"
    case SIXCHANNEL_LIGHT = "0006"
    
    // 新类型编码
    case NEW_DEVICE_LIGHT = "9999"
}
