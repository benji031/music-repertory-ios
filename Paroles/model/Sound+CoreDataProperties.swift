//
//  Sound+CoreDataProperties.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 18/03/2020.
//  Copyright © 2020 Bananapps. All rights reserved.
//
//

import Foundation
import CoreData


extension Sound {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sound> {
        return NSFetchRequest<Sound>(entityName: "Sound")
    }

    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var music: Music?

}
