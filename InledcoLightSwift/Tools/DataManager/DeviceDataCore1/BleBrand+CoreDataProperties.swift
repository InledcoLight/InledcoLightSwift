//
//  BleBrand+CoreDataProperties.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/10.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//
//

import Foundation
import CoreData


extension BleBrand {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BleBrand> {
        return NSFetchRequest<BleBrand>(entityName: "BleBrand")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var brand_group: NSSet?

}

// MARK: Generated accessors for brand_group
extension BleBrand {

    @objc(addBrand_groupObject:)
    @NSManaged public func addToBrand_group(_ value: BleGroup)

    @objc(removeBrand_groupObject:)
    @NSManaged public func removeFromBrand_group(_ value: BleGroup)

    @objc(addBrand_group:)
    @NSManaged public func addToBrand_group(_ values: NSSet)

    @objc(removeBrand_group:)
    @NSManaged public func removeFromBrand_group(_ values: NSSet)

}
