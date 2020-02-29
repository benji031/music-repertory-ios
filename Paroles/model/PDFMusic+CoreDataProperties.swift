//
//  PDFMusic+CoreDataProperties.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 07/06/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//
//

import Foundation
import CoreData


extension PDFMusic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PDFMusic> {
        return NSFetchRequest<PDFMusic>(entityName: "PDFMusic")
    }

    @NSManaged public var documentPath: String?

}
