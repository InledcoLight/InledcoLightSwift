//
//  BleGroup+CoreDataProperties.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/10.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//
//

import Foundation
import CoreData


extension BleGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BleGroup> {
        return NSFetchRequest<BleGroup>(entityName: "BleGroup")
    }

    @NSManaged public var brandId: Int32
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var group_device: NSSet?
    @NSManaged public var group_brand: BleBrand?

}

// MARK: Generated accessors for group_device
extension BleGroup {

    @objc(addGroup_deviceObject:)
    @NSManaged public func addToGroup_device(_ value: BleDevice)

    @objc(removeGroup_deviceObject:)
    @NSManaged public func removeFromGroup_device(_ value: BleDevice)

    @objc(addGroup_device:)
    @NSManaged public func addToGroup_device(_ values: NSSet)

    @objc(removeGroup_device:)
    @NSManaged public func removeFromGroup_device(_ values: NSSet)

}
