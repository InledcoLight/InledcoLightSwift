//
//  BlueToothManager.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/14.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//  蓝牙管理对象处理
//

import UIKit
import LGAlertView

// 设备开关状态
enum DeviceState {
    case POWER_ON
    case POWER_OFF
    case UNKNOWN_STATE
}

// 蓝牙设置运行模式
enum DeviceRunMode {
    case MANUAL_RUN_MODE
    case AUTO_RUN_MODE
    case UNKNOWN_RUN_MODE
}

// 命令头
enum CommandHeader: String {
    case COMMANDHEAD_ONE = "6801"
    case COMMANDHEAD_TWO = "6802"
    case COMMANDHEAD_THREE = "6803"
    case COMMANDHEAD_FOUR = "6804"
    case COMMANDHEAD_FIVE = "6805"
    case COMMANDHEAD_SIX = "6806"
    case COMMANDHEAD_SEVEN = "6807"
    case COMMANDHEAD_ELEVEN = "680B"
    case COMMANDHEAD_TWELVE = "680C"
    
    case COMMANDHEAD_READ_ONE = "680101"
    
    case COMMANDHEAD_WRITE_ONE = "680201"
}

// 命令类型
enum CommandType {
    case SYNCTIME_COMMAND
    case POWERON_COMMAND
    case POWEROFF_COMMAND
    case FINDDEVICE_COMMAND
    case SETTINGUSERDEFINED_COMMAND
    case SETTINGAUTOMODE_COMMAND
    case READTIME_COMMAND
    case MANUALMODE_COMMAN
    case AUTOMODE_COMMAN
    case UNKNOWN_COMMAND
    
    // 新协议命令类型：特殊命令，即读取自动手动数据命令
    case READDEVICEDATA_COMMAND
}

class BlueToothManager: NSObject, BLEManagerDelegate {
    private static var bluetoothManager: BlueToothManager?;
    private let bleManager: BLEManager! = BLEManager<AnyObject, AnyObject>.default()
    private let reconnectInterval: TimeInterval! = 2
    private let maxConnectCount: Int! = 3
    private var connectTimeCount: Int! = 0
    private var connectTimer: Timer?
    private var isReceiveDataAll: Bool! = false
    private var lastCommandSendTime: TimeInterval! = 0.0
    private let maxCommandLength: Int = 30
    private var currentCommandType: CommandType! = .UNKNOWN_COMMAND
    private var receivedData: String = ""
    typealias oneStrParameterType = (_ dataStr: String?, _ commandType: CommandType) -> Void
    var completeReceiveDataCallback: oneStrParameterType?
    var connectFailedCallback: oneStrParameterType?
    var currentDeviceTypeCode: DeviceTypeCode?
    var writeDataCallback: oneStrParameterType?
    let languageManager: LanguageManager! = LanguageManager.shareInstance()
    
    static func sharedBluetoothManager() -> BlueToothManager {
        if bluetoothManager == nil {
            bluetoothManager = BlueToothManager()
        }
        
        bluetoothManager?.bleManager.delegate = bluetoothManager
        bluetoothManager?.connectTimeCount = 0
        bluetoothManager?.isReceiveDataAll = false
        bluetoothManager?.lastCommandSendTime = 0
        
        return bluetoothManager!
    }
    
    override init() {

    }
    
    /// 连接设备
    /// - parameter uuid: 设备标识
    ///
    /// - returns: 是否开始连接设备
    func connectDeviceWithUuid(uuid: String!) -> Bool {
        if self.bleManager.centralManager.state != .poweredOn {
            // 提示打开蓝牙
            let bluetoothAlert = LGAlertView.init(title: self.languageManager.getTextForKey(key: "bluetoothError"), message: self.languageManager.getTextForKey(key: "blueErrorMessage"), style: .alert, buttonTitles: nil, cancelButtonTitle: self.languageManager.getTextForKey(key: "confirm"), destructiveButtonTitle: nil, delegate: nil)
            
            bluetoothAlert?.show(animated: true, completionHandler: nil)
            
            return false
        } else {
            self.connectTimeCount = 0
            self.connectTimer = Timer.scheduledTimer(timeInterval: reconnectInterval, target: self, selector: #selector(connectTimeCount(timer:)), userInfo: uuid, repeats: true)
            
            // 连接设备如果不在这个数组里面，则会连接失败
            let device: CBPeripheral = self.bleManager.getDeviceByUUID(uuid)
            if !self.bleManager.dev_DICARRAY.contains(device) {
                self.bleManager.dev_DICARRAY.add(device)
            }
            
            self.bleManager.connect(toDevice: device)
            
            return true
        }
    }
    
    /// 断开设备
    /// - parameter uuid: 设备uuid
    ///
    /// - returns: Void
    func disConnectDevice(uuid: String!) -> Void {
        self.connectTimeCount = 0
        self.connectTimer?.invalidate()
        self.connectTimer = nil
        self.bleManager.disconnectDevice(self.bleManager.getDeviceByUUID(uuid))
    }
    
    /// 连接设备定时器方法
    /// - parameter timer: 调用该方法的定时器
    ///
    /// - returns: 空
    @objc private func connectTimeCount(timer: Timer) -> Void {
        print("第\(self.connectTimeCount)次连接！")
        // 连接设备
        self.connectTimeCount = self.connectTimeCount + 1

        if self.connectTimeCount >= self.maxConnectCount {
            let uuid = timer.userInfo as! String
            
            self.connectTimer?.invalidate()
            self.connectTimer = nil

            self.disConnectDevice(uuid: uuid)
            
            // 调用连接超时回调
            if connectFailedCallback != nil {
                self.connectFailedCallback!(nil, CommandType.UNKNOWN_COMMAND)
            }

            return
        }
    }
    
    /// 发送同步时间命令
    /// - parameter device: 设备
    ///
    /// - returns: Void
    func sendSynchronizationTimeCommand(device: CBPeripheral, deviceTypeCode: DeviceTypeCode) -> Void {
        self.isReceiveDataAll = false
        self.receivedData = ""
        self.currentCommandType = .SYNCTIME_COMMAND
        
        // 获取当前时间
        let currentDate: Date! = Date()
        let calendar: Calendar! = Calendar.current
        let weekComps: DateComponents! = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: currentDate)
        
        // 构建同步时间命令
        var commandStr: String? = ""
        switch deviceTypeCode {
        case DeviceTypeCode.LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
            // 旧协议
            commandStr = String(format: "680E%02x%02x%02x%02x%02x%02x%02x", weekComps.year! % 2000, weekComps.month!, weekComps.day!, weekComps.weekday!, weekComps.hour!, weekComps.minute!, weekComps.second!)
            break
        default:
            // 新协议
            commandStr = String(format: "680107%02x%02x%02x%02x%02x%02x%02x", weekComps.year! % 2000, weekComps.month!, weekComps.day!, weekComps.weekday!, weekComps.hour!, weekComps.minute!, weekComps.second!)
            break
        }
        
        self.bleManager.sendData(toDevice1: commandStr! + (commandStr?.calculateXor()!)!, device: device)
    }
    
    /// 发送打开开关命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendPowerOnCommand(uuid: String!) -> Void {
        switch self.currentDeviceTypeCode! {
        case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
            sendCommandToDevice(uuid: uuid, commandStr: "680301", commandType: .POWERON_COMMAND, isXORCommand: true)
        default:
            sendCommandToDevice(uuid: uuid, commandStr: "680C01", commandType: .POWERON_COMMAND, isXORCommand: true)
        }
    }
    
    /// 发送关闭开关命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendPowerOffCommand(uuid: String) -> Void {
        switch self.currentDeviceTypeCode! {
        case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
            sendCommandToDevice(uuid: uuid, commandStr: "680300", commandType: .POWEROFF_COMMAND, isXORCommand: true)
        default:
            sendCommandToDevice(uuid: uuid, commandStr: "680C00", commandType: .POWEROFF_COMMAND, isXORCommand: true)
        }
        
    }
    
    /// 发送手动模式命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendManualModeCommand(uuid: String) -> Void {
        switch self.currentDeviceTypeCode! {
        case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
            sendCommandToDevice(uuid: uuid, commandStr: "680200", commandType: .MANUALMODE_COMMAN, isXORCommand: true)
        default:
            sendCommandToDevice(uuid: uuid, commandStr: "681000", commandType: .MANUALMODE_COMMAN, isXORCommand: true)
        }
    }
    
    /// 发送自动模式命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendAutoModeCommand(uuid: String) -> Void {
        switch self.currentDeviceTypeCode! {
        case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
            sendCommandToDevice(uuid: uuid, commandStr: "680201", commandType: .AUTOMODE_COMMAN, isXORCommand: true)
        default:
            sendCommandToDevice(uuid: uuid, commandStr: "681001", commandType: .AUTOMODE_COMMAN, isXORCommand: true)
        }
    }
    
    /// 发送读取时间命令
    /// - parameter uuid: 设备标识
    ///sendFindDeviceCommand
    /// - returns: void
    func sendReadTimeCommand(uuid: String) -> Void {
        sendCommandToDevice(uuid: uuid, commandStr: "680D", commandType: .READTIME_COMMAND, isXORCommand: true)
    }
    
    /// 发送查找设备命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendFindDeviceCommand(uuid: String) -> Void {
        switch self.currentDeviceTypeCode! {
        case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
            sendCommandToDevice(uuid: uuid, commandStr: "680F", commandType: .FINDDEVICE_COMMAND, isXORCommand: true)
        default:
            break
        }
        
    }
    
    /// 设置设备名称
    /// - parameter one:
    /// - parameter two:
    ///
    /// - returns:
    func setDeviceName(uuid:String , name: String!) -> Void {
        self.bleManager.isEncryption = false
        self.bleManager.setDeviceName(name, device: self.bleManager.getDeviceByUUID(uuid))
        self.bleManager.isEncryption = true
    }
    
    /// 发送特殊命令，读取设备数据
    /// - parameter uuid: 设备uuid
    ///
    /// - returns: Void
    func sendReadDeviceDataCommand(uuid: String) -> Void {
         sendCommandToDevice(uuid: uuid, commandStr: "68000000", commandType: .READDEVICEDATA_COMMAND, isXORCommand: true)
    }
    
    /// 发送命令：所有的命令发送都要通过这个方法发送，该方法可以放松任意长度的命令
    /// - parameter uuid: 设置标识
    /// - parameter commandStr: 不带校验的命令
    /// - parameter commandType: 命令类型
    /// - parameter isXORCommand: 发送命令时是否计算校验码
    /// - parameter commandInterval: 命令发送时间间隔，默认为30毫秒：时间间隔不能过大
    ///
    /// - returns: void
    func sendCommandToDevice(uuid: String, commandStr: String, commandType: CommandType, isXORCommand: Bool, commandInterval: TimeInterval = 30) -> Void {
        
        self.isReceiveDataAll = false
        var xorCommand: String! = commandStr
        if isXORCommand {
            // 计算校验码
            xorCommand.append(xorCommand.calculateXor()!)
        }
        
        var subLastCommandStr: String! = xorCommand
        while subLastCommandStr.count > maxCommandLength {
            let startSlicingIndex = subLastCommandStr.index(subLastCommandStr.startIndex, offsetBy: maxCommandLength)
            self.sendSafeCommand(uuid: uuid, commandStr: String(subLastCommandStr[..<startSlicingIndex]), commandType: commandType, commandInterval: commandInterval)
            
            subLastCommandStr = String(subLastCommandStr[startSlicingIndex...])
        }
        
        self.sendSafeCommand(uuid: uuid, commandStr: subLastCommandStr, commandType: commandType, commandInterval: commandInterval)
    }
    
    private func sendSafeCommand(uuid: String, commandStr: String, commandType: CommandType, commandInterval: TimeInterval) -> Void {
        while Date().timeIntervalSince1970 * 1000 - self.lastCommandSendTime < commandInterval {
            // 如果时间间隔小于一定毫秒，则停止执行，直到两次发送时间间隔大于一定毫秒
            // print("间隔小于时间间隔！")
        }
        
        self.currentCommandType = commandType
        // print("发送命令:\(commandStr)")
        let device: CBPeripheral = self.bleManager.getDeviceByUUID(uuid)
        self.bleManager.sendData(toDevice1: commandStr, device: device)
        
        self.lastCommandSendTime = Date().timeIntervalSince1970 * 1000
    }
    
    // 蓝牙回调
    func connectDeviceSuccess(_ device: CBPeripheral!, error: Error!) {
        print("连接成功:\(String(describing: device.name))")
        self.connectTimeCount = 0
        if self.connectTimer != nil {
            self.connectTimer?.invalidate()
            self.connectTimer = nil
        }
        
        // 发送同步时间命令
        sendSynchronizationTimeCommand(device: device, deviceTypeCode: self.currentDeviceTypeCode!)
    }
    
    func didDisconnectDevice(_ device: CBPeripheral!, error: Error!) {
        print("断开设备:\(String(describing: device.name))")
        // 调用断开设备回调
    }
    
    func receiveDeviceAdvertData(_ dataStr: String!, device: CBPeripheral!) {
        print("获取广播数据成功")
    }
    
    func receiveDeviceDataSuccess_1(_ data: Data!, device: CBPeripheral!) {
        // 处理OTA

        // 处理正常命令返回的数据
        if self.isReceiveDataAll {
            return
        }
        
        // 拼接接收到的数据
        self.receivedData.append(String.dataToHexString(data: data)!)
        if self.receivedData.count <= 0 {
            return
        }
        
        switch self.currentDeviceTypeCode! {
        case .LIGHT_CODE_STRIP_III, .ONECHANNEL_LIGHT, .TWOCHANNEL_LIGHT, .THREECHANNEL_LIGHT, .FOURCHANNEL_LIGHT, .FIVECHANNEL_LIGHT, .SIXCHANNEL_LIGHT:
            // 旧协议
            self.processOldProtocolReceiveData()
            break
        default:
            self.processProtocolReceiveData()
            break
        }
    }
    
    /// 新协议数据接收
    ///
    /// - returns: Void
    func processProtocolReceiveData() -> Void {
        // 两个条件：
        // 1.返回数据中的Count是否与数据量相同
        // 2.校验码是否正确
        let dataCount = (self.receivedData as NSString).substring(with: NSRange.init(location: 6, length: 2)).hexaToDecimal
        if dataCount == (self.receivedData.count / 2 - 5) && self.receivedData.calculateXor() == "00" {
            self.isReceiveDataAll = true
            
            // 根据命令类型，处理返回的数据
            print("发送的命令：\(self.currentCommandType),receivedData=\(String(self.receivedData))")
            // 旧协议部分
            switch self.currentCommandType {
            case .SYNCTIME_COMMAND:
                if self.writeDataCallback != nil {
                    self.writeDataCallback!(self.receivedData, self.currentCommandType)
                }
            case .POWERON_COMMAND,
                 .POWEROFF_COMMAND,
                 .MANUALMODE_COMMAN,
                 .SETTINGAUTOMODE_COMMAND,
                 .SETTINGUSERDEFINED_COMMAND,
                 .AUTOMODE_COMMAN:
                    break
            case .READDEVICEDATA_COMMAND:
                if self.completeReceiveDataCallback != nil {
                    self.completeReceiveDataCallback!(self.receivedData, self.currentCommandType)
                }
            default:
                print("未知命令")
            }
            
            self.receivedData = ""
        }
    }
    
    /// 旧协议数据接收
    ///
    /// - returns: Void
    func processOldProtocolReceiveData() -> Void {
        if self.receivedData.calculateXor() == "00" {
            self.isReceiveDataAll = true
            
            // 根据命令类型，处理返回的数据
            print("发送的命令：\(self.currentCommandType),receivedData=\(String(self.receivedData))")
            switch self.currentCommandType {
            case .SYNCTIME_COMMAND,
                 .POWERON_COMMAND,
                 .POWEROFF_COMMAND,
                 .MANUALMODE_COMMAN,
                 .SETTINGAUTOMODE_COMMAND,
                 .SETTINGUSERDEFINED_COMMAND,
                 .AUTOMODE_COMMAN:
                if self.completeReceiveDataCallback != nil {
                    self.completeReceiveDataCallback!(self.receivedData, self.currentCommandType)
                }
                
            default:
                print("未知命令")
            }
            
            self.receivedData = ""
        }
    }
}

































