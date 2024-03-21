//
//  PhotoModelData+CoreDataProperties.swift
//  Universe App
//
//  Created by Yuriy on 21.03.2024.
//
//

import Foundation
import CoreData


extension PhotoModelData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoModelData> {
        return NSFetchRequest<PhotoModelData>(entityName: "PhotoModelData")
    }

    @NSManaged public var localIdentifiers: String?
    @NSManaged public var isDeleting: Bool
}

extension PhotoModelData : Identifiable {

}
