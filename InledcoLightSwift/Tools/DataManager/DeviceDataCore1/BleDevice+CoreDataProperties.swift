//
//  BleDevice+CoreDataProperties.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/10.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//
//

import Foundation
import CoreData


extension BleDevice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BleDevice> {
        return NSFetchRequest<BleDevice>(entityName: "BleDevice")
    }

    @NSManaged public var deviceName: String?
    @NSManaged public var groupId: Int32
    @NSManaged public var id: Int32
    @NSManaged public var macAddress: String?
    @NSManaged public var name: String?
    @NSManaged public var rssi: String?
    @NSManaged public var typeCode: String?
    @NSManaged public var uuid: String?
    @NSManaged public var brandId: Int32
    @NSManaged public var device_group: BleGroup?

}
